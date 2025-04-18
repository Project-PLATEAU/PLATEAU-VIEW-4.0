package main

import (
	"fmt"
	"os"

	"github.com/eukarya-inc/reearth-plateauview/server/citygml"
	"github.com/eukarya-inc/reearth-plateauview/server/cmsintegration"
	"github.com/eukarya-inc/reearth-plateauview/server/datacatalog"
	"github.com/eukarya-inc/reearth-plateauview/server/opinion"
	"github.com/eukarya-inc/reearth-plateauview/server/plateaucms"
	"github.com/eukarya-inc/reearth-plateauview/server/sdkapi/sdkapiv3"
	"github.com/eukarya-inc/reearth-plateauview/server/searchindex"
	"github.com/eukarya-inc/reearth-plateauview/server/sidebar"
	"github.com/eukarya-inc/reearth-plateauview/server/tiles"
	"github.com/joho/godotenv"
	"github.com/k0kubun/pp/v3"
	"github.com/kelseyhightower/envconfig"
	"github.com/reearth/reearthx/log"
)

const citygmlPackerImageDefault = "ghcr.io/eukarya-inc/plateau-view/plateauview-api-worker:latest"

var noColorPP *pp.PrettyPrinter

func init() {
	noColorPP = pp.New()
	noColorPP.SetColoringEnabled(false)
}

const configPrefix = "REEARTH_PLATEAUVIEW"

type Config struct {
	Port                               uint     `default:"8080" envconfig:"PORT"`
	Host                               string   `default:"http://localhost:8080"`
	GOOGLE_CLOUD_PROJECT               string   `envconfig:"GOOGLE_CLOUD_PROJECT" pp:",omitempty"`
	GOOGLE_CLOUD_REGION                string   `envconfig:"GOOGLE_CLOUD_REGION" pp:",omitempty"`
	Debug                              bool     `pp:",omitempty"`
	Origin                             []string `pp:",omitempty"`
	Secret                             string   `pp:",omitempty"`
	Delegate_URL                       string   `pp:",omitempty"`
	CMS_Webhook_Secret                 string   `pp:",omitempty"`
	CMS_BaseURL                        string   `pp:",omitempty"`
	CMS_Token                          string   `pp:",omitempty"`
	CMS_IntegrationID                  string   `pp:",omitempty"`
	CMS_PlateauProject                 string   `pp:",omitempty"`
	CMS_SystemProject                  string   `pp:",omitempty"`
	CMS_TokenProject                   string   `pp:",omitempty"`
	FME_BaseURL                        string   `pp:",omitempty"`
	FME_BaseURL_V2                     string   `pp:",omitempty"`
	FME_URL_V3                         string   `pp:",omitempty"`
	FME_Mock                           bool     `pp:",omitempty"`
	FME_Token                          string   `pp:",omitempty"`
	FME_SkipQualityCheck               bool     `pp:",omitempty"`
	Ckan_BaseURL                       string   `pp:",omitempty"`
	Ckan_Org                           string   `pp:",omitempty"`
	Ckan_Token                         string   `pp:",omitempty"`
	Ckan_Private                       bool     `pp:",omitempty"`
	SDK_Token                          string   `pp:",omitempty"`
	SendGrid_APIKey                    string   `pp:",omitempty"`
	Opinion_From                       string   `pp:",omitempty"`
	Opinion_FromName                   string   `pp:",omitempty"`
	Opinion_To                         string   `pp:",omitempty"`
	Opinion_ToName                     string   `pp:",omitempty"`
	Sidebar_Token                      string   `pp:",omitempty"`
	Share_Disable                      bool     `pp:",omitempty"`
	CMSINT_TaskImage                   string   `pp:",omitempty"`
	Geospatialjp_Publication_Disable   bool     `pp:",omitempty"`
	Geospatialjp_CatalocCheck_Disable  bool     `pp:",omitempty"`
	Geospatialjp_BuildType             string   `pp:",omitempty"`
	Geospatialjp_JobName               string   `pp:",omitempty"`
	Geospatialjp_CloudBuildImage       string   `pp:",omitempty"`
	Geospatialjp_CloudBuildMachineType string   `pp:",omitempty"`
	Geospatialjp_CloudBuildProject     string   `pp:",omitempty"`
	Geospatialjp_CloudBuildRegion      string   `pp:",omitempty"`
	Geospatialjp_CloudBuildDiskSizeGb  int64    `pp:",omitempty"`
	DataConv_Disable                   bool     `pp:",omitempty"`
	Indexer_Delegate                   bool     `pp:",omitempty"`
	DataCatalog_DisableCache           bool     `pp:",omitempty"`
	DataCatalog_CacheUpdateKey         string   `pp:",omitempty"`
	DataCatalog_PlaygroundEndpoint     string   `pp:",omitempty"`
	DataCatalog_CacheTTL               int      `pp:",omitempty"`
	DataCatalog_GQL_MaxComplexity      int      `pp:",omitempty"`
	DataCatalog_PanicOnInit            bool     `pp:",omitempty"`
	DataCatalog_GeocodingAppID         string   `pp:",omitempty"`
	DataCatalog_DiskCache              bool     `pp:",omitempty"`
	DataCatalog_Debug                  bool     `pp:",omitempty"`
	GCParcent                          int      `pp:",omitempty"`
	CityGML_Domain                     string   `pp:",omitempty"`
	CityGML_Bucket                     string   `pp:",omitempty"`
	CityGML_CityGMLPackerImage         string   `pp:",omitempty"`
	CityGML_WorkerRegion               string   `pp:",omitempty"`
	CityGML_WorkerProject              string   `pp:",omitempty"`
	CityGML_PackerTimeout              uint     `pp:",omitempty"`
	Flow_BaseURL                       string   `pp:",omitempty"`
	Flow_Token                         string   `pp:",omitempty"`
	Tiles_Cache_Control                string   `pp:",omitempty"`
	Chiitiler_URL                      string   `pp:",omitempty"`
	Chiitiler_Bucket                   string   `pp:",omitempty"`
}

