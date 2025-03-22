################################################################################
# Main QUEUE configuration
################################################################################


resource "aws_sqs_queue" "main" {

  name                        = var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication

  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = var.create_dead_letter_queue ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = merge(
    { "Name" = var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name },
    var.tags,
    var.default_tags,
  )


}

# dead letter queue configuration
resource "aws_sqs_queue" "dlq" {
  count                     = var.create_dead_letter_queue ? 1 : 0
  name                      = "${var.queue_name}-dlq"
  message_retention_seconds = var.dlq_message_retention_seconds

  tags = merge(
    { "Name" = "${var.queue_name}-dlq" },
    var.tags,
    var.default_tags,
  )

}

