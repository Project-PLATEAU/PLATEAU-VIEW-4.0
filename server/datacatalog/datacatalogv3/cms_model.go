package datacatalogv3

import (
	"encoding/json"
	"fmt"
	"path"
	"slices"
	"time"

	"github.com/eukarya-inc/reearth-plateauview/server/cmsintegration/cmsintegrationcommon"
	"github.com/eukarya-inc/reearth-plateauview/server/datacatalog/datacatalogcommon"
	cms "github.com/reearth/reearth-cms-api/go"
	"github.com/samber/lo"
)

const modelPrefix = "plateau-"
const cityModel = "city"
const relatedModel = "related"
const genericModel = "generic"
const sampleModel = "sample"
const geospatialjpDataModel = "geospatialjp-data"
const defaultSpec = "第3.2版"

type ManagementStatus string

type stage string

const (
	stageAlpha            stage            = "alpha"
	stageBeta             stage            = "beta"
	stageGA               stage            = "ga"
	ManagementStatusReady ManagementStatus = "確認可能"
)

type FeatureType struct {
	Code      string `json:"code,omitempty" cms:"code,text"`
	Name      string `json:"name,omitempty" cms:"name,text"`
	Order     int    `json:"order,omitempty" cms:"order,integer"`
	GroupName string `json:"group_name,omitempty" cms:"group_name,text"`
	// for plateau
	MinSpecMajor          int              `json:"spec_major,omitempty" cms:"spec_major,integer"`
	MinYear               int              `json:"min_year,omitempty" cms:"min_year,integer"`
	Flood                 bool             `json:"flood,omitempty" cms:"flood,bool"`
	MVTLayerName          []string         `json:"layer_name,omitempty" cms:"layer_name,text"`
	MVTLayerNamesForLOD   map[int][]string `json:"layer_names_for_lod,omitempty" cms:"-"`
	MVTLayerNamePrefix    string           `json:"layer_name_prefix,omitempty" cms:"layer_name_prefix,text"`
	UseCategoryAsMVTLayer bool             `json:"use_category_as_mvt_layer" cms:"use_category_as_mvt_layer,bool"`
	HideTexture           bool             `json:"hide_texture,omitempty" cms:"hide_texture,bool"`
	HideLOD               bool             `json:"hide_lod,omitempty" cms:"hide_lod,bool"`
}

type CityItem struct {
	ID             string                    `json:"id,omitempty" cms:"id"`
	Prefecture     string                    `json:"prefecture,omitempty" cms:"prefecture,select"`
	CityName       string                    `json:"city_name,omitempty" cms:"city_name,text"`
	CityNameEn     string                    `json:"city_name_en,omitempty" cms:"city_name_en,text"`
	CityCode       string                    `json:"city_code,omitempty" cms:"city_code,text"`
	Spec           string                    `json:"spec,omitempty" cms:"spec,select"`
	References     map[string]string         `json:"references,omitempty" cms:"-"`
	RelatedDataset string                    `json:"related_dataset,omitempty" cms:"related_dataset,reference"`
	Year           string                    `json:"year,omitempty" cms:"year,select"`
	PRCS           cmsintegrationcommon.PRCS `json:"prcs,omitempty" cms:"prcs,select"`
	OpenDataURL    string                    `json:"open_data_url,omitempty" cms:"open_data_url,text"`
	SubCityCode    string                    `json:"city_code_sub,omitempty" cms:"city_code_sub,text"`
	CodeLists      *cms.PublicAsset          `json:"codelists,omitempty" cms:"codelists,asset"`
	Schemas        *cms.PublicAsset          `json:"schemas,omitempty" cms:"schemas,asset"`
	Metadata       *cms.PublicAsset          `json:"metadata,omitempty" cms:"metadata,asset"`
	Specification  *cms.PublicAsset          `json:"specification,omitempty" cms:"specification,asset"`
	Misc           *cms.PublicAsset          `json:"misc,omitempty" cms:"misc,asset"`
	// meatadata
	PlateauDataStatus   *cms.Tag        `json:"plateau_data_status,omitempty" cms:"plateau_data_status,select,metadata"`
	RelatedDataStatus   *cms.Tag        `json:"related_data_status,omitempty" cms:"related_data_status,select,metadata"`
	CityPublic          bool            `json:"city_public,omitempty" cms:"city_public,bool,metadata"`
	SDKPublic           bool            `json:"sdk_public,omitempty" cms:"sdk_public,bool,metadata"`
	RelatedPublic       bool            `json:"related_public,omitempty" cms:"related_public,bool,metadata"`
	Public              map[string]bool `json:"public,omitempty" cms:"-"`
	GeospatialjpPublish bool            `json:"geospatialjp_publish,omitempty" cms:"geospatialjp_publish,bool,metadata"`
	Sample              bool            `json:"sample,omitempty" cms:"sample,bool,metadata"`
}

