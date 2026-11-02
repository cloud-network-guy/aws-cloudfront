variable "name" {
  description = "Short name for this CloudFront distribution"
  type        = string
  default     = "cloudfront"
}

variable "dns_zone_name" {
  description = "DNS Zone Name to create CNAME in"
  type        = string
  default     = ""
}

variable "dns_zone_id" {
  description = "DNS Zone ID to create CNAME in"
  type        = string
  default     = null
}


variable "dns_ttl" {
  description = "DNS TTL value for CNAME"
  type        = number
  default     = 300
}

variable "domain_names" {
  type        = list(string)
  description = "List of do"
}

variable "ssl_cert" {
  type        = string
  description = "ARN of SSL Certificate"
}

variable "tls_minimum" {
  type    = string
  default = "TLSv1.2_2025"
}
variable "price_class" {
  type    = string
  default = "PriceClass_100"
}
variable "origins" {
  description = "List of Origins for this Distribution"
  type = map(object({
    dns_name            = optional(string)
    port                = optional(number)
    protocol            = optional(string)
    tls_version         = optional(number)
    bucket_name         = optional(string)
    path                = optional(string)
    include_host_header = optional(bool)
  }))
  default = {
    default = {
      port        = 443
      protocol    = "https"
      tls_version = 1.2
    }
  }
}

variable "behaviors" {
  description = "List of paths to route to each non-default origin"
  type = list(object({
    paths           = list(string)
    origin          = string
    allowed_methods = optional(list(string))
    cached_methods  = optional(list(string))
    min_ttl         = optional(number)
    default_ttl     = optional(number)
    max_ttl         = optional(number)
  }))
  default = []
}

variable "default_origin" {
  description = "Origin ID for traffic that doesn't match specific policy"
  type        = string
}

variable "include_host_header" {
  description = "Include host header when passing to all non-S3 origins"
  type        = bool
  default     = false
}
