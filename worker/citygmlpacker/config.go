package citygmlpacker

import (
	"time"
)

type Config struct {
	Dest    string
	Source  string
	Domain  string
	URLs    []string
	Timeout time.Duration
}
