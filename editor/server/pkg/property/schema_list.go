package property

import (
	"github.com/reearth/reearth/server/pkg/id"
	"github.com/reearth/reearthx/util"
)

type SchemaList []*Schema

func (l SchemaList) Find(psid id.PropertySchemaID) *Schema {
	for _, s := range l {
		if s != nil && s.ID().Equal(psid) {
			return s
		}
	}
	return nil
}

func (l SchemaList) Map() SchemaMap {
	return util.MapWithIDFunc[id.PropertySchemaID, Schema](l, (*Schema).ID, false)
}

func (l SchemaList) Loader() SchemaLoader {
	return SchemaLoaderFromMap(l.Map())
}

func (l SchemaList) Concat(m SchemaList) SchemaList {
	return append(l, m...)
}

func (l SchemaList) MapToIDs(ids []id.PropertySchemaID) SchemaList {
	results := make(SchemaList, 0, len(ids))
	for _, id := range ids {
		results = append(results, l.Find(id))
	}
	return results
}

type SchemaMap map[id.PropertySchemaID]*Schema

func (m SchemaMap) Add(schemas ...*Schema) {
	if m == nil {
		return
	}
	for _, p := range schemas {
		if p == nil {
			continue
		}
		m[p.ID()] = p
	}
}

func (m SchemaMap) List() SchemaList {
	return util.MapList[id.PropertySchemaID, Schema](m, false)
}

func (m SchemaMap) Clone() SchemaMap {
	return util.Clone[id.PropertySchemaID, Schema](m)
}

func (m SchemaMap) Merge(m2 SchemaMap) SchemaMap {
	if m == nil {
		return nil
	}
	m3 := m.Clone()
	if m2 == nil {
		return m3
	}

	m3.Add(m2.List()...)

	return m3
}

func (m SchemaMap) Loader() SchemaLoader {
	return SchemaLoaderFromMap(m)
}
