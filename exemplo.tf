terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

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

# Criando a Aplicacao Beanstalk
resource "aws_elastic_beanstalk_application" "application_teste" {
  name        = "application--beanstalk-teste"
  description = "exemplo teste para criação de ambiente Beanstalk utilizando Terraform"
}

# Criando Ambiente Beanstalk 
resource "aws_elastic_beanstalk_environment" "enviroment_teste" {
  name                = "enviroment--beanstalk-teste"
  application         = aws_elastic_beanstalk_application.application_teste.name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.3 running Corretto 17"


  # Associando instance profile ao Beanstalk
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.name
  }

  # Configurando quantidade de min/max de instancias ec2
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = 1
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = 5
  }

  #   Configurando Trigger para auto scaling

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold" // Trigger definido para escalar maquinas, se o valor for maior que o valor definido abaixo, é criado novas instancias ec2 ate o numero maximo de instancias
    value     = 40
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold" // Trigger definido para escalar maquinas, se o valor for menor que o valor definido abaixo, é removido instancias ec2 existentes ate o numero minimo de instancias
    value     = 40
  }


  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerBreachScaleIncrement" // Quantidade de instancias que serão removidas simultaneamente quando a metrica definida estiver abaixo do trigger
    value     = -1
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperBreachScaleIncrement"
    value     = 2 // Quantidade de instancias que serão criadas ao ultrapassar o trigger definido
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "CPUUtilization" // Qual métrica será utilizada para o trigger de auto scaling, o padrão é NetworkOut
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = "Average" // Qual estatistica utilizada pelo trigger, valor padrão é a Aberage
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "Percent" // unidade de medida utilizada, valor padrão é Bytes
  }

  # Definindo Configurações das instancias EC2 utilizada
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  tags = {
    Name        = "aplicacao-teste"
    Environment = "Development"
  }

}