resource "aws_budgets_budget" "account_budget" {
  name              = "monthly-account-budget"
  budget_type       = "COST"
  limit_amount      = var.limit_amount
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  # Tier 1: Warning - Actual spend > $5
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 33.33 # roughly $5
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Tier 2: Elevated - Actual spend > $10
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 66.66 # roughly $10
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Tier 3: Critical - Forecasted spend > $15
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}
