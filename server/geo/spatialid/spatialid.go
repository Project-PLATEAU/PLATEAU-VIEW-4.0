// Package spatialid provides functionality to work with spatial IDs and convert
// them to geographic bounds. It includes functions to parse spatial IDs in different
// formats and calculate their geographic bounds.

package spatialid

import (
	"fmt"
	"math"
	"strconv"
	"strings"

	"github.com/eukarya-inc/reearth-plateauview/server/geo"
)

// Voxel represents a tile with zoom level (z), floor (f), x-coordinate (x),
// and y-coordinate (y)
type Voxel struct {
	Z int
	F int
	X int
	Y int
}

func (t Voxel) Bounds() geo.Bounds3 {
	z := zoom(t.Z)
	lngMin := z.lng(t.X)
	lngMax := z.lng(t.X + 1)
	latMin, latMax := minmax(z.lat(t.Y), z.lat(t.Y+1))
	floorMin := z.floor(t.F)
	floorMax := z.floor(t.F + 1)
	return geo.Bounds3{
		Min: geo.Point3{
			X: lngMin,
			Y: latMin,
			Z: floorMin,
		},
		Max: geo.Point3{
			X: lngMax,
			Y: latMax,
			Z: floorMax,
		},
	}
}

func minmax(a, b float64) (float64, float64) {
	if a < b {
		return a, b
	} else {
		return b, a
	}
}

func zoom(level int) zoomed {
	return zoomed{
		level: level,
		v:     1 / float64(int(1)<<level),
	}
}

type zoomed struct {
	level int
	v     float64
}

func (z zoomed) lng(x int) float64 {
	return float64(x)*z.v*360.0 - 180.0
}

func (z zoomed) lat(y int) float64 {
	t := math.Pi - 2.0*math.Pi*float64(y)*z.v
	return (180.0 / math.Pi) * math.Atan(math.Sinh(t))
}

func (z zoomed) floor(f int) float64 {
	return float64(f) * float64(int64(1<<(25-z.level)))
}

// Parse parses the given string as a tile identifier and returns the geographic
// bounds of the tile. The input can be in the format "/z/x/y" or "/z/f/x/y", or
// as a hash string. It returns an error if the format is invalid or the string
// contains invalid characters.
func Parse(s string) (Voxel, error) {
	if strings.Contains(s, "/") {
		t, err := parseTile(s)
		if err != nil {
			return Voxel{}, err
		}
		return t, nil
	} else {
		t, err := parseTileHash(s)
		if err != nil {
			return Voxel{}, err
		}
		return t, nil
	}
}

// parseTile parses a tile identifier in the format "z/x/y" or "z/f/x/y". It
// returns a zfxyTile object or an error if the format is invalid.
func parseTile(s string) (Voxel, error) {
	// z/f?/x/y
	s = strings.TrimPrefix(s, "/")
	tokens := strings.SplitN(s, "/", 5)
	switch len(tokens) {
	case 3:
		var t Voxel
		var err error
		if t.Z, err = strconv.Atoi(tokens[0]); err != nil {
			return Voxel{}, err
		}
		if t.X, err = strconv.Atoi(tokens[1]); err != nil {
			return Voxel{}, err
		}
		if t.Y, err = strconv.Atoi(tokens[2]); err != nil {
			return Voxel{}, err
		}
		return t, nil
	case 4:
		var t Voxel
		var err error
		if t.Z, err = strconv.Atoi(tokens[0]); err != nil {
			return Voxel{}, err
		}
		if t.F, err = strconv.Atoi(tokens[1]); err != nil {
			return Voxel{}, err
		}
		if t.X, err = strconv.Atoi(tokens[2]); err != nil {
			return Voxel{}, err
		}
		if t.Y, err = strconv.Atoi(tokens[3]); err != nil {
			return Voxel{}, err
		}
		return t, nil
	default:
		return Voxel{}, fmt.Errorf("invalid format")
	}
}

// parseTileHash parses a hash string representing a tile and converts it into a
// zfxyTile object. The hash string is a sequence of characters '1' to '9'
// representing the tile's coordinates. It returns an error if the string
// contains invalid characters.
func parseTileHash(s string) (Voxel, error) {
	var f, y, x int
	for _, c := range s {
		if !('1' <= c && c <= '9') {
			return Voxel{}, fmt.Errorf("invalid character '%c'", c)
		}
		v := c - '1'
		x <<= 1
		y <<= 1
		f <<= 1
		if v&1 != 0 {
			x |= 1
		}
		if v&2 != 0 {
			y |= 1
		}
		if v&4 != 0 {
			f |= 1
		}
	}
	z := len(s)
	return Voxel{Z: z, F: f, X: x, Y: y}, nil
}
