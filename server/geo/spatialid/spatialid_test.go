package spatialid

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestParse(t *testing.T) {
	v, err := Parse("1/2/3/4")
	assert.NoError(t, err)
	assert.Equal(t, Voxel{Z: 1, F: 2, X: 3, Y: 4}, v)
	v, err = Parse("0/1/2")
	assert.NoError(t, err)
	assert.Equal(t, Voxel{Z: 0, F: 0, X: 1, Y: 2}, v)
	v, err = Parse("/1/2/3/4")
	assert.NoError(t, err)
	assert.Equal(t, Voxel{Z: 1, F: 2, X: 3, Y: 4}, v)
	v, err = Parse("/4/3/2")
	assert.NoError(t, err)
	assert.Equal(t, Voxel{Z: 4, F: 0, X: 3, Y: 2}, v)
}