func CityItemFrom(item *cms.Item, featureTypes []FeatureType) (i *CityItem) {
	i = &CityItem{}
	item.Unmarshal(i)

	references := map[string]string{}
	public := map[string]bool{}
	for _, ft := range featureTypes {
		if ref := item.FieldByKey(ft.Code).GetValue().String(); ref != nil {
			references[ft.Code] = *ref
		}

		if pub := item.MetadataFieldByKey(ft.Code + "_public").GetValue().Bool(); pub != nil {
			public[ft.Code] = *pub
		}
	}

	i.References = references
	i.Public = public

	if i.Spec == "" {
		i.Spec = defaultSpec
	}

	return
}

func (i *CityItem) YearInt() int {
	return datacatalogcommon.YearInt(i.Year)
}

func (c *CityItem) PlanarCrsEpsgCode() string {
	return c.PRCS.EPSGCode()
}

func (c *CityItem) GetOpenDataURL() string {
	if c == nil {
		return ""
	}
	if c.OpenDataURL != "" {
		return c.OpenDataURL
	}
	return geospatialjpURL(c.CityCode, c.CityNameEn, c.YearInt())
}

func (i *CityItem) PlateauStage(ft string) stage {
	if i.CityPublic || ft != "" && i.Public[ft] {
		return stageGA
	}
	if i.PlateauDataStatus != nil && i.PlateauDataStatus.Name == string(ManagementStatusReady) {
		return stageBeta
	}
	return stageAlpha
}

func (i *CityItem) SDKStage() stage {
	if i.SDKPublic {
		return stageGA
	}
	if i.PlateauStage("") == stageBeta {
		return stageBeta
	}
	return stageAlpha
}

func (i *CityItem) IsPublicOrBeta() bool {
	if s := i.PlateauStage(""); s == stageGA || s == stageBeta {
		return true
	}
	if s := i.SDKStage(); s == stageGA || s == stageBeta {
		return true
	}
	for _, p := range i.Public {
		if p {
			return true
		}
	}
	return false
}

func (i *CityItem) MetadataZipURLs() []string {
	if i == nil {
		return nil
	}

	files := []*cms.PublicAsset{
		i.CodeLists,
		i.Schemas,
		i.Metadata,
		i.Specification,
		i.Misc,
	}

	return lo.FilterMap(files, func(a *cms.PublicAsset, _ int) (string, bool) {
		if a == nil || path.Ext(a.URL) != ".zip" {
			return "", false
		}
		return a.URL, true
	})
}

