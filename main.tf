# Create CloudFront Distribution
locals {
  allowed_methods                    = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
  cached_methods                     = ["GET", "HEAD"]
  tls_minimum                        = var.tls_minimum
  min_ttl                            = 60
  default_ttl                        = 3600
  max_ttl                            = 86400
  origin_connection_attempts         = 2
  origin_connection_timeout          = 3
  origin_response_completion_timeout = 0
  origin_ssl_protocols               = ["TLSv1", "TLSv1.2"]
}
module "cloudfront" {
  source          = "terraform-aws-modules/cloudfront/aws"
  aliases         = toset(var.domain_names)
  comment         = null
  price_class     = var.price_class
  is_ipv6_enabled = false
  http_version    = "http2"
  restrictions = {
    geo_restriction = { restriction_type = "blacklist", locations = ["IR", "KP"] }
  }
  default_root_object = "index.html"
  viewer_certificate = {
    acm_certificate_arn      = var.ssl_cert
    ssl_support_method       = "sni-only"
    minimum_protocol_version = local.tls_minimum
  }
  origin_access_control = {
    s3_oac = {
      name             = "cloudfront-${var.name}"
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
  #  logging_config = {
  #    bucket = "logs-my-cdn.s3.amazonaws.com"
  #  }
  origin = { for k, v in var.origins :
    k => {
      origin_id                   = k
      domain_name                 = v["bucket_name"] != null ? "${v["bucket_name"]}.s3.amazonaws.com" : v["dns_name"]
      origin_path                 = v.path
      connection_attempts         = local.origin_connection_attempts
      connection_timeout          = local.origin_connection_timeout
      response_completion_timeout = local.origin_response_completion_timeout
      custom_origin_config = {
        http_port              = coalesce(v.port, 80)
        https_port             = coalesce(v.port, 443)
        origin_protocol_policy = coalesce(lookup(v, "protocol", "https") == "http" ? "http-only" : null, "match-viewer")
        origin_ssl_protocols   = local.origin_ssl_protocols
      }
    }
  }
  default_cache_behavior = {
    target_origin_id       = var.default_origin
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = local.allowed_methods
    cached_methods         = local.cached_methods
    compress               = false
    min_ttl                = local.min_ttl
    default_ttl            = local.default_ttl
    max_ttl                = local.max_ttl
    forwarded_values = {
      query_string = true
      cookies = {
        forward = "all"
      }
    }
  }
  ordered_cache_behavior = flatten([for i, v in var.behaviors :
    [for path in v.paths :
      {
        path_pattern           = path
        target_origin_id       = v.origin
        viewer_protocol_policy = "allow-all"
        compress               = false
        allowed_methods        = coalesce(v.allowed_methods, local.allowed_methods)
        cached_methods         = coalesce(v.cached_methods, local.cached_methods)
        min_ttl                = coalesce(v.min_ttl, local.min_ttl)
        max_ttl                = coalesce(v.max_ttl, local.max_ttl)
        default_ttl            = coalesce(v.default_ttl, local.default_ttl)
        forwarded_values = {
          query_string = true
          cookies      = {}
        }
      }
    ]
  ])
}

# Lookup Zone ID using Domain Name, if provided
data "aws_route53_zone" "default" {
  count        = var.dns_zone_name != "" ? 1 : 0
  name         = lower(trimspace(endswith(var.dns_zone_name, ".") ? var.dns_zone_name : "${var.dns_zone_name}."))
  private_zone = false
}

# Create CNAME in Route 53
module "route53_cname" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"
  zone_id = coalesce(
    var.dns_zone_name != "" ? one(data.aws_route53_zone.default).zone_id : null,
    var.dns_zone_id
  )
  records = [
    {
      full_name_override = true
      name               = var.name
      ttl                = var.dns_ttl
      type               = "CNAME"
      records            = [module.cloudfront.cloudfront_distribution_domain_name]
      allow_overwrite    = true
    }
  ]
}


moved {
  from = module.cloudfront.aws_cloudfront_distribution.default
  to   = module.cloudfront.aws_cloudfront_distribution.this[0]
}

moved {
  from = module.route53_records.aws_route53_record.this
  to   = module.route53_cname.aws_route53_record.this
}

