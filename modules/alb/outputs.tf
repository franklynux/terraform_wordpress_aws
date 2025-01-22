output "alb_arn" {
    value = aws_lb.wp-lb.arn
    description = "The Application Load Balancer ARN"
  
}

output "target_group_arn" {
    value = aws_lb_target_group.wp-tg.arn
    description = "The Target Group ARN"
  
}