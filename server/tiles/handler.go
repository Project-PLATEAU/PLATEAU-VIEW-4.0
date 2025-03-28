package tiles

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"path"
	"strconv"
	"strings"
	"sync"
	"time"

	"cloud.google.com/go/storage"
	"github.com/eukarya-inc/reearth-plateauview/server/plateaucms"
	"github.com/labstack/echo/v4"
	"github.com/reearth/reearthx/log"
)

const modelKey = "tiles"

type Config struct {
	CMS                  plateaucms.Config
	CacheControl         string
	Host                 string
	ChiitilerURL         string
	ChiitilerCacheBucket string
}

type Handler struct {
	pcms                 *plateaucms.CMS
	http                 *http.Client
	lock                 sync.RWMutex
	host                 *url.URL
	chiitilerURL         *url.URL
	tiles                Tiles
	conf                 Config
	chiitilerCacheBucket *storage.BucketHandle
}

func New(ctx context.Context, conf Config) (*Handler, error) {
	pcms, err := plateaucms.New(conf.CMS)
	if err != nil {
		return nil, fmt.Errorf("failed to create plateau cms: %w", err)
	}

	var host, chiitilerURL *url.URL

	if conf.Host != "" {
		host, err = url.Parse(conf.Host)
		if err != nil {
			return nil, fmt.Errorf("failed to parse host: %w", err)
		}
	}

	if conf.ChiitilerURL != "" {
		chiitilerURL, err = url.Parse(conf.ChiitilerURL)
		if err != nil {
			return nil, fmt.Errorf("failed to parse chiitiler url: %w", err)
		}
	}

	var bucket *storage.BucketHandle
	if conf.ChiitilerCacheBucket != "" {
		client, err := storage.NewClient(ctx)
		if err != nil {
			return nil, fmt.Errorf("failed to get chiitiler bucket: %w", err)
		}

		bucket = client.Bucket(conf.ChiitilerCacheBucket)
	}

	return &Handler{
		pcms:                 pcms,
		conf:                 conf,
		host:                 host,
		chiitilerURL:         chiitilerURL,
		chiitilerCacheBucket: bucket,
		http: &http.Client{
			Timeout: 10 * time.Second,
		},
	}, nil
}

func (h *Handler) Init(ctx context.Context) {
	h.lock.Lock()
	defer h.lock.Unlock()

	tiles, err := initTiles(ctx, h.pcms)
	if err != nil {
		log.Errorfc(ctx, "tiles: failed to init tiles: %v", err)
		return
	}

	h.tiles = tiles
	if len(h.tiles) == 0 {
		log.Debugfc(ctx, "tiles: no tiles found")
		return
	}

	log.Debugfc(ctx, "tiles: initialized: \n%s", h.tiles)
}

func (h *Handler) Route(g *echo.Group) {
	g = g.Group("/tiles")
	g.GET("/:id/:z/:x/:y", h.GetTile)
	g.GET("/styles/:id", styleHandler)
	g.POST("/update", h.UpdateCache)
}

func (h *Handler) UpdateCache(c echo.Context) error {
	ctx := c.Request().Context()
	h.Init(ctx)
	return c.String(http.StatusOK, "ok")
}

func (h *Handler) GetTile(c echo.Context) error {
	id := c.Param("id")
	if _, ok := styles[id]; ok {
		return h.chiitilerHandler(c)
	}

	ctx := c.Request().Context()
	z := c.Param("z")
	x := c.Param("x")
	y := c.Param("y")
	y2 := strings.TrimSuffix(y, path.Ext(y))
	zi, errx := strconv.Atoi(z)
	xi, erry := strconv.Atoi(x)
	yi, errz := strconv.Atoi(y2)
	if errx != nil || erry != nil || errz != nil || zi < 0 || xi < 0 || yi < 0 {
		log.Debugfc(ctx, "tiles: invalid params: %s/%s/%s", z, x, y2)
		return c.JSON(http.StatusNotFound, map[string]string{"error": "not found"})
	}

	tileURL := h.getTileURL(id, zi, xi, yi)
	if tileURL == "" {
		log.Debugfc(ctx, "tiles: not found: %d/%d/%d", zi, xi, yi)
		return c.JSON(http.StatusNotFound, map[string]string{"error": "not found"})
	}

	return h.streamTile(c, tileURL, z, x, y)
}

func (h *Handler) getTileURL(name string, z, x, y int) string {
	h.lock.RLock()
	defer h.lock.RUnlock()

	if h.tiles == nil {
		return ""
	}
	return h.tiles.Find(name, z, x, y)
}

func (h *Handler) streamTile(c echo.Context, base, z, x, y string) error {
	url, err := url.JoinPath(base, z, x, y)
	if err != nil {
		return fmt.Errorf("failed to join url: %w", err)
	}

	resp, err := h.http.Get(url)
	if err != nil {
		return fmt.Errorf("failed to get tile: %w", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Debugfc(c.Request().Context(), "tiles: failed to get tile (status code %d): %s", resp.StatusCode, url)
	}

	for k, v := range resp.Header {
		for _, vv := range v {
			c.Response().Header().Set(k, vv)
		}
	}

	if h.conf.CacheControl != "" {
		c.Response().Header().Set("Cache-Control", h.conf.CacheControl)
	} else if h := resp.Header.Get("Cache-Control"); h != "" {
		c.Response().Header().Set("Cache-Control", h)
	}

	return c.Stream(resp.StatusCode, resp.Header.Get("Content-Type"), resp.Body)
}

func initTiles(ctx context.Context, pcms *plateaucms.CMS) (Tiles, error) {
	ml, err := pcms.AllMetadata(ctx, false)
	if err != nil {
		return nil, fmt.Errorf("failed to get all metadata: %w", err)
	}

	tiles := Tiles{}
	for _, m := range ml {
		prj := m.DataCatalogProjectAlias
		if prj == "" {
			prj = m.ProjectAlias
		}
		if prj == "" {
			continue
		}

		cms, err := m.CMS()
		if err != nil {
			continue
		}

		tiles2, err := getTiles(ctx, cms, prj)
		if err != nil {
			return nil, fmt.Errorf("failed to get tiles from %s: %w", prj, err)
		}

		for k, v := range tiles2 {
			tiles[k] = v
		}
	}

	return tiles, nil
}
