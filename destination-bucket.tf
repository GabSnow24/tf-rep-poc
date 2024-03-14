resource "aws_s3_bucket" "dest-bucket" {
  provider = aws.destination
  bucket   = "dst.bucket.test-cheddar-v2"
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  provider = aws.destination
  bucket   = aws_s3_bucket.dest-bucket.id
  policy   = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication-role.arn]
    }
    sid = "Set-permissions-for-objects"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
    ]
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.dest-bucket.arn}/*",
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication-role.arn]
    }
    sid = "Set permissions on bucket"
    actions = [
      "s3:List*",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
    ]
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.dest-bucket.arn}",
    ]
  }
}

resource "aws_s3_bucket_versioning" "dest-bucket-versioning" {
  provider = aws.destination
  bucket   = aws_s3_bucket.dest-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dest-bucket-sse" {
  provider = aws.destination
  bucket   = aws_s3_bucket.dest-bucket.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "dest-bucket-ownership" {
  provider = aws.destination
  bucket   = aws_s3_bucket.dest-bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# ####### import block #########
# import {
#   to = aws_s3_bucket.dest-dassan-bucket
#   id = "dst.bucket.test.dassan"
# }

# import {
#   to = aws_s3_bucket_server_side_encryption_configuration.dest-dassan-bucket-sse
#   id = "dst.bucket.test.dassan"
# }

# import {
#   to = aws_s3_bucket_versioning.dest-dassan-bucket-versioning
#   id = "dst.bucket.test.dassan"
# }

# import {
#   to = aws_s3_bucket_ownership_controls.dest-dassan-bucket-ownership
#   id = "dst.bucket.test.dassan"
# }

# import {
#   to = aws_s3_bucket_acl.dest-dassan-bucket-acl
#   id = "dst.bucket.test.dassan"
# }

# import {
#   to = aws_s3_bucket_policy.allow_access_from_another_account
#   id = "dst.bucket.test.dassan"
# }