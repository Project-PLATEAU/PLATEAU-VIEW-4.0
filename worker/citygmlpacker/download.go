package citygmlpacker

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"path"
)

type Download struct {
	dep string
	req *http.Request
	pr  *io.PipeReader
	pw  *io.PipeWriter
	err error
}

func (d *Download) URL() *url.URL {
	return d.req.URL
}

func (d *Download) Err() error {
	return d.err
}

func (d *Download) Close() error {
	d.err = nil
	return d.pw.Close()
}

func (d *Download) CloseWithError(err error) error {
	d.err = err
	return d.pw.CloseWithError(err)
}

func (d *Download) Download(client *http.Client) bool {
	bw := bufio.NewWriterSize(d.pw, 2*1024*1024)

	resp, err := client.Do(d.req)
	if err != nil {
		_ = d.CloseWithError(err)
		return false
	}

	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		_ = d.Close()
		return false
	}

	if resp.StatusCode != http.StatusOK {
		_ = d.CloseWithError(fmt.Errorf("status code: %d", resp.StatusCode))
		return false
	}

	if _, err := io.Copy(bw, resp.Body); err != nil {
		_ = d.CloseWithError(err)
		return false
	}

	_ = d.CloseWithError(bw.Flush())
	return true
}

func (d *Download) WriteTo(w io.Writer) (int64, error) {
	written, err := io.Copy(w, d.pr)
	if err != nil {
		return written, fmt.Errorf("copy: %w", err)
	}
	return written, nil
}

func DownloadsFromUrls(ctx context.Context, urls []string, base *url.URL) ([]*Download, error) {
	downloads := make([]*Download, 0, len(urls))
	for _, dep := range urls {
		u := *base
		dir := path.Dir(u.Path)
		u.Path = path.Join(dir, dep)

		req := newHTTPGetRequest(ctx, &u)
		pr, pw := io.Pipe()
		downloads = append(downloads, &Download{
			dep: dep,
			req: req,
			pr:  pr,
			pw:  pw,
		})
	}

	return downloads, nil
}