type PlateauFeatureItem struct {
	ID          string                    `json:"id,omitempty" cms:"id"`
	City        string                    `json:"city,omitempty" cms:"city,reference"`
	CityGML     string                    `json:"citygml,omitempty" cms:"citygml,-"`
	Data        []string                  `json:"data,omitempty" cms:"data,-"`
	Desc        string                    `json:"desc,omitempty" cms:"desc,textarea"`
	Items       []PlateauFeatureItemDatum `json:"items,omitempty" cms:"items,group"`
	Dic         string                    `json:"dic,omitempty" cms:"dic,textarea"`
	Group       string                    `json:"group,omitempty" cms:"group,text"`
	MaxLOD      string                    `json:"maxlod,omitempty" cms:"maxlod,-"`
	FeatureType string                    `json:"feature_type,omitempty" cms:"feature_type,select"`
	// metadata
	Sample bool     `json:"sample,omitempty" cms:"sample,bool,metadata"`
	Status *cms.Tag `json:"status,omitempty" cms:"status,select,metadata"`
	// common
	CreatedAt time.Time `json:"created_at,omitempty"`
	UpdatedAt time.Time `json:"updated_at,omitempty"`
}

func (c *PlateauFeatureItem) IsBeta() bool {
	return c.Status != nil && c.Status.Name == string(ManagementStatusReady)
}

func (c PlateauFeatureItem) ReadDic() (d Dic, _ error) {
	err := json.Unmarshal([]byte(c.Dic), &d)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal dic: %w", err)
	}
	return d, nil
}

type PlateauFeatureItemDatum struct {
	ID    string   `json:"id,omitempty" cms:"id"`
	Data  []string `json:"data,omitempty" cms:"data,-"`
	Name  string   `json:"name,omitempty" cms:"name,text"`
	Desc  string   `json:"desc,omitempty" cms:"desc,textarea"`
	Key   string   `json:"key,omitempty" cms:"key,text"`
	Group string   `json:"group,omitempty" cms:"group,text"`
	// Simple indicates that this item should not use subcode and subname
	Simple bool `json:"simple,omitempty" cms:"-"`
}

type Dic map[string][]DicEntry // admin, fld. htd, tnm, urf, gen

func (d Dic) FindEntryOrDefault(key, name string) (*DicEntry, bool) {
	if e := d.FindEntry(key, name); e != nil {
		// attach order
		if key == "urf" && e.Order == nil {
			e.Order = lo.ToPtr(slices.Index(UrfFeatureTypes, name) + 1)
		}
		return e, true
	}

	// urf
	if key == "urf" {
		if urfType, ok := UrfFeatureTypeMap[name]; ok {
			return &DicEntry{
				Name:        &StringOrNumber{Value: name},
				Code:        &StringOrNumber{Value: name},
				Description: urfType.Name,
				Order:       lo.ToPtr(slices.Index(UrfFeatureTypes, name) + 1),
			}, true
		}
	}

	return &DicEntry{
		Name:        &StringOrNumber{Value: name},
		Code:        &StringOrNumber{Value: name},
		Description: name,
	}, false
}

func (d Dic) FindEntry(key, name string) *DicEntry {
	if d == nil {
		return nil
	}

	if entries, ok := d[key]; ok {
		for _, e := range entries {
			if e.Name.String() == name || e.Code.String() == name {
				return &e
			}
		}
	}

	return nil
}

type DicEntry struct {
	Name              *StringOrNumber `json:"name,omitempty"`
	Description       string          `json:"description,omitempty"`
	Code              *StringOrNumber `json:"code,omitempty"`               // bldg only
	Admin             string          `json:"admin,omitempty"`              // fld only
	Scale             string          `json:"scale,omitempty"`              // fld only
	Suffix            string          `json:"suffix,omitempty"`             // fld only (optional)
	SuffixDescription string          `json:"suffix_description,omitempty"` // fld only (optional)
	Order             *int            `json:"order"`
}

func PlateauFeatureItemFrom(item *cms.Item, code string) (i *PlateauFeatureItem) {
	i = &PlateauFeatureItem{}
	item.Unmarshal(i)

	i.CreatedAt = item.CreatedAt
	i.UpdatedAt = item.UpdatedAt
	i.CityGML = valueToAssetURL(item.FieldByKey("citygml").GetValue())
	i.Data = valueToAssetURLs(item.FieldByKey("data").GetValue())
	i.MaxLOD = valueToAssetURL(item.FieldByKey("maxlod").GetValue())
	for ind, d := range i.Items {
		i.Items[ind].Data = valueToAssetURLs(item.FieldByKeyAndGroup("data", d.ID).GetValue())
	}
	if i.FeatureType != "" {
		// e.g. "建築物モデル（bldg）" -> Name="建築物モデル", FeatureType="bldg"
		if _, ft := getLastBracketContent(i.FeatureType); ft != "" {
			i.FeatureType = ft
		}
	} else {
		i.FeatureType = code
	}

	return
}

