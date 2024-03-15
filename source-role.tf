data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com", "batchoperations.s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication-role" {
  name                  = "s3crr_role_for_src.${aws_s3_bucket.src-bucket.id}"
  assume_role_policy    = data.aws_iam_policy_document.assume_role.json
  force_detach_policies = false
  path                  = "/service-role/"
  tags                  = {}
  tags_all              = {}
}


data "aws_iam_policy_document" "replication" {
  provider = aws
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetReplicationConfiguration",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectRetention",
      "s3:GetObjectLegalHold"
    ]

    resources = [
      aws_s3_bucket.src-bucket.arn,
      "${aws_s3_bucket.src-bucket.arn}/*",
      aws_s3_bucket.dest-bucket.arn,
      "${aws_s3_bucket.dest-bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:InitiateReplication"
    ]
    resources = [
      "${aws_s3_bucket.src-bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:PutInventoryConfiguration"

    ]
    resources = [
      aws_s3_bucket.src-bucket.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::dev-replication-reports/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]

    resources = [
      "${aws_s3_bucket.src-bucket.arn}/*",
      "${aws_s3_bucket.dest-bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "replication" {
  provider = aws
  name     = "s3crr_policy_for_src.${aws_s3_bucket.src-bucket.id}"
  policy   = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  provider   = aws
  role       = aws_iam_role.replication-role.name
  policy_arn = aws_iam_policy.replication.arn
}
