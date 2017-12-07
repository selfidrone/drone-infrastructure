resource "aws_s3_bucket" "bucket" {
  bucket = "images.demo.gs"
  acl    = "public-read"

  force_destroy = true

  tags {
    Name        = "SelfiDroneBucket"
    Environment = "Dev"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

output "bucket_domain_name" {
  value = "${aws_s3_bucket.bucket.bucket_domain_name}"
}

output "website_endpoint" {
  value = "${aws_s3_bucket.bucket.website_endpoint}"
}
