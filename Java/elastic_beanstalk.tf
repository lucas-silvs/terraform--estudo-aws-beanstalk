# Criando a Aplicacao Beanstalk
resource "aws_elastic_beanstalk_application" "application_teste" {
  name        = "application--beanstalk-teste-java-17"
  description = "exemplo teste para criação de ambiente Beanstalk utilizando Terraform"
}

# Criando Ambiente Beanstalk 
resource "aws_elastic_beanstalk_environment" "enviroment_teste" {
  name                = "enviroment--beanstalk-teste-java-17"
  application         = aws_elastic_beanstalk_application.application_teste.name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.3 running Corretto 17"


  # ---------------------------- Definindo Configurações das instancias EC2 utilizada -------------------------------
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  # ---------------------- Associando instance profile ao Beanstalk -------------------------------------
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.name
  }

  # ---------------------------- Configurando quantidade de min/max de instancias ec2 ------------------------------
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = 1
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = 1
  }

  #   -------------------- Configurando Trigger para auto scaling -------------------------------------

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

  #---------------------------- Definindo Configurações de Rolling update, onde é executado o deploy da nova versão em lotes ----------------------

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled" // Habilitando o uso do Rolling update, onde o deploy de uma versão nova acontece em lotes, o valor padrão é false
    value     = true
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType" // Definindo estrategia validação de atualização do deploy, o valor padrão é Time
    value     = "Health"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MaxBatchSize" // Definindo o tamanho do lote que será atualizado, o valor padrão é 1
    value     = 1
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "PauseTime" // Definindo o tempo de pausa antes de iniciar o proximo lote
    value     = "PT2M"
  }


  #   ----------------------------- Definindo Configurações de Deploy --------------------------------

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy" // Definindo politica de deploy, qual estrategia de deploy será utilizada, o valor padrão é AllAtOnce
    value     = "Rolling"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType" // Definindo o tipo de unidade de medida utilizado para definir o tamanho do lote, o valor padrão é Percentage
    value     = "Fixed"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize" // Definindo o tamanho o tamanho do lote seguindo o tipo definido, o valor padrão é
    value     = 1
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  #   -------------------------- Definindo configurações para verificação da saúde e comunicação das instancias -----------------
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port" // Definindo a porta onde o o ELB acessará das instancias, o valor padrão é 80 (HTTP Default)
    value     = 5000
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath" // Definindo a porta onde o o ELB acessará das instancias, o valor padrão é 80 (HTTP Default)
    value     = "/feature--toggle/actuator/health"
  }

  #   ---------------------- Definindo variavel de ambiente para execução em mongo ou inmemory -------------------------------------

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_PROFILES_ACTIVE" // definindo variavel spring profile active da aplicação exemplo em java
    value     = "mongo"
  }

  # --------------------------- Habilitando logs no Cloudwatch -------------------------------

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs" // definindo variavel spring profile active da aplicação exemplo em java
    value     = true
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays" // definindo variavel spring profile active da aplicação exemplo em java
    value     = 1
  }


  //tags só precisam ser definidas durante a criação do ambiente, não sendo necessário definir após a criação o atualização
  #   tags = {
  #     Name        = "aplicacao-teste"
  #     Environment = "Development"
  #   }

}
