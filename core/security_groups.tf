resource "aws_security_group" "postgres" {
  name   = "postgres-sg"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_db_access" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.postgres.id
  cidr_blocks       = ["0.0.0.0/0"]
}
