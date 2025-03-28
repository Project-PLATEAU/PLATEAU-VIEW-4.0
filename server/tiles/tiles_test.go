package tiles

import (
	"testing"

	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
)

func TestTiles_Find(t *testing.T) {
	tiles := Tiles{
		"name": []lo.Entry[Range, string]{
			{
				Key:   Range{ZMin: 0, ZMax: 0, XMin: -1, XMax: -1, YMin: 10, YMax: 20},
				Value: "a",
			},
			{
				Key:   Range{ZMin: 1, ZMax: -1, XMin: 1, XMax: 2, YMin: 10, YMax: 20},
				Value: "b",
			},
		},
	}

	assert.Equal(t, "a", tiles.Find("name", 0, 0, 10))
	assert.Equal(t, "a", tiles.Find("name", 0, 0, 20))
	assert.Equal(t, "b", tiles.Find("name", 2, 1, 10))
	assert.Equal(t, "", tiles.Find("name", 2, 3, 11))
}

func TestRange_In(t *testing.T) {
	assert.True(t, Range{ZMin: -1, ZMax: -1, XMin: -1, XMax: -1, YMin: -1, YMax: -1}.In(0, 0, 10))
	assert.True(t, Range{ZMin: 0, ZMax: 0, XMin: -1, XMax: -1, YMin: 10, YMax: 20}.In(0, 0, 10))
	assert.True(t, Range{ZMin: 0, ZMax: 0, XMin: -1, XMax: -1, YMin: 10, YMax: 20}.In(0, 0, 20))
	assert.True(t, Range{ZMin: 1, ZMax: -1, XMin: 1, XMax: 2, YMin: 10, YMax: 20}.In(2, 1, 10))
	assert.False(t, Range{ZMin: 1, ZMax: -1, XMin: 1, XMax: 2, YMin: 10, YMax: 20}.In(2, 3, 11))
}

func TestExtractRange(t *testing.T) {
	assert.Equal(t, Range{
		ZMin: 0, ZMax: 0, YMin: -1, YMax: -1, XMin: -1, XMax: -1,
	}, extractRange("hogeohoge_z0.zip"))
	assert.Equal(t, Range{
		ZMin: 1, ZMax: 1, YMin: -1, YMax: -1, XMin: -1, XMax: -1,
	}, extractRange("hogeohoge_z1.zip"))
	assert.Equal(t, Range{
		ZMin: 10, ZMax: 10, YMin: -1, YMax: -1, XMin: -1, XMax: -1,
	}, extractRange("hogeohoge_z10.zip"))
	assert.Equal(t, Range{
		ZMin: 9, ZMax: 12, YMin: -1, YMax: -1, XMin: 1, XMax: 1,
	}, extractRange("hogeohoge_z9-12_x1.zip"))
	assert.Equal(t, Range{
		ZMin: -1, ZMax: -1, YMin: -1, YMax: -1, XMin: -1, XMax: -1,
	}, extractRange("hogeohoge.zip"))
}
