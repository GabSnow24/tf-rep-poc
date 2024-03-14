resource "aws_s3_bucket" "src-bucket" {
  provider            = aws
  bucket              = "src.bucket.test-cheddar-v2"
  object_lock_enabled = false
}

resource "aws_s3_bucket_versioning" "src-bucket-versioning" {
  provider = aws
  bucket   = aws_s3_bucket.src-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "src-bucket-sse" {
  provider = aws
  bucket   = aws_s3_bucket.src-bucket.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "src-bucket-ownership" {
  provider = aws
  bucket   = aws_s3_bucket.src-bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_replication_configuration" "src-bucket-replication" {
  provider = aws
  role     = aws_iam_role.replication-role.arn
  bucket   = aws_s3_bucket.src-bucket.id
  rule {
    id = "replicateToNewAccount"

    priority = 0
    status   = "Enabled"
    destination {
      account = data.aws_caller_identity.destination.account_id
      bucket  = aws_s3_bucket.dest-bucket.arn
    }
  }
}

# resource "aws_s3_bucket_acl" "src-bucket-acl" {
#   provider = aws
#   bucket   = aws_s3_bucket.src-bucket.id
#   access_control_policy {
#     grant {
#       permission = "FULL_CONTROL"
#       grantee {
#         id   = "6a3ca4db01d4a5c3c3cecbc39fbec59b5a96cd77e03d76eb15a99740558e3163"
#         type = "CanonicalUser"
#       }
#     }
#     owner {
#       id = "6a3ca4db01d4a5c3c3cecbc39fbec59b5a96cd77e03d76eb15a99740558e3163"
#     }
#   }
  
# }


# ####### import block #########
# import {
#   to = aws_s3_bucket.src-dassan-bucket
#   id = "src.bucket.test.dassan"
# }

# import {
#   to = aws_s3_bucket_ownership_controls.src-dassan-bucket-ownership
#   id = "src.bucket.test.dassan"
# }

# import {
#   to = aws_s3_bucket_acl.src-dassan-bucket-acl
#   id = "src.bucket.test.dassan"
# }

# # import {
# #   to = aws_s3_bucket_replication_configuration.src-dassan-bucket-replication
# #   id = "src.bucket.test.dassan"
# # }

# import {
#   to = aws_iam_role.dassan-replication-role
#   id = "s3crr_role_for_src.bucket.test.dassan"
# }

# import {
#   to = aws_s3_bucket_server_side_encryption_configuration.src-dassan-bucket-sse
#   id = "src.bucket.test.dassan"
# }

# import {
#   to = aws_s3_bucket_versioning.src-dassan-bucket-versioning
#   id = "src.bucket.test.dassan"
# }