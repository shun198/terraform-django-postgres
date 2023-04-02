# ------------------------------
# Bastion Server Configuration
# ------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-3.0.*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  user_data            = file("./scripts/bastion/user-data.sh")
  key_name      = var.bastion_key_name
  # パブリックサブネットに配置
  subnet_id = aws_subnet.public_a.id
  # 踏み台サーバのセキュリティグループを指定
  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]
  # タグ付け
  # mergeを使うことで一部のmain.tfにあるcommon_tagsをoverrideできる
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion" })
  )
}
resource "aws_security_group" "bastion" {
  description = "Control bastion inbound and outbound access"
  name        = "${local.prefix}-bastion"
  vpc_id      = aws_vpc.main.id

  # sshを許可
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_c.cidr_block,
    ]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion-sg" })
  )
}