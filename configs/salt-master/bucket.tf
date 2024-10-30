resource "aws_s3_bucket" "salt" {
  bucket = "${format("%s-%s-salt-%s", var.ORG, terraform.workspace, data.aws_region.current.name)}"
  acl = "private"
  tags {
    Name = "${format("%s-%s-salt-%s", var.ORG, terraform.workspace, data.aws_region.current.name)}"
    Environment = "${terraform.workspace}"
    Purpose = "salt"
  }
}

resource "aws_s3_bucket_object" "private_key" {
  bucket = "${aws_s3_bucket.salt.bucket}"
  key = "master/master.pem"
  source = "keys/master.pem"
}

resource "aws_s3_bucket_object" "public_key" {
  bucket = "${aws_s3_bucket.salt.bucket}"
  key = "master/master.pub"
  source = "keys/master.pub"
}

resource "aws_s3_bucket_object" "master_finger" {
  bucket = "${aws_s3_bucket.salt.bucket}"
  key = "public/master.finger"
  source = "keys/master.finger"
}

resource "aws_s3_bucket_object" "gitfs_privkey" {
  count = "${var.GITFS_BACKEND == "true" ? 1 : 0 }"
  bucket = "${aws_s3_bucket.salt.bucket}"
  key = "master/gitfs.pem"
  source = "keys/gitfs.pem"
}
  
resource "aws_s3_bucket_object" "gitfs_pubkey" {
  count = "${var.GITFS_BACKEND == "true" ? 1 : 0 }"
  bucket = "${aws_s3_bucket.salt.bucket}"
  key = "master/gitfs.pub"
  source = "keys/gitfs.pub" }

output "bucket_name" {
  value = "${aws_s3_bucket.salt.bucket}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.salt.arn}"
}
