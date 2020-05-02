locals {
  covid_rds = {
    username = "covid_rds"
    password = random_string.rds_password.result
    port     = 5432
  }
}

resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "$#"
}


resource "aws_db_instance" "covid_rds" {
  identifier             = "covid-rds"
  engine                 = "postgres"
  engine_version         = "10.6"
  port                   = local.covid_rds.port
  username               = local.covid_rds.username
  password               = local.covid_rds.password
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.postgres.id]
  skip_final_snapshot    = true
  license_model          = "postgresql-license"
}
