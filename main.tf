# main.tf
#
provider "aws" {
  region = "eu-west-1"
}

# Configuration du bucket S3 pour stocker les images et les rendre publiques
resource "aws_s3_bucket" "mon_bucket" {
  bucket = "ynov-infracloud-wattelgayelordv2"
}

# Configuration pour bloquer les accès publics non nécessaires au bucket S3
resource "aws_s3_bucket_public_access_block" "pab_bucket" {
  bucket = aws_s3_bucket.mon_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Politique du bucket S3 pour autoriser l'accès public aux objets
resource "aws_s3_bucket_policy" "mon_bucket_policy" {
  bucket = aws_s3_bucket.mon_bucket.id

  # Déclaration de la politique en JSON
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.mon_bucket.arn}/*"
      },
    ]
  })
}

# Téléchargement de l'image puppy.jpg dans le bucket S3
resource "aws_s3_object" "puppy_object" {
  bucket = aws_s3_bucket.mon_bucket.bucket
  key    = "puppy.jpg" # Le chemin d'accès dans le bucket où le fichier sera stocké
  source = "./puppy.jpg" # Le chemin d'accès local au fichier à télécharger
}

# Définition d'une data source pour référencer un Security Group existant pour la base de données
data "aws_security_group" "db_security_group" {
  id = "sg-0c37b0335fdf3d50d"
}

# Configuration d'un Security Group pour les instances web
resource "aws_security_group" "sg_web" {
  name_prefix = "web-gayelordwattel"
  description = "Security group for web servers"
  vpc_id      = "vpc-0049682c1b010a070" # Remplacez par l'ID de votre VPC

  # Autoriser le trafic entrant HTTP sur le port 80 de n'importe où
  ingress {
    description = "Allow port 80 from anywhere for HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser le trafic entrant SSH sur le port 22 de n'importe où
  ingress {
    description = "Allow port 22 from anywhere for SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser tout le trafic sortant
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 signifie tous les protocoles
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Configuration du Launch Template pour les instances EC2
resource "aws_launch_template" "launchTemplate_gayelordwattel" {
  name_prefix   = "launchTemplate-gayelordwattel"
  image_id      = "ami-012ba92271e91512d"
  instance_type = "t2.micro"
  depends_on = [
      aws_security_group.sg_web
  ]
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups = [aws_security_group.sg_web.id,data.aws_security_group.db_security_group.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    cd /home/ubuntu/app/
    sudo docker compose up --build -d
  EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sg_gayelordwattel" {
  name_prefix = "sec-gayelordwattel"

  # Règle pour le Load Balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle pour SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Attacher le Security Group de la DB
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["sg-0c37b0335fdf3d50d"]
  }
}

resource "aws_autoscaling_group" "asg_gayelordwattel" {
  name_prefix = "asg-gayelordwattel"
  max_size    = 2
  min_size    = 0
  desired_capacity = 2
  depends_on = [
    aws_launch_template.launchTemplate_gayelordwattel,
    aws_lb_target_group.tg_gayelordwattel
  ]

  vpc_zone_identifier = ["subnet-0e3b5a73eb879dbe8","subnet-00c1a909f003623cf"]

  launch_template {
    id      = aws_launch_template.launchTemplate_gayelordwattel.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-instance-gayelordwattel"
    propagate_at_launch = true
  }
}



resource "aws_lb" "lb_gayelordwattel" {
  name               = "lb-gayelordwattel"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_gayelordwattel.id]
  subnets            = ["subnet-0e3b5a73eb879dbe8","subnet-00c1a909f003623cf"]
  depends_on = [
    aws_security_group.sg_gayelordwattel
  ]
}


resource "aws_lb_listener" "listener_gayelordwattel" {
  load_balancer_arn = aws_lb.lb_gayelordwattel.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on = [
    aws_lb.lb_gayelordwattel,
    aws_lb_target_group.tg_gayelordwattel
  ]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_gayelordwattel.arn
  }
}

resource "aws_lb_target_group" "tg_gayelordwattel" {
  name     = "tg-gayelordwattel"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0049682c1b010a070"
}

resource "aws_autoscaling_attachment" "asg_attachment_gayelordwattel" {
  autoscaling_group_name = aws_autoscaling_group.asg_gayelordwattel.id
  lb_target_group_arn    = aws_lb_target_group.tg_gayelordwattel.arn
}