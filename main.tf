# +++++++++++++++++++++++++ rds-61/main.tf (2022-09-22)
#___________________________________________________________________
#---- Collect data ----
resource "random_string" "random" {
  length           = 32
  special          = true
  min_special      = 4
  override_special = "@$"
}
data "aws_rds_engine_version" "family" {
  engine   = var.engine
  version  = var.engine_version_mysql
  provider = aws.primary
}
# NEW
data "aws_availability_zones" "region_p" {
  state    = "available"
  provider = aws.primary
}
data "aws_availability_zones" "region_s" {
  state    = "available"
  provider = aws.secondary
}
data "aws_iam_role" "example" {
  name = "rds-monitoring-role"
}
#___________________________________________________________________
#---- Randomness ----
resource "random_string" "random_id" {
  length  = 16
  special = false
  upper   = false
  lower   = true
}
#___________________________________________________________________
#---- DB Subnet group ----
# -primary-
resource "aws_db_subnet_group" "private_p" {
  provider    = aws.primary
  name        = "${var.name}-sg"
  description = "${var.name} Subnet Group"
  subnet_ids  = var.Private_subnet_ids_p
  tags = merge(var.tags, {
    Name     = "${var.name}-sg"
    customer = var.name
    },
  )
}

resource "aws_db_subnet_group" "private_s" {
  provider    = aws.secondary
  name        = "${var.name}-sg"
  description = "${var.name} Subnet Group"
  subnet_ids  = var.Private_subnet_ids_s
  tags = merge(var.tags, {
    Name     = "${var.name}-sg"
    customer = var.name
    },
  )
}
#___________________________________________________________________
#---- Parameter Groups ----
# -primary-
resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group_p" {
  provider    = aws.primary
  name        = "${var.name}-cl-par-group-${random_string.random_id.id}"
  family      = data.aws_rds_engine_version.family.parameter_group_family
  description = "aurora-cluster-parameter-group"
  dynamic "parameter" {
    for_each = local.mysql_cluster_pgroup_params
    iterator = pblock
    content {
      name         = pblock.value.name
      value        = pblock.value.value
      apply_method = pblock.value.apply_method
    }
  }
  lifecycle { create_before_destroy = true }
  tags = merge(var.tags, {
    Name     = "${var.name}-cl-pg"
    customer = var.name
    },
  )
}
resource "aws_db_parameter_group" "aurora_db_parameter_group_p" {
  provider    = aws.primary
  name        = "${var.name}-db-par-group-${random_string.random_id.id}"
  family      = data.aws_rds_engine_version.family.parameter_group_family
  description = "aurora-db-parameter-group"
  dynamic "parameter" {
    for_each = local.mysql_db_pgroup_params
    iterator = pblock
    content {
      name         = pblock.value.name
      value        = pblock.value.value
      apply_method = pblock.value.apply_method
    }
  }
  lifecycle { create_before_destroy = true }
  tags = merge(var.tags, {
    Name     = "${var.name}-db-pg"
    customer = var.name
    },
  )
}
# --- Secondary ---
resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group_s" {
  provider    = aws.secondary
  name        = "${var.name}-cl-par-group-${random_string.random_id.id}"
  family      = data.aws_rds_engine_version.family.parameter_group_family
  description = "aurora-cluster-parameter-group"
  dynamic "parameter" {
    for_each = local.mysql_cluster_pgroup_params
    iterator = pblock
    content {
      name         = pblock.value.name
      value        = pblock.value.value
      apply_method = pblock.value.apply_method
    }
  }
  lifecycle { create_before_destroy = true }
  tags = merge(var.tags, {
    Name     = "${var.name}-cl-pg"
    customer = var.name
    },
  )
}
resource "aws_db_parameter_group" "aurora_db_parameter_group_s" {
  provider    = aws.secondary
  name        = "${var.name}-db-par-group-${random_string.random_id.id}"
  family      = data.aws_rds_engine_version.family.parameter_group_family
  description = "aurora-db-parameter-group"
  dynamic "parameter" {
    for_each = local.mysql_db_pgroup_params
    iterator = pblock
    content {
      name         = pblock.value.name
      value        = pblock.value.value
      apply_method = pblock.value.apply_method
    }
  }
  lifecycle { create_before_destroy = true }
  tags = merge(var.tags, {
    Name     = "${var.name}-db-pg"
    customer = var.name
    },
  )
}
#===================================================================
#---- DB Cluster ----
# -global-
resource "aws_rds_global_cluster" "globaldb" {
  provider                  = aws.primary
  global_cluster_identifier = "${var.name}-global"
  engine                    = var.engine
  engine_version            = var.engine_version_mysql
  storage_encrypted         = var.storage_encrypted
}
# -primary cluster-
resource "aws_rds_cluster" "primary" {
  provider                         = aws.primary
  global_cluster_identifier        = aws_rds_global_cluster.globaldb.id
  cluster_identifier               = "${var.name}-${var.region}-cl"
  deletion_protection              = false
  engine                           = var.engine
  engine_version                   = var.engine_version_mysql
  allow_major_version_upgrade      = var.allow_major_version_upgrade
  availability_zones               = [data.aws_availability_zones.region_p.names[0], data.aws_availability_zones.region_p.names[1], data.aws_availability_zones.region_p.names[2]] # ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  db_subnet_group_name             = aws_db_subnet_group.private_p.name
  port                             = var.port
  database_name                    = var.database_name
  master_username                  = var.username
  master_password                  = "TemporarY~PassworD#4321"
  db_cluster_parameter_group_name  = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group_p.id
  db_instance_parameter_group_name = aws_db_parameter_group.aurora_db_parameter_group_p.id
  backup_retention_period          = var.backup_retention_period
  preferred_backup_window          = var.preferred_backup_window
  storage_encrypted                = var.storage_encrypted
  vpc_security_group_ids           = var.cluster_security_groups_p
  kms_key_id                       = var.kms_key_p
  apply_immediately                = true
  skip_final_snapshot              = false
  final_snapshot_identifier        = "${var.name}-final-snap-${random_string.random_id.id}"
  enabled_cloudwatch_logs_exports  = var.enable_logs[*]
  lifecycle { ignore_changes = [replication_source_identifier, engine_version, master_password] }
  depends_on = [ 
    # aws_rds_cluster_instance.secondary,
    # When this Aurora cluster is setup as a secondary, setting up the dependency makes sure to delete this cluster 1st before deleting current primary Cluster during terraform destroy
    # Comment out the following line if this cluster has changed role to be the primary Aurora cluster because of a failover for terraform destroy to work
  ]
  tags = merge(var.tags, {
    Name     = "${var.name}-cluster"
    customer = var.name
    service  = "db"
    },
  )
}
# -primary instances-
resource "aws_rds_cluster_instance" "primary" {
  provider                     = aws.primary
  count                        = var.primary_instance_count
  identifier                   = "${var.name}-${var.region}-n${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.primary.id
  engine                       = var.engine
  engine_version               = var.engine_version_mysql
  auto_minor_version_upgrade   = false
  instance_class               = var.instance_class
  db_subnet_group_name         = aws_db_subnet_group.private_p.name
  db_parameter_group_name      = aws_db_parameter_group.aurora_db_parameter_group_p.id
  performance_insights_enabled = var.performance_insights       # disable - faster deployment
  # monitoring_interval          = var.monitoring_interval        # comment out - faster deployment
  # monitoring_role_arn          = data.aws_iam_role.example.arn  # comment out - faster deployment
  apply_immediately            = true
  tags = merge(var.tags, {
    Name     = "${var.name}-node${count.index + 1}"
    customer = var.name
    service  = "db"
    },
  )
}
# -secondary cluster-
resource "aws_rds_cluster" "secondary" {
  provider                         = aws.secondary
  global_cluster_identifier        = aws_rds_global_cluster.globaldb.id
  cluster_identifier               = "${var.name}-${var.sec_region}-cl"
  deletion_protection              = false
  engine                           = var.engine
  engine_version                   = var.engine_version_mysql
  allow_major_version_upgrade      = var.allow_major_version_upgrade
  availability_zones               = [data.aws_availability_zones.region_s.names[0], data.aws_availability_zones.region_s.names[1], data.aws_availability_zones.region_s.names[2]] # ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  db_subnet_group_name             = aws_db_subnet_group.private_s.name
  port                             = var.port
  db_cluster_parameter_group_name  = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group_s.id
  db_instance_parameter_group_name = aws_db_parameter_group.aurora_db_parameter_group_s.id
  backup_retention_period          = var.backup_retention_period
  preferred_backup_window          = var.preferred_backup_window
  storage_encrypted                = var.storage_encrypted
  vpc_security_group_ids           = var.cluster_security_groups_s
  kms_key_id                       = var.kms_key_s
  apply_immediately                = true
  skip_final_snapshot              = false
  final_snapshot_identifier        = "${var.name}-final-snap-${random_string.random_id.id}"
  enabled_cloudwatch_logs_exports  = var.enable_logs[*]
  lifecycle { ignore_changes = [replication_source_identifier, engine_version, master_password] }
  depends_on = [
    aws_rds_cluster_instance.primary,
  ]
  tags = merge(var.tags, {
    Name     = "${var.name}-cluster"
    customer = var.name
    service  = "db"
    },
  )
}
# -secondary instances-
resource "aws_rds_cluster_instance" "secondary" {
  provider                     = aws.secondary
  count                        = var.secondary_instance_count
  identifier                   = "${var.name}-${var.sec_region}-n${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.secondary.id
  engine                       = var.engine
  engine_version               = var.engine_version_mysql
  auto_minor_version_upgrade   = false
  instance_class               = var.instance_class
  db_subnet_group_name         = aws_db_subnet_group.private_s.name
  db_parameter_group_name      = aws_db_parameter_group.aurora_db_parameter_group_s.id
  performance_insights_enabled = var.performance_insights       # disable - faster deployment
  # monitoring_interval          = var.monitoring_interval        # comment out - faster deployment
  # monitoring_role_arn          = data.aws_iam_role.example.arn  # comment out - faster deployment
  apply_immediately            = true                           # manual reboot required if parameter change
  tags = merge(var.tags, {
    Name     = "${var.name}-node${count.index + 1}"
    customer = var.name
    service  = "db"
    },
  )
}


