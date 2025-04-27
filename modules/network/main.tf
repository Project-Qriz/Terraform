resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
    Environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = var.nat_instance_eni_id
    # nat instance에 대한 라우팅은 따로 해줘야 함
  }

  tags = {
    Name = "${var.environment}-private-rt"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Transit Gateway 리소스 (enable_tgw가 true인 경우에만 생성)
resource "aws_ec2_transit_gateway" "tgw" {
  count = var.enable_tgw ? 1 : 0
  
  description                     = "Transit Gateway for ${var.environment} environment"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {
    Name        = "qriz-${var.environment}-tgw"
    Environment = var.environment
  }
}

# VPC에 대한 Transit Gateway 연결
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  count = var.enable_tgw ? 1 : 0
  
  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id             = aws_vpc.main.id
  subnet_ids         = aws_subnet.private[*].id
  
  tags = {
    Name        = "qriz-${var.environment}-tgw-attachment"
    Environment = var.environment
  }
}

# 사용자 정의 라우팅이 필요한 경우 추가 라우트 설정 (Transit Gateway 사용 시)
resource "aws_route" "tgw_route" {
  count = var.enable_tgw && var.tgw_destination_cidr != "" ? 1 : 0
  
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.tgw_destination_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw[0].id
}