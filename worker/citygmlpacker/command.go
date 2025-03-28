package citygmlpacker

import (
	"bufio"
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"path"
	"strconv"
	"strings"
	"sync"
	"time"

	"cloud.google.com/go/storage"
	"github.com/eukarya-inc/reearth-plateauview/server/citygml"
	"github.com/reearth/reearthx/log"
	"google.golang.org/api/googleapi"
)

const defaultTimeout = 15 * time.Minute

func Run(conf Config) (err error) {
	if conf.Timeout <= 0 {
		conf.Timeout = defaultTimeout
	}

	log.Printf("timeout: %s", conf.Timeout)
	bgctx := context.Background()

	destURL, err := url.Parse(conf.Dest)
	if err != nil {
		return fmt.Errorf("invalid destination bucket(%s): %w", conf.Dest, err)
	}
	if destURL.Scheme != "gs" {
		return fmt.Errorf("invalid destination bucket(%s): must be gs://", conf.Dest)
	}

	var sourceURL *url.URL
	if conf.Source != "" {
		sourceURL, err = url.Parse(conf.Source)
		if err != nil {
			return fmt.Errorf("invalid source bucket(%s): %w", conf.Source, err)
		}
		if sourceURL.Scheme != "gs" {
			return fmt.Errorf("invalid source bucket(%s): must be gs://", conf.Source)
		}
	}

	gcs, err := storage.NewClient(bgctx)
	if err != nil {
		return fmt.Errorf("storage.NewClient: %v", err)
	}

	urls, err := resolveURLs(bgctx, gcs, conf.URLs, sourceURL)
	if err != nil {
		return fmt.Errorf("resolve URLs: %w", err)
	}

	log.Printf("resolved urls:\n%s", strings.Join(urls, "\n"))

	obj := gcs.Bucket(destURL.Host).Object(path.Join(strings.TrimPrefix(destURL.Path, "/")))

	startedAt := time.Now().Format(time.RFC3339Nano)

	defer func() {
		if err == nil {
			return
		}
		metadata := citygml.Status(PackStatusFailed)
		metadata["startedAt"] = startedAt
		// Use background context for metadata update to avoid timeout issues
		_, uErr := obj.Update(bgctx, storage.ObjectAttrsToUpdate{
			Metadata: metadata,
		})
		if uErr != nil {
			log.Printf("failed to update status: (to=%s): %v", PackStatusFailed, uErr)
		}
	}()

	attrs, err := obj.Attrs(bgctx)
	if err != nil {
		return fmt.Errorf("get metadata: %v", err)
	}

	if status := getStatus(attrs.Metadata); status != PackStatusAccepted {
		log.Printf("SKIPPED: already exists (status=%s)", status)
		return nil
	}
	metadata := status(PackStatusProcessing)
	metadata["startedAt"] = startedAt
	{
		_, err = obj.If(storage.Conditions{GenerationMatch: attrs.Generation, MetagenerationMatch: attrs.Metageneration}).
			Update(bgctx, storage.ObjectAttrsToUpdate{Metadata: metadata})

		if err != nil {
			var gErr *googleapi.Error
			if !(errors.As(err, &gErr) && gErr.Code == http.StatusPreconditionFailed) {
				log.Printf("SKIPPED: someone else is processing")
				return nil
			}
			return fmt.Errorf("update metadata: %v", err)
		}
	}

	w := obj.NewWriter(bgctx)
	completedMetadata := status(PackStatusSucceeded)
	completedMetadata["startedAt"] = startedAt
	w.ObjectAttrs.Metadata = completedMetadata
	defer w.Close()

	ctx, cancel := context.WithTimeout(bgctx, conf.Timeout)
	defer cancel()
	p := NewPacker(w, nil)

	var finished bool
	var finishedMu sync.Mutex

	go func() {
		t := time.NewTicker(5 * time.Second)
		defer t.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-t.C:
				finishedMu.Lock()
				ok := finished
				if ok {
					finishedMu.Unlock()
					return
				}

				progress := p.Progress()
				metadata["total"] = strconv.FormatInt(progress.Total(), 10)
				metadata["processed"] = strconv.FormatInt(progress.Processed(), 10)
				_, err := obj.Update(ctx, storage.ObjectAttrsToUpdate{
					Metadata: metadata,
				})
				finishedMu.Unlock()
				if err != nil {
					log.Printf("[WARN] failed to update progress: %s", err)
				}
			}
		}
	}()

	if err := p.Pack(ctx, conf.Domain, urls); err != nil {
		return fmt.Errorf("pack: %w", err)
	}
	finishedMu.Lock()
	defer finishedMu.Unlock()
	if err := w.Close(); err != nil {
		return fmt.Errorf("close object writer: %v", err)
	}
	finished = true
	return nil
}

func resolveURLs(ctx context.Context, gcs *storage.Client, urls []string, source *url.URL) ([]string, error) {
	if source == nil {
		return urls, nil
	}

	obj := gcs.Bucket(source.Host).Object(path.Join(strings.TrimPrefix(source.Path, "/")))
	r, err := obj.NewReader(ctx)
	if err != nil {
		return nil, fmt.Errorf("open source file: %w", err)
	}

	defer r.Close()

	var resolved []string
	sc := bufio.NewScanner(r)
	for sc.Scan() {
		txt := sc.Text()
		if txt == "" {
			continue
		}
		resolved = append(resolved, txt)
	}
	if err := sc.Err(); err != nil {
		return nil, fmt.Errorf("read source file: %w", err)
	}
	return resolved, nil
}
