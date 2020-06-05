# IAM role which dictates what other AWS services the Lambda function
 # may access.
provider "aws" {
  region     = var.aws_region
}

data "archive_file" "lambda_zip" {
    type          = "zip"
    source_file   = "lambda.py"
    output_path   = "lambda_function.zip"
}

resource "aws_vpc" "lambda" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "lambda" {
  vpc_id     = aws_vpc.lambda.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Lambda Subnet"
  }
}

resource "aws_security_group" "lambda" {
  name        = "lambda"
  description = "Lambda Security Group"
  vpc_id      = aws_vpc.lambda.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda"
  }
}

resource "aws_iam_role" "lambda" {
   name = "lambda_iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "lambda" {
  name        = "lambda_policy"
  path        = "/"
  description = "My lambda policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
        "Effect": "Allow",
        "Action": [
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
        ],
        "Resource": ["*"]
    }
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.lambda.arn}"
}

resource "aws_lambda_function" "lambda" {
    filename      = "lambda_function.zip"
    function_name = "greet_lambda"
    role          = aws_iam_role.lambda.arn
    handler       = "lambda.lambda_handler"

    runtime = "python3.6"

    vpc_config {
        subnet_ids = [aws_subnet.lambda.id]
        security_group_ids = [aws_security_group.lambda.id]
    }

    environment {
        variables = {
            greeting = "did it"
        }
    }


}