type StringOrNumber struct {
	Value string
}

func (s *StringOrNumber) UnmarshalJSON(b []byte) error {
	var str string
	if err := json.Unmarshal(b, &str); err == nil {
		s.Value = str
		return nil
	}

	var in int
	if err := json.Unmarshal(b, &in); err == nil {
		s.Value = fmt.Sprintf("%d", in)
		return nil
	}

	var num float64
	if err := json.Unmarshal(b, &num); err == nil {
		s.Value = fmt.Sprintf("%f", num)
		return nil
	}

	return nil
}

func (s *StringOrNumber) String() string {
	if s == nil {
		return ""
	}
	return s.Value
}

type GenericItem struct {
	ID          string               `json:"id,omitempty" cms:"id"`
	City        string               `json:"city,omitempty" cms:"city,reference"`
	Name        string               `json:"name,omitempty" cms:"name,text"`
	Desc        string               `json:"desc,omitempty" cms:"desc,textarea"`
	Type        string               `json:"type,omitempty" cms:"type,text"`
	TypeEn      string               `json:"type_en,omitempty" cms:"type_en,text"`
	Items       []GenericItemDataset `json:"items,omitempty" cms:"items,group"`
	OpenDataURL string               `json:"open_data_url,omitempty" cms:"open_data_url,url"`
	Category    string               `json:"category,omitempty" cms:"category,select"`
	Group       string               `json:"group,omitempty" cms:"group,text"`
	// metadata
	Status *cms.Tag `json:"status,omitempty" cms:"status,select,metadata"`
	Public bool     `json:"public,omitempty" cms:"public,bool,metadata"`
	AR     bool     `json:"ar,omitempty" cms:"ar,bool,metadata"`
	// common
	CreatedAt time.Time `json:"created_at,omitempty" cms:"-"`
	UpdatedAt time.Time `json:"updated_at,omitempty" cms:"-"`
}

func (c *GenericItem) Stage() stage {
	if c.Public {
		return stageGA
	}
	if c.Status != nil && c.Status.Name == string(ManagementStatusReady) {
		return stageBeta
	}
	return stageAlpha
}

type GenericItemDataset struct {
	ID         string `json:"id,omitempty" cms:"id"`
	Name       string `json:"name,omitempty" cms:"item_name,text"`
	Data       string `json:"data,omitempty" cms:"data,-"`
	Desc       string `json:"desc,omitempty" cms:"desc,textarea"`
	DataURL    string `json:"url,omitempty" cms:"url,url"`
	DataFormat string `json:"format,omitempty" cms:"format,select"`
	LayerName  string `json:"layer,omitempty" cms:"layer,text"`
}

func GenericItemFrom(item *cms.Item) (i *GenericItem) {
	i = &GenericItem{}
	item.Unmarshal(i)

	i.CreatedAt = item.CreatedAt
	i.UpdatedAt = item.UpdatedAt

	for ind, d := range i.Items {
		i.Items[ind].Data = valueToAssetURL(item.FieldByKeyAndGroup("data", d.ID).GetValue())
	}
	return
}

type RelatedItem struct {
	ID    string                      `json:"id,omitempty" cms:"id"`
	City  string                      `json:"city,omitempty" cms:"city,reference"`
	Items map[string]RelatedItemDatum `json:"items,omitempty" cms:"-"`
	// meadata
	Merged string   `json:"merged,omitempty" cms:"merged,asset"`
	Status *cms.Tag `json:"status,omitempty" cms:"status,select,metadata"`
	// common
	CreatedAt time.Time `json:"created_at,omitempty" cms:"-"`
	UpdatedAt time.Time `json:"updated_at,omitempty" cms:"-"`
}

