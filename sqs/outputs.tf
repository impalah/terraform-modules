output "sqs_queue_arn" {
  value       = aws_sqs_queue.main.arn
  description = "ARN of the main SQS queue"
}

output "sqs_queue_url" {
  value       = aws_sqs_queue.main.url
  description = "URL of the main SQS queue"
}

output "dlq_queue_arn" {
  value       = var.create_dead_letter_queue ? aws_sqs_queue.dlq[0].arn : null
  description = "ARN of the DLQ (if created)"
}

output "dlq_queue_url" {
  value       = var.create_dead_letter_queue ? aws_sqs_queue.dlq[0].url : null
  description = "URL of the DLQ (if created)"
}

