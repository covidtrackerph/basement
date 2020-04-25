resource "aws_db_instance" "covid_rds" {
  identifier        = "covid-rds"
  engine            = "postgres"
  engine_version    = "10.6"
  port              = 5432
  username          = "covid_rds"
  password          = var.covid_rds_password
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.postgres.id]
  skip_final_snapshot    = true
  license_model          = "postgresql-license"
}
