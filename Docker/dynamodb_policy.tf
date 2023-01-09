resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamdb--policy"
  path        = "/"
  description = "policy para acesso ao dynamodb"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}
