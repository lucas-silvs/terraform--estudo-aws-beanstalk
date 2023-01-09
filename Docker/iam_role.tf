# Criando IAM Policy que será associada a IAM role 
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

}

resource "aws_iam_role" "instance" {
  name               = "aws--iam-role-teste"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

# Criando IAM Instance e associando role aws criada
resource "aws_iam_instance_profile" "beanstalk_instance_profile" {
  name = "aws--instance-profile-beanstalk-exemplo"
  role = aws_iam_role.instance.name
}
