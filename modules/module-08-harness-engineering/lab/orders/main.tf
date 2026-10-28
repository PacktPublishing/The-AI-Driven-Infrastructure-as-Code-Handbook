# Orders storage for the checkout service. Added in a hurry before the launch.
# TODO: harden before this ships.
resource "aws_dynamodb_table" "orders" {
  name         = "checkout-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  # The current, unhardened settings, written out so a plan-mode test can read them.
  point_in_time_recovery {
    enabled = false
  }

  server_side_encryption {
    enabled = false
  }
}

data "aws_iam_policy_document" "orders_access" {
  statement {
    actions   = ["dynamodb:*"]
    resources = [aws_dynamodb_table.orders.arn]
  }
}

resource "aws_iam_policy" "orders_access" {
  name   = "checkout-orders-access"
  policy = data.aws_iam_policy_document.orders_access.json
}
