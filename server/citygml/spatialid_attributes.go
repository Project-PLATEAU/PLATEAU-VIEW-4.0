package citygml

import (
	"context"
	"io"
	"net/http"
	"net/url"
	"path"

	"github.com/eukarya-inc/reearth-plateauview/server/geo/spatialid"
	"github.com/klauspost/compress/gzip"
	"github.com/orisano/gosax/xmlb"
	"github.com/reearth/reearthx/log"
)

type Reader interface {
	Open(ctx context.Context) (io.Reader, func() error, error)
	Resolver() CodeResolver
}

type urlReader struct {
	URL    string
	client *http.Client

	skipCodeListFetch bool
	etagCache         map[string]string
}

func (r *urlReader) Open(ctx context.Context) (io.Reader, func() error, error) {
	log.Debugfc(ctx, "citygml: open url: %s", r.URL)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, r.URL, nil)
	if err != nil {
		return nil, nil, err
	}
	u, _ := url.ParseRequestURI(r.URL)
	cacheKey := path.Base(u.Path)

	req.Header.Set("Accept-Encoding", "gzip")
	if etag, ok := r.etagCache[cacheKey]; ok {
		req.Header.Set("If-None-Match", etag)
	}
	resp, err := r.client.Do(req)
	if err != nil {
		return nil, nil, err
	}
	if resp.StatusCode == http.StatusNotModified {
		return nil, nil, resp.Body.Close()
	}
	if resp.StatusCode != http.StatusOK {
		log.Debugfc(ctx, "citygml: failed to open: %s", resp.Status)
		return nil, nil, resp.Body.Close()
	}
	r.etagCache[cacheKey] = resp.Header.Get("ETag")
	if resp.Header.Get("Content-Encoding") == "gzip" {
		gr, err := gzip.NewReader(resp.Body)
		if err != nil {
			_ = resp.Body.Close()
			return nil, nil, err
		}
		cleanup := func() error {
			_ = gr.Close()
			return resp.Body.Close()
		}
		return gr, cleanup, nil
	}
	return resp.Body, resp.Body.Close, nil
}

func (r *urlReader) Resolver() CodeResolver {
	if r.skipCodeListFetch {
		return nil
	}
	return &fetchCodeResolver{
		client: r.client,
		url:    r.URL,
	}
}

func SpatialIDAttributes(ctx context.Context, rs []Reader, spatialIDs []string) ([]map[string]any, error) {
	var filter lod1SolidFilter
	for _, sid := range spatialIDs {
		v, err := spatialid.Parse(sid)
		if err != nil {
			return nil, err
		}
		filter.Bounds = append(filter.Bounds, v.Bounds())
	}

	if len(filter.Bounds) == 0 {
		return nil, nil
	}
	h := lod1SolidHandler{
		Filter: filter,
	}

	var attributes []map[string]any
	buf := make([]byte, 32*1024)
	for _, r := range rs {
		err := func(r Reader) error {
			rc, cleanup, err := r.Open(ctx)
			if err != nil {
				return err
			}
			if rc == nil {
				log.Debugfc(ctx, "citygml: skip scan")
				return nil
			}
			defer func() {
				_ = cleanup()
			}()

			fs := &featureScanner{
				Dec: xmlb.NewDecoder(rc, buf),
			}
			count := 0
			thCache := map[string]tagHandler{}
			for fs.Scan() {
				count++

				id, el := fs.Feature()
				tag := tagName(el.Name)
				if _, ok := thCache[tag]; !ok {
					thCache[tag] = toTagHandler(tag, schemaDefs, r.Resolver())
				}
				fah, err := newFeatureAttributeHandler(fs.ns, id, tag, thCache[tag])
				if err != nil {
					return err
				}
				h.Next = fah
				ok, err := processFeature(fs.Dec, &h)
				if err != nil {
					return err
				}
				if ok {
					attributes = append(attributes, fah.Val)
				}
			}

			if err := fs.Err(); err != nil {
				return err
			}

			log.Debugfc(ctx, "citygml: %d features scanned and %d intersected", count, len(attributes))
			return nil
		}(r)
		if err != nil {
			return nil, err
		}
	}
	return attributes, nil
}
