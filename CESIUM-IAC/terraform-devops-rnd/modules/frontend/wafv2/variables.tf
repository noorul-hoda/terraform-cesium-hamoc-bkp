//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//WAF Variables

variable "region" {
  type        = string
  description = "default aws region to deploy the resources"
}

variable "profile" {
  type        = string
  description = "Your different aws configuration profile to separate the aws account"
}

variable "environment" {
  type        = string
  description = "Application different environment like dev/qa/prod"
}

variable "project" {
  type        = string
  description = "Your project name"
}

variable "owner" {
  type        = string
  description = "Owner of the terraform modules"
}

#------------------------------------------
# WAFv2 variables
//variable "scope" {
//  type = string
//  description = "IP Set scope. CLOUDFRONT or REGIONAL"
//  default = "CLOUDFRONT"
//}
variable "whitelist_ips" {
  description = "List of embargoed IPs by type"
  type        = map(list(string))
  default = {
    "IPV4" = ["1.2.3.4/16"] #My ip addresses
    //    "IPv6" = []
  }
}

variable "managed_rules" {
  type = list(object({
    name            = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
  description = "List of Managed WAF rules."
  default = [
    {
      name            = "AWSManagedRulesCommonRuleSet",
      priority        = 10
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList",
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet",
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesSQLiRuleSet",
      priority        = 40
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesLinuxRuleSet",
      priority        = 50
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesUnixRuleSet",
      priority        = 60
      override_action = "none"
      excluded_rules  = []
    }
  ]
}

variable "cf_whitelist_ipv4-list" {
  type = list(any)
  description = "Cloudfront Whitelist IPV4 List in x.x.x.x/x format"
}

variable "cf_whitelist_ipv6-list" {
  type = list(any)
  description = "Cloudfront Whitelist IPV6 List in x:x:x:x:x:x:x:x:x/x format"
}

variable "cf_blacklist_ipv4-list" {
  type = list(any)
  description = "Cloudfront Blacklist IPV4 List in x.x.x.x/x format"
}

variable "cf_blacklist_ipv6-list" {
  type = list(any)
  description = "Cloudfront Blacklist IPV6 List in x:x:x:x:x:x:x:x:x/x format"  
}