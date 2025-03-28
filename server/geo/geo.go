package geo

import (
	"math"

	"github.com/JamesLMilner/quadtree-go"
)

type Vec3 struct {
	X, Y, Z float64
}

type Point3 Vec3

type Vec2 struct {
	X, Y float64
}

func (v Vec2) Cross(v2 Vec2) float64 {
	return v.X*v2.Y - v.Y*v2.X
}

func (v Vec2) Dot(v2 Vec2) float64 {
	return v.X*v2.X + v.Y*v2.Y
}

type Point2 Vec2

func (p Point2) Sub(p2 Point2) Vec2 {
	return Vec2{p.X - p2.X, p.Y - p2.Y}
}

// Bounds3 represents an axis-aligned 3D bounding box.
type Bounds3 struct {
	Min, Max Point3
}

func (b Bounds3) height() float64 {
	return b.Max.Z - b.Min.Z
}

func (b Bounds3) IsIntersect(b2 Bounds3) bool {
	return b.Min.X <= b2.Max.X && b.Max.X >= b2.Min.X &&
		b.Min.Y <= b2.Max.Y && b.Max.Y >= b2.Min.Y &&
		b.Min.Z <= b2.Max.Z && b.Max.Z >= b2.Min.Z
}

func (b Bounds3) ToXY() Bounds2 {
	return Bounds2{
		Min: Point2{b.Min.X, b.Min.Y},
		Max: Point2{b.Max.X, b.Max.Y},
	}
}

// Bounds2 represents an axis-aligned 2D bounding box.
type Bounds2 struct {
	Min, Max Point2
}

func ToBounds2(b quadtree.Bounds) Bounds2 {
	return Bounds2{
		Min: Point2{b.X, b.Y},
		Max: Point2{b.X + b.Width, b.Y + b.Height},
	}
}

func (b Bounds2) QBounds() quadtree.Bounds {
	return quadtree.Bounds{
		X:      b.Min.X,
		Y:      b.Min.Y,
		Width:  b.Max.X - b.Min.X,
		Height: b.Max.Y - b.Min.Y,
	}
}

func (b Bounds2) Intersects(b2 Bounds2) bool {
	if b == b2 {
		return true
	}

	// 軸方向で完全に外なら false
	if b.Max.X <= b2.Min.X || b.Min.X >= b2.Max.X ||
		b.Max.Y <= b2.Min.Y || b.Min.Y >= b2.Max.Y {
		return false
	}

	// b の任意の頂点が b2 内部にある
	if b2.In(b.Min) || b2.In(b.Max) ||
		b2.In(Point2{b.Min.X, b.Max.Y}) || b2.In(Point2{b.Max.X, b.Min.Y}) {
		return true
	}

	// b2 の任意の頂点が b 内部にある
	if b.In(b2.Min) || b.In(b2.Max) ||
		b.In(Point2{b2.Min.X, b2.Max.Y}) || b.In(Point2{b2.Max.X, b2.Min.Y}) {
		return true
	}

	// 辺が接しているだけの場合（どちらの頂点も中にない）
	return false
}

func (b Bounds2) In(p Point2) bool {
	return b.Min.X <= p.X && p.X <= b.Max.X &&
		b.Min.Y <= p.Y && p.Y <= b.Max.Y
}

func (b Bounds2) Polygon() Polygon2 {
	return Polygon2{
		b.Min,
		Point2{b.Max.X, b.Min.Y},
		b.Max,
		Point2{b.Min.X, b.Max.Y},
	}
}

type Polygon3 []Point3

func (po Polygon3) Bounds() Bounds3 {
	mini := po[0]
	maxi := po[0]
	for _, p := range po {
		mini.X = min(mini.X, p.X)
		mini.Y = min(mini.Y, p.Y)
		mini.Z = min(mini.Z, p.Z)
		maxi.X = max(maxi.X, p.X)
		maxi.Y = max(maxi.Y, p.Y)
		maxi.Z = max(maxi.Z, p.Z)
	}
	return Bounds3{mini, maxi}
}

