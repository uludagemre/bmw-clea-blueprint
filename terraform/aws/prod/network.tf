resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  tags             = {
    "Name" = "${var.env}-${var.app_name}",
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_ids)
  vpc_id            = aws_vpc.main.id
  availability_zone = var.azs[count.index]
  cidr_block        = var.public_subnet_ids[count.index]

  tags = {
    Name = "${var.env}-${var.app_name}-public-${var.azs[count.index]}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for subnet in var.public_subnet_ids : aws_route_table.public[subnet].id]
  tags              = {
    Name = "s3-endpoint"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-${var.app_name}-igw"
  }
}

resource "aws_route_table" "public" {
  count  = length(var.public_subnet_ids)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-${var.app_name}-public-subnet-rt-${count.index}"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "dbt_security_group" {
  name        = "${var.env}-${var.app_name}-ecs-task-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.app_name}-ecs-task-sg"
  }
}