type RelatedItemDatum struct {
	ID          string   `json:"id,omitempty" cms:"id"`
	Asset       []string `json:"asset,omitempty" cms:"asset,asset"`
	Converted   []string `json:"converted,omitempty" cms:"converted,asset"`
	Description string   `json:"description,omitempty" cms:"description,textarea"`
}

func RelatedItemFrom(item *cms.Item, featureTypes []FeatureType) (i *RelatedItem) {
	i = &RelatedItem{}
	item.Unmarshal(i)

	i.CreatedAt = item.CreatedAt
	i.UpdatedAt = item.UpdatedAt

	if i.Items == nil {
		i.Items = map[string]RelatedItemDatum{}
	}

	for _, t := range featureTypes {
		g := item.FieldByKey(t.Code).GetValue().String()
		if g == nil {
			continue
		}

		if group := item.Group(*g); group != nil && len(group.Fields) > 0 {
			i.Items[t.Code] = RelatedItemDatum{
				ID:          group.ID,
				Asset:       valueToAssetURLs(group.FieldByKey("asset").GetValue()),
				Converted:   valueToAssetURLs(group.FieldByKey("conv").GetValue()),
				Description: lo.FromPtr(group.FieldByKey("description").GetValue().String()),
			}
		}
	}

	return
}

func valueToAssetURL(v *cms.Value) string {
	return anyToAssetURL(v.Interface())
}

func valueToAssetURLs(v *cms.Value) (res []string) {
	i := v.Interface()
	if i == nil {
		return
	}

	values := []any{}
	if s, ok := i.([]any); ok {
		values = s
	} else {
		values = append(values, i)
	}

	for _, v := range values {
		if url := anyToAssetURL(v); url != "" {
			res = append(res, url)
		}
	}

	return
}

func anyToAssetURL(v any) string {
	if v == nil {
		return ""
	}

	m, ok := v.(map[string]any)
	if !ok {
		m2, ok := v.(map[any]any)
		if !ok {
			return ""
		}

		m = map[string]interface{}{}
		for k, v := range m2 {
			if s, ok := k.(string); ok {
				m[s] = v
			}
		}
	}

	url, ok := m["url"].(string)
	if !ok {
		return ""
	}

	return url
}

func geospatialjpURL(cityCode string, cityName string, year int) string {
	if cityCode == "" || cityName == "" || year == 0 {
		return ""
	}
	return fmt.Sprintf("%splateau-%s-%s-%d", gespatialjpDatasetURL, cityCode, cityName, year)
}

type GeospatialjpDataItem struct {
	ID       string `json:"id,omitempty" cms:"id"`
	City     string `json:"city,omitempty" cms:"city,reference"`
	CityGML  string `json:"citygml,omitempty" cms:"citygml,asset"`
	MaxLOD   string `json:"maxlod,omitempty" cms:"maxlod,asset"`
	HasIndex bool   `json:"has_index,omitempty" cms:"-"`
}

func GeospatialjpDataItemFrom(item *cms.Item) *GeospatialjpDataItem {
	type itemType struct {
		ID      string `json:"id,omitempty" cms:"id"`
		City    string `json:"city,omitempty" cms:"city,reference"`
		CityGML any    `json:"citygml,omitempty" cms:"citygml,asset"`
		MaxLOD  any    `json:"maxlod,omitempty" cms:"maxlod,asset"`
		Index   string `json:"desc_index,omitempty" cms:"desc_index,markdown"`
	}

	it := itemType{}
	item.Unmarshal(&it)

	citygml := anyToAssetURL(it.CityGML)
	maxlod := anyToAssetURL(it.MaxLOD)

	return &GeospatialjpDataItem{
		ID:       it.ID,
		City:     it.City,
		CityGML:  citygml,
		MaxLOD:   maxlod,
		HasIndex: it.Index != "",
	}
}