func (po Polygon3) toXY() Polygon2 {
	xy := make([]Point2, len(po))
	for i, p := range po {
		xy[i] = Point2{p.X, p.Y}
	}
	return xy
}

type Polygon2 []Point2

func (po Polygon2) Edge(i int) LineSegment2 {
	return LineSegment2{po[i], po[(i+1)%len(po)]}
}

func (po Polygon2) In(p Point2) bool {
	wn := 0
	for i := 0; i < len(po); i++ {
		line := po.Edge(i)
		if line.A.Y <= p.Y {
			if line.B.Y > p.Y && line.orient(p) == 1 {
				wn++
			}
		} else {
			if line.B.Y <= p.Y && line.orient(p) == -1 {
				wn--
			}
		}
	}
	return wn != 0
}

func (po Polygon2) IsIntersect(b Bounds2) bool {
	for i, p := range po {
		if b.In(p) {
			return true
		}
		e := po.Edge(i)
		if e.IsIntersect(b) {
			return true
		}
	}
	for _, p := range b.Polygon() {
		if po.In(p) {
			return true
		}
	}
	return false
}

type LineSegment2 struct {
	A, B Point2
}

func (ls LineSegment2) orient(p Point2) int {
	const eps = 1e-10
	dir := ls.B.Sub(ls.A)
	o := dir.Cross(p.Sub(ls.A))
	switch {
	case o > eps:
		return +1 // counter clock-wise
	case o < -eps:
		return -1 // clock-wise
	case dir.Dot(p.Sub(ls.A)) < -eps:
		return +2 // p-a-b
	case dir.Dot(ls.B.Sub(p)) < -eps:
		return -2 // a-b-p
	default:
		return 0
	}
}

func (ls LineSegment2) isIntersect(ls2 LineSegment2) bool {
	a := ls.orient(ls2.A) * ls.orient(ls2.B)
	b := ls2.orient(ls.A) * ls2.orient(ls.B)
	return a == 0 || b == 0 || (a == -1 && b == -1)
}

func (ls LineSegment2) IsIntersect(b Bounds2) bool {
	if b.In(ls.A) || b.In(ls.B) {
		return true
	}
	po := b.Polygon()
	for i := range po {
		line := po.Edge(i)
		if ls.isIntersect(line) {
			return true
		}
	}
	return false
}

type Polyhedron []Polygon3

func (po Polyhedron) Bounds() Bounds3 {
	mini := po[0][0]
	maxi := po[0][0]
	for _, p := range po {
		for _, p2 := range p {
			mini.X = min(mini.X, p2.X)
			mini.Y = min(mini.Y, p2.Y)
			mini.Z = min(mini.Z, p2.Z)
			maxi.X = max(maxi.X, p2.X)
			maxi.Y = max(maxi.Y, p2.Y)
			maxi.Z = max(maxi.Z, p2.Z)
		}
	}
	return Bounds3{mini, maxi}
}

type LOD1Solid struct {
	Bottom Polygon2
	Bounds Bounds3
}

func (so *LOD1Solid) IsIntersect(b Bounds3) bool {
	return so.Bounds.IsIntersect(b) && so.Bottom.IsIntersect(b.ToXY())
}

func ReconstructLOD1Solid(po Polyhedron) LOD1Solid {
	const eps = 1e-1
	// find bottom face
	bottom := 0
	b := po[0].Bounds()
	for i := 1; i < len(po); i++ {
		b2 := po[i].Bounds()
		if math.Abs(b.Min.Z-b2.Min.Z) >= eps {
			if b.Min.Z > b2.Min.Z {
				bottom = i
				b = b2
			}
		} else if b.height() > b2.height() {
			bottom = i
			b = b2
		}
	}
	return LOD1Solid{
		Bottom: po[bottom].toXY(),
		Bounds: po.Bounds(),
	}
}
