resource "aws_iam_policy" "userReadAccess" {
  name        = var.IAM_policy_name_source
  path        = "/"
  description = var.IAM_policy_desc_source

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowListigOfUserFolder",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.source_Bucket_name}"
        ]
      },
      {
        "Sid" : "HomeDirObjectAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:DeleteObjectVersion"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.source_Bucket_name}",
          "arn:aws:s3:::${var.source_Bucket_name}/*"
        ]
      }
    ]
  })
  depends_on = [var.glue_policy_depends_on]
}

resource "aws_iam_policy" "userFullAccess" {
  name        = var.IAM_policy_name_dest
  path        = "/"
  description = var.IAM_policy_desc_dest

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowListigOfUserFolder",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.dest_Bucket_name}"
        ]
      },
      {
        "Sid" : "HomeDirObjectAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:DeleteObjectVersion"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.dest_Bucket_name}",
          "arn:aws:s3:::${var.dest_Bucket_name}/*"
        ]
      }
    ]
  })
  depends_on = [var.glue_policy_depends_on]
}

resource "aws_iam_role" "service_to_s3_iamRole" {
  name = var.IAM_Glue_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "${var.IAM_Glue_role_service}"
        }
      },
    ]
  })

  tags = {
    Name      = var.IAM_Glue_role_name
    Region    = var.Region
    Terraform = "true"
  }
  depends_on = [aws_iam_policy.userFullAccess, aws_iam_policy.userReadAccess]
}

resource "aws_iam_role_policy_attachment" "iamRole-attach1" {
  role       = aws_iam_role.service_to_s3_iamRole.name
  policy_arn = aws_iam_policy.userReadAccess.arn
  depends_on = [aws_iam_role.service_to_s3_iamRole]
}

resource "aws_iam_role_policy_attachment" "iamRole-attach2" {
  role       = aws_iam_role.service_to_s3_iamRole.name
  policy_arn = aws_iam_policy.userFullAccess.arn
  depends_on = [aws_iam_role.service_to_s3_iamRole]
}

resource "aws_iam_role_policy_attachment" "iamRole-attach3" {
  role       = aws_iam_role.service_to_s3_iamRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  depends_on = [aws_iam_role.service_to_s3_iamRole]
}