provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }
}

# resource "random_string" "test" {
#   length           = 16
#   special          = true
#   upper            = true
#   lower            = true
#   number           = true
#   min_numeric      = 0
#   min_upper        = 0
#   min_lower        = 0
#   min_special      = 0
#   override_special = ""
# }

resource "random_string" "random" { 
    length = 6
    special = false
    upper = false
}

resource "aws_s3_bucket" "my_bucket" { 
    bucket = "rumothy-hw-bucket-v${random_string.random.result}"
}

resource "aws_s3_bucket_public_access_block" "site" { 
    bucket = aws_s3_bucket.my_bucket.id
 
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    bucket_key_enabled = true
  }
}



resource "aws_s3_bucket_website_configuration" "site" { 
    bucket = aws_s3_bucket.my_bucket.id   

    index_document { 
        suffix = "index.html"
    }
    
    error_document { 
        key = "error.html"
    }
}

resource "aws_s3_bucket_ownership_controls" "site" { 
    bucket = aws_s3_bucket.my_bucket.id
    rule { 
        object_ownership = "BucketOwnerPreferred"
    }
}


# resource "aws_s3_object" "upload_object" { 
#     for_each = fileset("html/", "*")
#     bucket = aws_s3_bucket.my_bucket.id
#     key = each.value
#     source = "html/$each.value}"
#     etag = filemd5("html/${each.value}")
#     content_type = "text/html"
# } 

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "index.html"
  source = "html/index.html"
  etag = filemd5("html/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "coffee_jpg" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "coffee.jpg"
  source = "html/coffee.jpg"
  etag = filemd5("html/coffee.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "error.html"
  source = "html/error.html"
  etag = filemd5("html/error.html")
  content_type = "text/html"
}

resource "aws_s3_object" "beach_jpg" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "beach.jpg"
  source = "html/beach.jpg"
  etag = filemd5("html/beach.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_bucket_policy" "allow_site_access" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Policy${random_string.random.result}"
    Statement = [
      {
        Sid       = "Stmt1705787${random_string.random.result}"
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.my_bucket.arn,
          "${aws_s3_bucket.my_bucket.arn}/*",
        ]
      },
    ]
  })
}

# data "aws_iam_policy_document" "allow_access_from_another_account" {
#   statement {
#     principals {
#       type        = "AWS"
#       identifiers = ["123456789012"]
#     }

#     actions = [
#       "s3:GetObject",
#       "s3:ListBucket",
#     ]

#     resources = [
#       aws_s3_bucket.my_bucket.arn,
#       "${aws_s3_bucket.my_bucket.arn}/*",
#     ]
#   }
# }