func NewConfig() (*Config, error) {
	if err := godotenv.Load(".env"); err != nil && !os.IsNotExist(err) {
		return nil, err
	} else if err == nil {
		log.Infof("config: .env loaded")
	}

	var c Config
	err := envconfig.Process(configPrefix, &c)

	return &c, err
}

func (c *Config) Print() string {
	return noColorPP.Sprint(c)
}

func (c *Config) LocalURL(path string) string {
	return fmt.Sprintf("http://[::]:%d%s", c.Port, path)
}

func (c *Config) CMSIntegration() cmsintegration.Config {
	cloudBuildProject := c.Geospatialjp_CloudBuildProject
	if cloudBuildProject == "" {
		cloudBuildProject = c.GOOGLE_CLOUD_PROJECT
	}

	cloudBuildRegion := c.Geospatialjp_CloudBuildRegion
	if cloudBuildRegion == "" {
		cloudBuildRegion = c.GOOGLE_CLOUD_REGION
	}

	return cmsintegration.Config{
		Host:                              c.Host,
		FMEMock:                           c.FME_Mock,
		FMEBaseURL:                        c.FME_BaseURL,
		FMEToken:                          c.FME_Token,
		FMEBaseURLV2:                      c.FME_BaseURL_V2,
		FMESkipQualityCheck:               c.FME_SkipQualityCheck,
		CMSBaseURL:                        c.CMS_BaseURL,
		CMSToken:                          c.CMS_Token,
		CMSIntegration:                    c.CMS_IntegrationID,
		CMSSystemProject:                  c.CMS_TokenProject,
		Secret:                            c.Secret,
		Debug:                             c.Debug,
		CkanBaseURL:                       c.Ckan_BaseURL,
		CkanOrg:                           c.Ckan_Org,
		CkanToken:                         c.Ckan_Token,
		CkanPrivate:                       c.Ckan_Private,
		DisableGeospatialjpPublication:    c.Geospatialjp_Publication_Disable,
		DisableGeospatialjpCatalogCheck:   c.Geospatialjp_CatalocCheck_Disable,
		DisableDataConv:                   c.DataConv_Disable,
		APIToken:                          c.Sidebar_Token,
		GeospatialjpBuildType:             c.Geospatialjp_BuildType,
		GeospatialjpCloudRunJobsJobName:   c.Geospatialjp_JobName,
		GeospatialjpCloudBuildMachineType: c.Geospatialjp_CloudBuildMachineType,
		GeospatialjpCloudBuildProject:     cloudBuildProject,
		GeospatialjpCloudBuildRegion:      cloudBuildRegion,
		GeospatialjpCloudBuildDiskSizeGb:  c.Geospatialjp_CloudBuildDiskSizeGb,
		TaskImage:                         c.Geospatialjp_CloudBuildImage, // TODO: change env var name
		GCPProject:                        cloudBuildProject,
		GCPRegion:                         cloudBuildRegion,
		FlowBaseURL:                       c.Flow_BaseURL,
		FlowToken:                         c.Flow_Token,
	}
}

