package citygmlpacker

import (
	"archive/zip"
	"context"
	"fmt"
	"io"
	"net/url"
	"path"
	"slices"
	"strings"

	"github.com/orisano/gosax/xmlb"
	"github.com/reearth/reearthx/log"
)

func (p *Packer) writeGML(ctx context.Context, u *url.URL, pctx *packerContext) error {
	upath := getBasePath(u.Path)
	if upath == "" {
		return fmt.Errorf("invalid path: %s", u.String())
	}

	uext := path.Ext(upath)
	if uext != ".gml" {
		return fmt.Errorf("invalid extension: %s", uext)
	}

	root := path.Dir(upath)
	rootDir, _, _ := strings.Cut(root, "/")
	if rootDir == "" {
		return fmt.Errorf("invalid root: %s", root)
	}

	depsMap := map[string]struct{}{}
	ustr := u.String()

	log.Infof("downloading... %s", ustr)
	body, err := httpGet(ctx, p.httpClient, ustr)
	if body != nil {
		defer body.Close()
	}
	if err != nil {
		return fmt.Errorf("get: %w", err)
	}
	if body == nil {
		log.Warnf("skipped download: %s", ustr)
		return nil // skip
	}

	ze, err := pctx.zw.CreateHeader(&zip.FileHeader{
		Name:     upath,
		Method:   zip.Deflate,
		Modified: pctx.modified,
	})
	if err != nil {
		return fmt.Errorf("create: %w", err)
	}

	pctx.roots[rootDir] = struct{}{}
	pctx.files[upath] = struct{}{}

	log.Infof("parsing... %s", ustr)

	if err := findDeps(io.TeeReader(body, ze), depsMap); err != nil {
		return fmt.Errorf("findDeps: %w", err)
	}

	deps := depsMapToSlice(depsMap, pctx.seen, u)

	log.Infof("%d deps detected from %s", ustr, len(deps), ustr)

	p.p.AddDep(int64(len(deps)))
	defer p.p.DepEnd()

	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	downloads, err := DownloadsFromUrls(ctx, deps, u)
	if err != nil {
		return fmt.Errorf("downloadsFromUrls: %w", err)
	}

	go func() {
		sem := make(chan struct{}, 512)
		for _, d := range downloads {
			select {
			case sem <- struct{}{}:
			case <-ctx.Done():
				return
			}

			d := d
			go func() {
				defer func() {
					<-sem
				}()

				log.Infof("downloading... %s", d.URL())
				if d.Download(p.httpClient) {
					return
				}

				err := d.Err()
				if err == nil {
					log.Warnf("skipped download: %s", d.URL())
					return
				}

				log.Errorf("failed to download: %s: %v", d.URL(), err)
			}()
		}
	}()

	for _, d := range downloads {
		n := path.Join(root, d.dep)
		w, err := pctx.zw.Create(n)
		if err != nil {
			return fmt.Errorf("create: %w", err)
		}

		if _, err := d.WriteTo(w); err != nil {
			return err
		}

		pctx.files[n] = struct{}{}
		p.p.DepOne()
	}

	return nil
}

func findDeps(gml io.Reader, depsMap map[string]struct{}) error {
	dec := xmlb.NewDecoder(gml, make([]byte, 32*1024))

	for {
		tok, err := dec.Token()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}
		switch tok.Type() {
		case xmlb.StartElement:
			el, err := tok.StartElement()
			if err != nil {
				return err
			}

			if el.Name.Space == "app" && el.Name.Local == "imageURI" {
				uri, err := dec.Text()
				if err != nil {
					return err
				}
				depsMap[uri] = struct{}{}
			}

			for _, a := range el.Attr {
				if a.Name.Space == "" && a.Name.Local == "codeSpace" {
					depsMap[a.Value] = struct{}{}
				}

				if a.Name.Space == "xsi" && a.Name.Local == "schemaLocation" {
					s := a.Value
					for _, v := range strings.Fields(s) {
						u, err := url.Parse(v)
						if err != nil {
							return fmt.Errorf("invalid schemaLocation: %w", err)
						}
						if u.Scheme == "" {
							depsMap[u.Path] = struct{}{}
						}
					}
				}
			}
		}
	}

	return nil
}

func depsMapToSlice(depsMap, seen map[string]struct{}, u *url.URL) []string {
	deps := make([]string, 0, len(depsMap))
	for dep := range depsMap {
		u := *u
		dir := path.Dir(u.Path)
		u.Path = path.Join(dir, dep)
		if _, ok := seen[u.String()]; ok {
			continue
		}
		seen[u.String()] = struct{}{}
		deps = append(deps, dep)
	}
	slices.Sort(deps)
	return deps
}
