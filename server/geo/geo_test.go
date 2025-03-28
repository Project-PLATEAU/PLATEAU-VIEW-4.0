package geo

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestBounds2_Intersects(t *testing.T) {
	tests := []struct {
		name     string
		a        Bounds2
		b        Bounds2
		expected bool
	}{
		{
			name:     "完全一致",
			a:        Bounds2{Min: Point2{0, 0}, Max: Point2{10, 10}},
			b:        Bounds2{Min: Point2{0, 0}, Max: Point2{10, 10}},
			expected: true,
		},
		{
			name:     "内部で重なっている",
			a:        Bounds2{Min: Point2{0, 0}, Max: Point2{10, 10}},
			b:        Bounds2{Min: Point2{5, 5}, Max: Point2{15, 15}},
			expected: true,
		},
		{
			name:     "辺で接しているだけ（false）",
			a:        Bounds2{Min: Point2{0, 0}, Max: Point2{10, 10}},
			b:        Bounds2{Min: Point2{10, 0}, Max: Point2{20, 10}},
			expected: false,
		},
		{
			name:     "角で接しているだけ（false）",
			a:        Bounds2{Min: Point2{0, 0}, Max: Point2{10, 10}},
			b:        Bounds2{Min: Point2{10, 10}, Max: Point2{20, 20}},
			expected: false,
		},
		{
			name:     "一部が内側に入り込んでいる（辺共有 + 頂点内包）",
			a:        Bounds2{Min: Point2{0, 0}, Max: Point2{10, 10}},
			b:        Bounds2{Min: Point2{5, 0}, Max: Point2{15, 10}},
			expected: true,
		},
		{
			name:     "完全に離れている",
			a:        Bounds2{Min: Point2{0, 0}, Max: Point2{10, 10}},
			b:        Bounds2{Min: Point2{20, 20}, Max: Point2{30, 30}},
			expected: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := tt.a.Intersects(tt.b)
			assert.Equal(t, tt.expected, result)
		})
	}
}
