locals {
  aws_ecs_cluster_arn         = aws_ecs_cluster.elt.arn
  aws_ecs_task_definition_arn = aws_ecs_task_definition.dbt.arn
  aws_subnet_ids              = jsonencode(tolist([for s in aws_subnet.public : s.id]))
  aws_security_group_id       = aws_security_group.dbt_security_group.id
}

resource "aws_sfn_state_machine" "bmw_stata_machine" {
  name       = "${var.env}-${var.app_name}"
  role_arn   = aws_iam_role.sfn.arn
  definition = jsonencode({
    StartAt : "RunDbtTask",
    States : {
      RunDbtTask : {
        Type : "Task",
        Resource : "arn:aws:states:::ecs:runTask.sync",
        Parameters : {
          Cluster : local.aws_ecs_cluster_arn,
          TaskDefinition : local.aws_ecs_task_definition_arn,
          LaunchType : "FARGATE",
          NetworkConfiguration : {
            AwsvpcConfiguration : {
              Subnets : local.aws_subnet_ids,
              SecurityGroups : [local.aws_security_group_id],
              AssignPublicIp : "ENABLED"
            }
          }
        },
        End : true
      }
    }
  })
}