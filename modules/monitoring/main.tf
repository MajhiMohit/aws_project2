# ------------------------------------------------------------------------------
# MONITORING MODULE: CloudWatch Alarms & SNS Alerting
# Managed by: Team T334 (Logging & Audit)
# Detects: Root login, unauthorized API calls, CloudTrail tampering
# ------------------------------------------------------------------------------

# 1. SNS Topic — receives all CloudWatch alarm notifications
resource "aws_sns_topic" "security_alerts" {
  name = "landingzone-security-alerts-${var.environment}"

  tags = {
    Name        = "landingzone-security-alerts-${var.environment}"
    Team        = var.team
    Environment = var.environment
    Purpose     = "Security-Alerting"
  }
}

# 2. CloudWatch Log Group for custom metric filters (CloudTrail events)
resource "aws_cloudwatch_log_group" "cloudtrail_events" {
  name              = "/aws/cloudtrail/events/${var.environment}"
  retention_in_days = 90

  tags = {
    Name        = "LandingZone-CloudTrailEvents-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# ==============================================================================
# ALARM 1: Root Account Login Detection
# Root logins bypass IAM — any root activity must alert immediately
# ==============================================================================

resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "landingzone-root-login-filter-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_events.name
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"

  metric_transformation {
    name      = "RootLoginCount"
    namespace = "LandingZone/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login_alarm" {
  alarm_name          = "landingzone-root-account-login-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.root_login.metric_transformation[0].name
  namespace           = "LandingZone/Security"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "SECURITY ALERT: Root account login detected in Landing Zone (${var.environment})"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.security_alerts.arn]
  ok_actions    = [aws_sns_topic.security_alerts.arn]

  tags = {
    Name        = "landingzone-root-login-alarm-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# ==============================================================================
# ALARM 2: Unauthorized API Call Detection
# Catches access-denied errors — potential attacker probing permissions
# ==============================================================================

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api" {
  name           = "landingzone-unauthorized-api-filter-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_events.name
  pattern        = "{ ($.errorCode = \"*UnauthorizedAccess*\") || ($.errorCode = \"AccessDenied\") }"

  metric_transformation {
    name      = "UnauthorizedAPICallCount"
    namespace = "LandingZone/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_alarm" {
  alarm_name          = "landingzone-unauthorized-api-calls-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api.metric_transformation[0].name
  namespace           = "LandingZone/Security"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "SECURITY ALERT: 5+ unauthorized API calls detected in ${var.environment} — potential intrusion attempt"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.security_alerts.arn]

  tags = {
    Name        = "landingzone-unauthorized-api-alarm-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# ==============================================================================
# ALARM 3: CloudTrail Tampering Detection
# Alerts if anyone tries to stop/delete the audit trail
# ==============================================================================

resource "aws_cloudwatch_log_metric_filter" "cloudtrail_tamper" {
  name           = "landingzone-cloudtrail-tamper-filter-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_events.name
  pattern        = "{ ($.eventName = DeleteTrail) || ($.eventName = StopLogging) || ($.eventName = UpdateTrail) }"

  metric_transformation {
    name      = "CloudTrailChangeCount"
    namespace = "LandingZone/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_tamper_alarm" {
  alarm_name          = "landingzone-cloudtrail-tamper-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.cloudtrail_tamper.metric_transformation[0].name
  namespace           = "LandingZone/Security"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "CRITICAL ALERT: CloudTrail modification attempt detected in ${var.environment} — audit integrity at risk"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.security_alerts.arn]

  tags = {
    Name        = "landingzone-cloudtrail-tamper-alarm-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}