#________________
#### Outputs ####
output "a1-aurora_cluster_writer_endpoint_p" { value = aws_rds_cluster.primary.endpoint }
output "a2-aurora_cluster_reader_endpoint_p" { value = aws_rds_cluster.primary.reader_endpoint }
# output "a3-aurora_cluster_instance_endpoints_p" { value = aws_rds_cluster_instance.primary.*.endpoint }
output "b1-aurora_cluster_writer_endpoint_s" { value = aws_rds_cluster.secondary.endpoint }
output "b2-aurora_cluster_reader_endpoint_s" { value = aws_rds_cluster.secondary.reader_endpoint }
# output "b3-aurora_cluster_instance_endpoints_s" { value = aws_rds_cluster_instance.secondary.*.endpoint }



#data "aws_db_subnet_group" "sg_import1" {
#  provider = aws.secondary
#  name     = "fr-global-subgr"
#}
#output "a-test" { value = resource.random_string.random.id }
# output "c-test" { value = aws_rds_global_cluster.globaldb }
# output "dd-test" { 
#    value = aws_rds_cluster.primary.global_cluster_identifier
#    #sensitive = true
#     }
#output "de-test" { value = aws_rds_cluster.primary.db_cluster_parameter_group_name }
#output "df-test" { value = aws_rds_cluster.primary.db_instance_parameter_group_name }
#output "dg-test" { value = aws_db_parameter_group.aurora_db_parameter_group_p }


#output "e-db_cluster_parameter_group_name-id" { value = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group_p.id }
#output "f-db_cluster_parameter_group_name" { value = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group_p.name }

#output "g-db_instance_parameter_group_name-id" { value = aws_db_parameter_group.aurora_db_parameter_group_p.id }
#output "h-db_instance_parameter_group_name" { value = aws_db_parameter_group.aurora_db_parameter_group_p.name }
#output "i-enabled_cloudwatch_logs_exports" { value = var.enable_logs[*]}
#output "j-enabled_cloudwatch_logs_exports" { value = var.enable_logs}
#output "o04-random_string" { value = random_string.random_id.id }
