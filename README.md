<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.71.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | terraform-aws-modules/cloudfront/aws | n/a |
| <a name="module_route53_cname"></a> [route53\_cname](#module\_route53\_cname) | terraform-aws-modules/route53/aws//modules/records | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_behaviors"></a> [behaviors](#input\_behaviors) | List of paths to route to each non-default origin | <pre>list(object({<br/>    paths           = list(string)<br/>    origin          = string<br/>    allowed_methods = optional(list(string))<br/>    cached_methods  = optional(list(string))<br/>    min_ttl         = optional(number)<br/>    default_ttl     = optional(number)<br/>    max_ttl         = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_default_origin"></a> [default\_origin](#input\_default\_origin) | Origin ID for traffic that doesn't match specific policy | `string` | n/a | yes |
| <a name="input_dns_ttl"></a> [dns\_ttl](#input\_dns\_ttl) | DNS TTL value for CNAME | `number` | `300` | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | DNS Zone ID to create CNAME in | `string` | `null` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | DNS Zone Name to create CNAME in | `string` | `""` | no |
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | List of do | `list(string)` | n/a | yes |
| <a name="input_include_host_header"></a> [include\_host\_header](#input\_include\_host\_header) | Include host header when passing to all non-S3 origins | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Short name for this CloudFront distribution | `string` | `"cloudfront"` | no |
| <a name="input_origins"></a> [origins](#input\_origins) | List of Origins for this Distribution | <pre>map(object({<br/>    dns_name            = optional(string)<br/>    port                = optional(number)<br/>    protocol            = optional(string)<br/>    tls_version         = optional(number)<br/>    bucket_name         = optional(string)<br/>    path                = optional(string)<br/>    include_host_header = optional(bool)<br/>  }))</pre> | <pre>{<br/>  "default": {<br/>    "port": 443,<br/>    "protocol": "https",<br/>    "tls_version": 1.2<br/>  }<br/>}</pre> | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | n/a | `string` | `"PriceClass_100"` | no |
| <a name="input_ssl_cert"></a> [ssl\_cert](#input\_ssl\_cert) | ARN of SSL Certificate | `string` | n/a | yes |
| <a name="input_tls_minimum"></a> [tls\_minimum](#input\_tls\_minimum) | n/a | `string` | `"TLSv1.2_2025"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
<!-- END_TF_DOCS -->