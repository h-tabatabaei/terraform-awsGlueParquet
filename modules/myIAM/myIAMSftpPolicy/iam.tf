resource "aws_iam_policy" "userAccess" {
  name        = var.IAM_policy_name
  path        = "/"
  description = var.IAM_policy_desc

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
          "arn:aws:s3:::${var.Bucket_name}"
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
          "arn:aws:s3:::${var.Bucket_name}",
          "arn:aws:s3:::${var.Bucket_name}/*"
        ]
      }
    ]
  })
  depends_on = [var.sftp_policy_depends_on]
}

resource "aws_iam_role" "service_to_s3_iamRole" {
  name = var.IAM_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "${var.IAM_role_service}"
        }
      },
    ]
  })

  tags = {
    Name      = var.IAM_role_name
    Region    = var.Region
    Terraform = "true"
  }
  depends_on = [aws_iam_policy.userAccess]
}

resource "aws_iam_role_policy_attachment" "iamRole-attach" {
  role       = aws_iam_role.service_to_s3_iamRole.name
  policy_arn = aws_iam_policy.userAccess.arn
  depends_on = [aws_iam_role.service_to_s3_iamRole]
}