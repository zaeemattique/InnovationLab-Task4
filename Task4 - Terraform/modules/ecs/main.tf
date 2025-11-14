resource "aws_ecs_cluster" "Task4-ECS-Cluster-Zaeem" {
  name = "Task4-ECS-Cluster-Zaeem"
  
}

resource "aws_db_instance" "task4_mysql" {
  identifier          = "task4-mysql"
  allocated_storage   = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  db_name             = "wordpressdb"
  username            = "root"
  password            = "YourPassword123!"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false
}

resource "aws_security_group" "rds_sg" {
  name        = "task4-rds-sg"
  description = "Allow access from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description      = "MySQL from ECS"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [var.sg_id]  # ECS task SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "task4-rds-subnet-group"
  subnet_ids = [var.public_subnet_id_A, var.public_subnet_id_B]

  tags = {
    Name = "task4-rds-subnet-group"
  }
}

resource "aws_ecs_task_definition" "Task4-TaskDefinition-Zaeem" {
  family               = "Task4FamilyZaeem"
  network_mode         = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                  = "512"
  memory               = "1024"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "wordpressno-container"
      image     = "wordpress:6.8.3-php8.1-apache"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      environment = [
      {
        name  = "WORDPRESS_DB_HOST"
        value = aws_db_instance.task4_mysql.address
      },
      {
        name  = "WORDPRESS_DB_USER"
        value = "root"
      },
      {
        name  = "WORDPRESS_DB_PASSWORD"
        value = "YourPassword123!"
      },
      {
        name  = "WORDPRESS_DB_NAME"
        value = "wordpressdb"
      }
    ]

    }
  ])
}

resource "aws_ecs_service" "Task4-ECS-Service-Zaeem" {
  name            = "Task4-ECS-Service-Zaeem"
  cluster         = aws_ecs_cluster.Task4-ECS-Cluster-Zaeem.id
  task_definition = aws_ecs_task_definition.Task4-TaskDefinition-Zaeem.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  

  network_configuration {
    subnets         = [var.public_subnet_id_A, var.public_subnet_id_B]
    security_groups = [var.sg_id]
    assign_public_ip = true
  }
  
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRoleZaeem"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
