# terraform--estudo-aws-beanstalk

repositório para análise e estudo de criação de ambiente Beanstalk utilizando Terraform.

Nesse projeto será desenvolvido um ambiente Beanstalk com as configurações de plataforma, scalling, trigger, CI/CD, Deployment Strategy, Instance Profile, Roles e policies, utilizando somente o Terraform:

Os namespaces do Auto Scaling Group para configurar o Beanstalk foi obtidos na documentação oficial a AWS:

- [Auto Scaling Group](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-autoscalingasg)

## Criando o ambiente

Para criar o ambiente do arquivo, deve executar o comando abaixo na raiz da pasta do repositório clonaod:

```
terraform apply
```
