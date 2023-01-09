resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "cloudwath--policy"
  path        = "/"
  description = "policy para dar permissao ao Beanstalk criar logs"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}
