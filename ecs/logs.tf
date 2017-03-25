## CloudWatch Logs

resource "aws_cloudwatch_log_group" "ecs" {
  name = "jenkins-ecs-group/ecs-agent"
}

resource "aws_cloudwatch_log_group" "app" {
  name = "jenkins-ecs-group/app-jenkins"
}
