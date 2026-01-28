resource "aws_s3_bucket" "static_site_styve" {
  bucket = "tp-terraform-site-statique-mich"

  tags = {
    Name        = "TP Terraform Site Statique"
    Environment = "TP"
  }
}

resource "aws_s3_bucket_website_configuration" "static_site_website" {
  bucket = aws_s3_bucket.static_site_styve.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.static_site_styve.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.static_site_styve.id

  depends_on = [
    aws_s3_bucket_public_access_block.public_access
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site_styve.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.static_site_styve.id
  key          = "index.html"
  source       = "site/index.html"
  content_type = "text/html"

  depends_on = [
    aws_s3_bucket_policy.public_policy
  ]
}


