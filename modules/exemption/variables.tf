variable name {
  type        = string
  description = "Name for the Policy Exemption"
}

variable display_name {
  type        = string
  description = "Display name for the Policy Exemption"
}

variable description {
  type        = string
  description = "Description for the Policy Exemption"
}

variable scope {
  type        = string
  description = "Scope for the Policy Exemption"
}

variable policy_assignment_id {
  type        = string
  description = "The ID of the policy assignment that is being exempted"
}

variable policy_definition_reference_ids {
  type        = list(any)
  description = "The policy definition reference ID list when the associated policy assignment is an assignment of a policy set definition"
  default     = []
}

variable exemption_category {
  type        = string
  description = "The policy exemption category. Possible values are Waiver or Mitigated. Defaults to Waiver"
  default     = "Waiver"

  validation {
    condition     = var.exemption_category == "Waiver" || var.exemption_category == "Mitigated"
    error_message = "Exemption category possible values are: Waiver or Mitigated."
  }
}

variable expires_on {
  type        = string
  description = "Optional expiration date (format yyyy-mm-dd) of the policy exemption. Defaults to no expiry"
  default     = null
}

variable metadata {
  type        = any
  description = "Optional policy exemption metadata. For example but not limited to; requestedBy, approvedBy, approvedOn, ticketRef, etc"
  default     = {}
}

locals {
  exemption_scope = try({
    mg       = length(regexall("(\\/managementGroups\\/)", var.scope)) > 0 ? 1 : 0,
    sub      = length(split("/", var.scope)) == 3 ? 1 : 0,
    rg       = length(regexall("(\\/managementGroups\\/)", var.scope)) < 1 ? length(split("/", var.scope)) == 5 ? 1 : 0 : 0,
    resource = length(split("/", var.scope)) >= 6 ? 1 : 0,
  })

  expires_on = var.expires_on != null ? "${var.expires_on}T23:00:00Z" : null

  exemption_id = try(
    azurerm_management_group_policy_exemption.management_group_exemption[0].id,
    azurerm_subscription_policy_exemption.subscription_exemption[0].id,
    azurerm_resource_group_policy_exemption.resource_group_exemption[0].id,
    azurerm_resource_policy_exemption.resource_exemption[0].id,
  "")
}
