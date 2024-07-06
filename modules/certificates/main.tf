terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.43"
      configuration_aliases = [aws.default, aws.global_region]
    }
  }
}

resource "aws_acm_certificate" "cloudfront_cert" {
  provider          = aws.global_region //US-EAST-1
  domain_name       = var.domain
  validation_method = "DNS"
  validation_option {
    domain_name       = var.domain
    validation_domain = var.zone_id
  }
  subject_alternative_names = ["*.${var.domain}"]
  tags = {
    ProjectName = var.project_name
    Environment = var.infra_environment
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cloudfront_cert" {
  provider        = aws.global_region //US-EAST-1
  certificate_arn = aws_acm_certificate.cloudfront_cert.arn
  timeouts {
    create = "3m"
  }
}

resource "aws_acm_certificate" "alb_cert" {
  provider                  = aws.default
  domain_name               = var.domain
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain}"]
  tags = {
    ProjectName = var.project_name
    Environment = var.infra_environment
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "alb_cert" {
  provider                = aws.default
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_record : record.fqdn]
  timeouts {
    create = "3m"
  }
}

resource "aws_route53_record" "alb_record" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.cloudfront_hosted_zone_id
}
