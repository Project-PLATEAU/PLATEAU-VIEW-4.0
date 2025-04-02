package citygml

import (
	"encoding/xml"
	"fmt"
	"io"
	"strconv"
	"strings"
	"unsafe"

	"github.com/eukarya-inc/reearth-plateauview/server/geo"
	"github.com/eukarya-inc/reearth-plateauview/server/geo/spatialid"

	"github.com/orisano/gosax/xmlb"
)

func Features(r io.Reader, spatialIDs []string) ([]string, error) {
	var filter lod1SolidFilter
	for _, sid := range spatialIDs {
		v, err := spatialid.Parse(sid)
		if err != nil {
			return nil, fmt.Errorf("invalid spatialID: %w", err)
		}
		filter.Bounds = append(filter.Bounds, v.Bounds())
	}
	dec := xmlb.NewDecoder(r, make([]byte, 32*1024))
	fs := &featureScanner{
		Dec: dec,
	}
	var features []string
	for fs.Scan() {
		feature, _ := fs.Feature()
		h := lod1SolidHandler{
			Next:   skipAttrHandler{},
			Filter: filter,
		}
		ok, err := processFeature(dec, &h)
		if err != nil {
			return nil, err
		}
		if ok {
			features = append(features, feature)
		}
	}
	if err := fs.Err(); err != nil {
		return nil, err
	}
	return features, nil
}

type lod1SolidFilter struct {
	Bounds []geo.Bounds3
}

func (f *lod1SolidFilter) IsIntersect(faces []geo.Polygon3) bool {
	if len(faces) == 0 {
		return false
	}
	po := geo.Polyhedron(faces)
	poB := po.Bounds()
	var lod1Solid *geo.LOD1Solid
	for _, b := range f.Bounds {
		if !b.IsIntersect(poB) {
			continue
		}
		if lod1Solid == nil {
			so := geo.ReconstructLOD1Solid(po)
			lod1Solid = &so
		}
		if lod1Solid.IsIntersect(b) {
			return true
		}
	}
	return false
}

type lod1SolidHandler struct {
	Next   attrHandler
	Filter lod1SolidFilter

	faces  []geo.Polygon3
	points []geo.Point3
}

func (h *lod1SolidHandler) HandleAttr(dec *xmlb.Decoder, el xml.StartElement) error {
	if el.Name.Local == "lod1Solid" {
		if h.points != nil {
			h.points = h.points[:0]
		}
		if h.faces != nil {
			h.faces = h.faces[:0]
		}
		s := &tagScanner{
			dec: dec,
			tag: "gml:posList",
		}
		for s.Scan() {
			tok, err := dec.Peek()
			if err != nil {
				return err
			}
			if tok.Type() != xmlb.CharData {
				return fmt.Errorf("invalid posList")
			}
			cd, err := tok.CharData()
			if err != nil {
				return err
			}
			begin := len(h.points)
			h.points, err = parsePosList(h.points, unsafe.String(&cd[0], len(cd)))
			if err != nil {
				return fmt.Errorf("parse posList: %w", err)
			}
			h.faces = append(h.faces, h.points[begin:])
		}
		if err := s.Err(); err != nil {
			return err
		}
		if !h.Filter.IsIntersect(h.faces) {
			return errSkipFeature
		}
		return nil
	} else {
		return h.Next.HandleAttr(dec, el)
	}
}

func parsePosList(dest []geo.Point3, t string) ([]geo.Point3, error) {
	n := strings.Count(t, " ") + 1
	if n%3 != 0 {
		return nil, fmt.Errorf("invalid length")
	}
	// gml:LinearRing の gml:posList なので末尾に先頭と同じ座標が入っているため取り除く
	p := n/3 - 1
	if p < 3 {
		return nil, fmt.Errorf("too few points")
	}
	for i := 0; i < p; i++ {
		rest := t
		p1, rest, _ := strings.Cut(rest, " ")
		p2, rest, _ := strings.Cut(rest, " ")
		p3, rest, _ := strings.Cut(rest, " ")
		t = rest
		y, err := strconv.ParseFloat(p1, 64)
		if err != nil {
			return nil, err
		}
		x, err := strconv.ParseFloat(p2, 64)
		if err != nil {
			return nil, err
		}
		z, err := strconv.ParseFloat(p3, 64)
		if err != nil {
			return nil, err
		}
		dest = append(dest, geo.Point3{
			X: x,
			Y: y,
			Z: z,
		})
	}
	return dest, nil
}
