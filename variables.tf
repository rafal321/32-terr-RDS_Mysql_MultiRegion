# - variables.tf
variable "name" {
  description = "Prefix for resource names"
  type        = string
  default     = "raf-devi"
}
variable "aws_profile" {
  description = "AWS Profile to use for deployments"
  type        = string
  default     = "lab"
}
variable "region" {
  type        = string
  description = "The name of the primary AWS region you wish to deploy into"
  default     = "eu-west-1"
}
variable "sec_region" {
  type        = string
  description = "The name of the secondary AWS region you wish to deploy into"
  default     = "eu-central-1"
}
variable "Private_subnet_ids_p" {
  type        = list(string)
  description = "A list of private subnet IDs in your Primary AWS region VPC"
  default     = ["subnet-02c8075bf371855b0", "subnet-0dc3a8aee59756816", "subnet-0da64c045bd6d2877"]
}
variable "Private_subnet_ids_s" {
  type        = list(string)
  description = "A list of private subnet IDs in your Secondary AWS region VPC"
  default     = ["subnet-03cf8c70b128bf4d7", "subnet-09231285ff07a5f71", "subnet-0586806e2ce2fd7a9"]
}
variable "engine" {
  description = "Aurora database engine type: aurora (for MySQL 5.6-compatible Aurora), aurora-mysql (for MySQL 5.7-compatible Aurora)"
  type        = string
  default     = "aurora-mysql"
}
variable "engine_version_mysql" {
  description = "Aurora database engine version.(5.7.mysql_aurora.2.09.2)"
  type        = string
  default     = "5.7.mysql_aurora.2.10.1"
}
variable "allow_major_version_upgrade" {
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to `false`"
  type        = bool
  default     = false
}
variable "port" {
  description = "The port on which to accept connections"
  type        = number
  default     = 3306
}
variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = "verification_db"
}
variable "username" {
  description = "Master DB username"
  type        = string
  default     = "admin"
}
variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 3
}
variable "preferred_backup_window" {
  description = "When to perform DB backups"
  type        = string
  default     = "06:00-07:00"
}
variable "storage_encrypted" {
  description = "Specifies whether the underlying Aurora storage layer should be encrypted"
  type        = bool
  default     = true
}
variable "primary_instance_count" {
  description = "instance count for primary Aurora cluster"
  default     = 2
}
variable "secondary_instance_count" {
  description = "instance count for primary Aurora cluster"
  default     = 1
}
variable "instance_class" {
  type        = string
  description = "Instance type to use"
  default     = "db.r5.large"
}
variable "cluster_security_groups_p" {
  description = "Security Groups for DB instances."
  type        = list(string)
  default     = ["sg-094f5b633ec9e7cd2"]
}
variable "cluster_security_groups_s" {
  description = "Security Groups for DB instances."
  type        = list(string)
  default     = ["sg-0443e8e4b6b33480a"]
}
variable "kms_key_p" {
  description = "kmsKeyId should be explicitly specified for primary | optional"
  type        = string
  default     = "arn:aws:kms:eu-west-1:411929112137:key/41f6c450-6520-454b-8acc-96374f264eae"
  #default     = "alias/aws/rds"
}
variable "kms_key_s" {
  description = "kmsKeyId should be explicitly specified for secondary | MUST exist"
  type        = string
  default     = "arn:aws:kms:eu-central-1:411929112137:key/aa0b3903-b422-432c-83d9-f9deba048d14"
  #default     = "alias/aws/rds"
}
variable "enable_logs" {
  description = "MySQL log export to Amazon Cloudwatch."
  type        = list(string)
  default     = ["error", "slowquery"]
}
variable "performance_insights" {
  description = "Enable performance insights"
  type        = bool
  default     = false
}
#___________________________________________________________________
#---- Tags ----
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default = {
    tag01   = "this is 01 tag"
    tag02   = "this is 02 tag"
    env     = "dev"
    project = "example project 1"
  }
}
#==================================


variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds"
  type        = number
  default     = 60
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Valid values: (0, 1, 5, 10, 15, 30, 60), 0 = Disabled."
  }
}
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.Enabling.html
# The role is named rds-monitoring-role. once it's created it's always there, so just use role arn  see rds-99
# apparently enchanced monitoring if enabled it creates 'rds-monitoring-role' right!
