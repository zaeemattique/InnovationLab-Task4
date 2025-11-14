output "ecs_cluster_id" {
    description = "ECS Cluster ID"
    value       = aws_ecs_cluster.Task4-ECS-Cluster-Zaeem.id

}

output "exec_role_arn" {
    description = "ECS Task Execution Role ARN"
    value = aws_iam_role.ecs_task_execution_role.arn
  
}