package tiles

import (
	"context"
	"fmt"
	"net/url"
	"path"
	"strconv"
	"strings"

	cms "github.com/reearth/reearth-cms-api/go"
	"github.com/samber/lo"
)

func getTiles(ctx context.Context, c cms.Interface, prj string) (Tiles, error) {
	items, err := c.GetItemsByKeyInParallel(ctx, prj, modelKey, true, 0)
	if err != nil || items == nil {
		return nil, nil
	}

	res := Tiles{}

	for _, item := range items.Items {
		name := lo.FromPtr(item.FieldByKey("name").GetValue().String())
		if name == "" {
			continue
		}

		assetsRaw, _ := item.FieldByKey("assets").Value.([]any)
		urls := []lo.Entry[Range, string]{}
		for _, assetRaw := range assetsRaw {
			asset := cms.PublicAssetFrom(assetRaw)
			if asset == nil {
				continue
			}

			r := extractRange(asset.URL)
			if u := assetBaseURL(asset.URL); u != "" {
				urls = append(urls, lo.Entry[Range, string]{Key: r, Value: u})
			}
		}

		if len(urls) == 0 {
			continue
		}

		res[name] = urls
	}

	return res, nil
}

func assetBaseURL(zipURL string) string {
	u, err := url.Parse(zipURL)
	if err != nil {
		return ""
	}

	u.Path = strings.TrimSuffix(u.Path, path.Ext(u.Path))
	return u.String()
}

type Tiles map[string][]lo.Entry[Range, string]

func (t Tiles) Find(name string, z, x, y int) string {
	if m, ok := t[name]; ok {
		for _, r := range m {
			if r.Key.In(z, x, y) {
				return r.Value
			}
		}
	}
	return ""
}

func (t Tiles) String() string {
	res := ""
	for name, urls := range t {
		res += name + ":\n"
		for _, url := range urls {
			_, p, ok := strings.Cut(url.Value, "/assets/")
			if !ok {
				p = url.Value
			}
			res += fmt.Sprintf("  %s: %s\n", url.Key, p)
		}
	}
	return res
}

type Range struct {
	ZMin int
	ZMax int
	XMin int
	XMax int
	YMin int
	YMax int
}

func (r Range) String() string {
	w := "*"
	zmin, zmax, xmin, xmax, ymin, ymax := w, w, w, w, w, w
	if r.ZMin >= 0 {
		zmin = strconv.Itoa(r.ZMin)
	}
	if r.ZMax >= 0 {
		zmax = strconv.Itoa(r.ZMax)
	}
	if r.XMin >= 0 {
		xmin = strconv.Itoa(r.XMin)
	}
	if r.XMax >= 0 {
		xmax = strconv.Itoa(r.XMax)
	}
	if r.YMin >= 0 {
		ymin = strconv.Itoa(r.YMin)
	}
	if r.YMax >= 0 {
		ymax = strconv.Itoa(r.YMax)
	}
	return fmt.Sprintf("z%s-%s,x%s-%s,y%s-%s", zmin, zmax, xmin, xmax, ymin, ymax)
}

func (r Range) In(z, x, y int) bool {
	return (r.ZMin < 0 || r.ZMin <= z) && (r.ZMax < 0 || z <= r.ZMax) &&
		(r.XMin < 0 || r.XMin <= x) && (r.XMax < 0 || x <= r.XMax) &&
		(r.YMin < 0 || r.YMin <= y) && (r.YMax < 0 || y <= r.YMax)
}

func extractRange(name string) Range {
	name = strings.TrimSuffix(path.Base(name), path.Ext(name))
	parts := strings.Split(name, "_")
	zmin, zmax := extractRangePart(parts, "z")
	xmin, xmax := extractRangePart(parts, "x")
	ymin, ymax := extractRangePart(parts, "y")
	return Range{ZMin: zmin, ZMax: zmax, XMin: xmin, XMax: xmax, YMin: ymin, YMax: ymax}
}

func extractRangePart(parts []string, prefix string) (min, max int) {
	min = -1
	max = -1

	for _, part := range parts {
		if !strings.HasPrefix(part, prefix) {
			continue
		}

		part := strings.TrimPrefix(part, prefix)
		if strings.Contains(part, "-") {
			ran := strings.Split(part, "-")
			if len(ran) != 2 {
				return
			}

			min2, err := strconv.Atoi(ran[0])
			if err != nil {
				return
			}

			max2, err := strconv.Atoi(ran[1])
			if err != nil {
				return
			}

			if min2 > max2 {
				min, max = max2, min2
			} else {
				min, max = min2, max2
			}
			return
		}

		d, err := strconv.Atoi(part)
		if err != nil {
			return
		}
		min = d
		max = d
		return
	}

	return
}
