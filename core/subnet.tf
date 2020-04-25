data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}


resource "aws_db_subnet_group" "default_subnet_group" {
  name       = "covid-default-subnet-group"
  subnet_ids = data.aws_subnet_ids.all.ids

  tags = {
    Name = "covid-default-subnet-group"
  }
}
