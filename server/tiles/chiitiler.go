package tiles

import (
	_ "embed"
	"errors"
	"fmt"
	"io"
	"net/http"

	"cloud.google.com/go/storage"
	"github.com/labstack/echo/v4"
	"github.com/reearth/reearthx/log"
)

// to generate style JSON files, see /tools/tile-style-json

//go:embed darkStyle.json
var DarkStyle []byte

//go:embed lightStyle.json
var LightStyle []byte

var styles = map[string][]byte{
	"dark-map":  DarkStyle,
	"light-map": LightStyle,
}

// chiitilerHandler handles requests for chiitiler with style
func (h *Handler) chiitilerHandler(c echo.Context) error {
	if h.host == nil || h.chiitilerURL == nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "not found"})
	}

	ctx := c.Request().Context()
	style := c.Param("id")
	_, ok := styles[style]
	if !ok {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "not found"})
	}

	z := c.Param("z")
	x := c.Param("x")
	y := c.Param("y")

	// get cache
	if h.chiitilerCacheBucket != nil {
		obj := h.chiitilerCacheBucket.Object(getKey(style, z, x, y))
		r, err := obj.NewReader(ctx)
		if err != nil {
			if !errors.Is(err, storage.ErrObjectNotExist) {
				log.Errorfc(ctx, "tiles: failed to get cache: %v", err)
			}
		} else {
			defer r.Close()
		}

		if r != nil {
			if h.conf.CacheControl != "" {
				c.Response().Header().Set("Cache-Control", h.conf.CacheControl)
			} else {
				c.Response().Header().Set("Cache-Control", r.Attrs.CacheControl)
			}
			return c.Stream(http.StatusOK, r.Attrs.ContentType, r)
		}
	}

	styleURL := *h.host
	styleURL.Path = fmt.Sprintf("/tiles/styles/%s", style)
	u := *h.chiitilerURL
	u.Path = fmt.Sprintf("/tiles/%s/%s/%s", z, x, y)
	q := u.Query()
	q.Add("url", styleURL.String())
	u.RawQuery = q.Encode()
	us := u.String()

	log.Debugfc(ctx, "tiles: chiitiler: %s", us)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, us, nil)
	if err != nil {
		log.Errorfc(ctx, "tiles: failed to create request: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "internal server error"})
	}

	resp, err := h.http.Do(req)
	if err != nil {
		log.Errorfc(ctx, "tiles: failed to request chiitiler: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "internal server error"})
	}

	defer resp.Body.Close()

	var body io.Reader = resp.Body
	// save cache
	if resp.StatusCode == http.StatusOK && h.chiitilerCacheBucket != nil {
		obj := h.chiitilerCacheBucket.Object(getKey(style, z, x, y))
		log.Debugfc(ctx, "tiles: cache save: %s", obj.ObjectName())
		w := obj.NewWriter(ctx)
		defer w.Close()
		body = io.TeeReader(resp.Body, w)
	}

	return c.Stream(resp.StatusCode, resp.Header.Get("Content-Type"), body)
}

func styleHandler(c echo.Context) error {
	style := c.Param("id")
	s, ok := styles[style]
	if !ok {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "not found"})
	}

	return c.Blob(http.StatusOK, "application/json", s)
}

func getKey(style, z, x, y string) string {
	return fmt.Sprintf("%s/%s/%s/%s", style, z, x, y)
}
