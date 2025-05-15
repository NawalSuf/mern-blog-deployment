provider "aws" {
  region = "eu-north-1"
}

# ------------------ S3 Buckets ------------------

resource "aws_s3_bucket" "frontend" {
  bucket = "frontend-bucket-alsufyani"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "Frontend Hosting"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "PublicReadGetObject",
        Effect : "Allow",
        Principal : "*",
        Action : "s3:GetObject",
        Resource : "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket" "media" {
  bucket = "media-bucket-alsufyani"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  tags = {
    Name = "Media Uploads"
  }
}

# ------------------ IAM for S3 Programmatic Access ------------------

resource "aws_iam_user" "media_user" {
  name = "blog-media-uploader"
}

resource "aws_iam_access_key" "media_key" {
  user = aws_iam_user.media_user.name
}

resource "aws_iam_user_policy" "media_policy" {
  name = "media-upload-policy"
  user = aws_iam_user.media_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutObjectAcl",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.media.arn}",
          "${aws_s3_bucket.media.arn}/*",
          "${aws_s3_bucket.frontend.arn}",
          "${aws_s3_bucket.frontend.arn}/*"
        ]
      }
    ]
  })
}


# ------------------ Security Group ------------------

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "backend_sg" {
  name   = "blog-backend-sg"
  vpc_id = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App port 5000
  ingress {
    description = "App access"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ------------------ EC2 Instance ------------------

resource "aws_instance" "backend" {
  ami                    = "ami-000e50175c5f86214"
  instance_type          = "t3.medium"
  key_name               = "rsa_key"
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  tags = {
    Name = "Blog Backend"
  }

  # Optional provisioner just to test SSH
  provisioner "remote-exec" {
    inline = [
      "echo Hello from EC2"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/rsa_key.pem")
      host        = "16.16.233.15"
    }
  }
}