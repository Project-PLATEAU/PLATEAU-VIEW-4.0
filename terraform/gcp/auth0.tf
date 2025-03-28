locals {
  action_binding = [
    {
      id   = module.auth0_cms.action_signup[0].id,
      name = module.auth0_cms.action_signup[0].name
    }
  ]

}

resource "auth0_trigger_binding" "login" {
  trigger = "post-user-registration"
  dynamic "actions" {
    for_each = local.action_binding
    content {
      id           = actions.value.id
      display_name = actions.value.name
    }
  }
}


module "auth0_cms" {
  source = "./modules/auth0"

  spa_name                   = "plateau-reearth-spa"
  m2m_name                   = "plateau-reearth-m2m"
  login_domain               = local.cms_domain
  identifier_domain          = local.cms_api_domain
  require_post_signup_action = true
  signup_name                = "signup-backend"
}

module "auth0_editor" {
  source = "./modules/auth0"

  spa_name          = "plateau-editor-spa"
  m2m_name          = "plateau-editor-m2m"
  login_domain      = local.editor_domain
  identifier_domain = local.editor_api_domain
  signup_name       = "signup-reearth"
}

module "auth0_flow" {
  source = "./modules/auth0"

  spa_name          = "plateau-flow-spa"
  m2m_name          = "plateau-flow-m2m"
  login_domain      = local.flow_domain
  identifier_domain = local.flow_api_domain
  signup_name       = "signup-reearth"
}
