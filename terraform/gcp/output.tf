output "plateauview_cms_url" {
  value = "https://${local.cms_domain}"
}

output "plateauview_cms_webhook_url" {
  value = "https://api.${var.domain}/webhook"
}

output "plateauview_cms_webhook_secret" {
  value     = module.plateauview_api.plateauview_cms_webhook_secret
  sensitive = true
}

output "plateauview_editor_url" {
  value = "https://${local.editor_domain}"
}

output "plateauview_flow_token" {
  value     = module.plateauview_api.plateauview_flow_token
  sensitive = true
}

output "plateauview_flow_url" {
  value = "https://${local.flow_domain}"
}

output "plateauview_geo_url" {
  value = "https://${local.geo_domain}"
}

output "plateauview_sdk_token" {
  value     = module.plateauview_api.plateauview_sdk_token
  sensitive = true
}

output "plateauview_setup_token" {
  value     = module.plateauview_api.plateauview_setup_token
  sensitive = true
}


output "plateauview_sidebar_token" {
  value     = module.plateauview_api.plateauview_sidebar_token
  sensitive = true
}

output "plateauview_sidecar_url" {
  value = "https://${local.cms_api_domain}"
}
