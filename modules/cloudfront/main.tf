resource "aws_route53_record" "cloudfront_record_alias" {
  zone_id = var.cloudfront_hosted_zone_id
  name    = var.domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.amplify_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.amplify_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

locals {
  amplify_origin_id   = "Amplify"
  basic_auth_function = var.is_prd ? [] : [aws_cloudfront_function.basic_auth[0].arn]
}

resource "aws_s3_bucket" "cloudfront_assets_access_logs" {
  bucket = "${var.project_name}-${var.infra_environment}-assets-access-logs"
}

resource "aws_s3_bucket_acl" "cloudfront_assets_access_logs_acl" {
  bucket     = aws_s3_bucket.cloudfront_assets_access_logs.id
  acl        = "log-delivery-write"
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront]
}

resource "aws_s3_bucket_ownership_controls" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront_assets_access_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_cloudfront_distribution" "amplify_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "S3 Static Website Hosting Distribution"
  aliases         = [var.domain]
  web_acl_id      = null
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_assets_access_logs.bucket_regional_domain_name
    prefix          = "cloudfront/"
  }
  origin {
    origin_id   = local.amplify_origin_id
    domain_name = "${var.github_branch_front}.${var.amplify_default_domain}"
    custom_header {
      name  = "Authorization"
      value = "Basic ${var.amplify_auth}"
    }
    custom_origin_config {
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      http_port                = 80
      https_port               = 443
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    cache_policy_id            = var.cache_policy_id
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    response_headers_policy_id = var.response_headers_policy_id
    target_origin_id           = local.amplify_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    dynamic "function_association" {
      for_each = local.basic_auth_function
      content {
        event_type   = "viewer-request"
        function_arn = function_association.value
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
  http_version = "http2"
}

resource "aws_cloudfront_function" "basic_auth" {
  count   = var.is_prd ? 0 : 1
  name    = "${var.project_name}-${var.infra_environment}-basicAuth"
  runtime = "cloudfront-js-1.0"
  comment = "This function is for basic authentication."
  publish = true
  code    = file("${path.module}/basic_auth.js")
}