func (c *Config) SearchIndex() searchindex.Config {
	return searchindex.Config{
		CMSBase:           c.CMS_BaseURL,
		CMSToken:          c.CMS_Token,
		CMSStorageProject: c.CMS_SystemProject,
		Delegate:          c.Indexer_Delegate,
		DelegateURL:       c.Delegate_URL,
		Debug:             c.Debug,
		// CMSModel: c.CMS_Model,
		// CMSStorageModel:   c.CMS_IndexerStorageModel,
	}
}

func (c *Config) SDKAPI() sdkapiv3.Config {
	return sdkapiv3.Config{
		DataCatalogAPIURL: c.LocalURL("/datacatalog"),
		Token:             c.SDK_Token,
	}
}

func (c *Config) Opinion() opinion.Config {
	return opinion.Config{
		SendGridAPIKey: c.SendGrid_APIKey,
		From:           c.Opinion_From,
		FromName:       c.Opinion_FromName,
		To:             c.Opinion_To,
		ToName:         c.Opinion_ToName,
	}
}

func (c *Config) Sidebar() sidebar.Config {
	return sidebar.Config{
		Config:       c.plateauCMS(),
		DisableShare: c.Share_Disable,
	}
}

func (c *Config) DataCatalog() datacatalog.Config {
	return datacatalog.Config{
		Config:               c.plateauCMS(),
		CacheUpdateKey:       c.DataCatalog_CacheUpdateKey,
		PlaygroundEndpoint:   c.DataCatalog_PlaygroundEndpoint,
		GraphqlMaxComplexity: c.DataCatalog_GQL_MaxComplexity,
		DisableCache:         c.DataCatalog_DisableCache,
		DiskCache:            c.DataCatalog_DiskCache,
		Debug:                c.DataCatalog_Debug,
		CacheTTL:             c.DataCatalog_CacheTTL,
		ErrorOnInit:          c.DataCatalog_PanicOnInit,
		GeocodingAppID:       c.DataCatalog_GeocodingAppID,
	}
}

func (c *Config) Tiles() tiles.Config {
	return tiles.Config{
		CMS:                  c.plateauCMS(),
		Host:                 c.Host,
		CacheControl:         c.Tiles_Cache_Control,
		ChiitilerURL:         c.Chiitiler_URL,
		ChiitilerCacheBucket: c.Chiitiler_Bucket,
	}
}

func (c *Config) plateauCMS() plateaucms.Config {
	return plateaucms.Config{
		CMSBaseURL:       c.CMS_BaseURL,
		CMSMainToken:     c.CMS_Token,
		CMSSystemProject: c.CMS_TokenProject,
		// compat
		CMSMainProject: c.CMS_SystemProject,
		AdminToken:     c.Sidebar_Token,
	}
}

func (c *Config) CityGML() citygml.Config {
	workRegion := c.CityGML_WorkerRegion
	if workRegion == "" {
		workRegion = c.GOOGLE_CLOUD_REGION
	}
	workProject := c.CityGML_WorkerProject
	if workProject == "" {
		workProject = c.GOOGLE_CLOUD_PROJECT
	}
	citygmlPackerImage := c.CityGML_CityGMLPackerImage
	if citygmlPackerImage == "" {
		citygmlPackerImage = citygmlPackerImageDefault
	}
	return citygml.Config{
		Domain:             c.CityGML_Domain,
		Bucket:             c.CityGML_Bucket,
		CityGMLPackerImage: citygmlPackerImage,
		WorkerRegion:       workRegion,
		WorkerProject:      workProject,
		DataCatalogAPIURL:  c.LocalURL("/datacatalog"),
		PackerTimeout:      c.CityGML_PackerTimeout,
	}
}
