# ECS Fargate WordPress Server Deployment with Terraform

## Project Overview
This project automates the deployment of a containerized WordPress server on AWS ECS Fargate using Terraform. The infrastructure includes an ECS Cluster with Fargate launch type, RDS MySQL database, and all necessary networking components for a fully functional WordPress deployment.

## Architecture
The infrastructure consists of:

- ECS Fargate Cluster with WordPress containers

- RDS MySQL Database for WordPress data storage

- Custom VPC with public subnets across multiple availability zones

- Internet Gateway for public internet access

- Security Groups for network traffic control

- IAM Roles for ECS task execution

- Architecture Flow

![alt text](https://raw.githubusercontent.com/zaeemattique/InnovationLab-Task4/refs/heads/main/Task4%20Architecture.png)

## Project Structure
```text
task4/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── provider.tf
└── modules/
    ├── networking/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ecs/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── sg/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

```
## Prerequisites
Software Requirements
Terraform v1.13.5 or later

AWS CLI configured with appropriate credentials

Git for version control

AWS Requirements
AWS account with appropriate permissions

Access Key ID and Secret Access Key

Default region: us-west-2

## Deployment Steps
1. Clone the Repository
```bash
git clone <repository-url>
cd task4
```
2. Initialize Terraform
```bash
terraform init
```
3. Review Execution Plan
```bash
terraform plan
```
4. Apply Infrastructure
```bash
terraform apply
```
## Infrastructure Components
### VPC Configuration
```hcl
resource "aws_vpc" "task4_vpc_zaeem" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Task4-vpc-zaeem"
  }
}
```
### Public Subnets
- Subnet A: 10.0.1.0/24 in us-west-2a

- Subnet B: 10.0.2.0/24 in us-west-2b

### Internet Gateway & Route Table
```hcl
resource "aws_internet_gateway" "task4_igw_zaeem" {
  vpc_id = aws_vpc.task4_vpc_zaeem.id
  tags = {
    Name = "Task4-igw-zaeem"
  }
}

resource "aws_route_table" "task4_public_rt_zaeem" {
  vpc_id = aws_vpc.task4_vpc_zaeem.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task4_igw_zaeem.id
  }
  tags = {
    Name = "Task4-public-rt-zaeem"
  }
}
````
### ECS Cluster Configuration
```hcl
resource "aws_ecs_cluster" "task4_ecs_cluster_zaeem" {
  name = "Task4-ECS-Cluster-Zaeem"
}
```
### ECS Task Definition
```hcl
resource "aws_ecs_task_definition" "task4_task_definition_zaeem" {
  family                   = "Task4FamilyZaeem"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  
  container_definitions = jsonencode([{
    name      = "Wordpress-Container"
    image     = "wordpress:6.8.3-php8.1-apache"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])
}
```
### ECS Service
```hcl
resource "aws_ecs_service" "task4_ecs_service_zaeem" {
  name            = "Task4-ECS-Service-Zaeem"
  cluster         = aws_ecs_cluster.task4_ecs_cluster_zaeem.id
  task_definition = aws_ecs_task_definition.task4_task_definition_zaeem.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = [var.public_subnet_id_A, var.public_subnet_id_B]
    security_groups  = [var.sg_id]
    assign_public_ip = true
  }
}
```
### RDS MySQL Database
```hcl
resource "aws_db_instance" "task4_mysql" {
  identifier             = "task4-mysql"
  allocated_storage      = 20
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  db_name               = "wordpressdb"
  username              = "root"
  password              = "YourPassword1231"
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot   = true
  publicly_accessible   = false
}
```
### Database Security Group
```hcl
resource "aws_security_group" "rds_sg" {
  name        = "task4-rds-sg"
  description = "Allow access from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.sg_id] # ECS task SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
### IAM Execution Role
```hcl
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
```
## Security Groups
### ECS Security Group
- Inbound Rules:

1. HTTP (80) from 0.0.0.0/0
2. SSH (22) from 0.0.0.0/0

- Outbound Rules: All traffic

1. Inbound Rules: MySQL (3306) from ECS Security Group
2. Outbound Rules: All traffic

## Accessing WordPress
1. Find Public IP
2. Go to AWS ECS Console
3. Navigate to Clusters → Task4-ECS-Cluster-Zaeem
4. Click on Tasks tab
5. Select the running task
6. In the Network section, find the Public IP
7. Open your web browser
8. Navigate to: http://<PUBLIC_IP>
9. Complete WordPress setup wizard

## Verification
Verify ECS Service
```bash
# Check ECS service status
aws ecs describe-services \
  --cluster Task4-ECS-Cluster-Zaeem \
  --services Task4-ECS-Service-Zaeem
```
Verify RDS Instance
```bash
# Check RDS instance status
aws rds describe-db-instances \
  --db-instance-identifier task4-mysql
```
Test WordPress Access
```bash
# Test HTTP access
curl -I http://<PUBLIC_IP>
```

## Challenges Faced & Solutions
1. Network Configuration
Challenge: Network configuration must be defined in the ECS service block, not in the cluster or task definition blocks.

Solution: Properly configured network_configuration block within the ECS service resource.

2. Security Group Configuration
Challenge: Security groups require appropriate outbound rules to pull images from Docker Hub and inbound rules for WordPress port access.

Solution: Configured security groups with:

- Outbound rules allowing all traffic for Docker Hub access
- Inbound rules for HTTP (80) traffic

3. Database Dependency
Challenge: WordPress container requires an external database instance to start properly, as it doesn't include a database in the Docker image.

Solution: Provisioned RDS MySQL instance with proper security groups and subnet groups for ECS task connectivity.

4. IAM Roles
Challenge: ECS tasks require proper IAM execution roles to pull container images and access AWS services.

Solution: Created IAM role with AmazonECSTaskExecutionRolePolicy attached.

## Cleanup
To destroy all created resources and avoid ongoing charges:

```bash
terraform destroy
```
Note: This will delete the RDS instance and all data stored in it.

## Author
Zaeem Attique Ashar

Cloud Intern - Cloudelligent
