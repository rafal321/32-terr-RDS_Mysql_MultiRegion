locals {
  mysql_cluster_pgroup_params = [{
    name         = "auto_increment_increment"
    value        = 1
    apply_method = "immediate"
    }, {
    name         = "auto_increment_offset"
    value        = 1
    apply_method = "immediate"
    }, {
    name         = "binlog_gtid_simple_recovery"
    value        = 1
    apply_method = "pending-reboot"
    }, {
    name         = "character_set_database"
    value        = "utf8"
    apply_method = "immediate"
    }, {
    name         = "character_set_server"
    value        = "utf8"
    apply_method = "immediate"
    }, {
    name         = "enforce_gtid_consistency"
    value        = "ON"
    apply_method = "pending-reboot"
    }, {
    name         = "gtid-mode"
    value        = "ON"
    apply_method = "pending-reboot"
    }, {
    name         = "innodb_default_row_format"
    value        = "DYNAMIC"
    apply_method = "immediate"
    }, {
    name         = "innodb_file_format"
    value        = "Barracuda"
    apply_method = "immediate"
    }, {
    name         = "innodb_flush_log_at_trx_commit"
    value        = 1
    apply_method = "immediate"
    }, {
    name         = "innodb_large_prefix"
    value        = 1
    apply_method = "immediate"
    }, {
    name         = "log_bin_trust_function_creators"
    value        = 1
    apply_method = "immediate"
    }, {
    name         = "long_query_time"
    value        = 5
    apply_method = "immediate"
    }, {
    name         = "lower_case_table_names"
    value        = 1
    apply_method = "pending-reboot"
    }, {
    name         = "max_allowed_packet"
    value        = 1073741824
    apply_method = "immediate"
    }, {
    name         = "performance_schema"
    value        = 1
    apply_method = "pending-reboot"
    }, {
    name         = "slow_query_log"
    value        = 1
    apply_method = "immediate"
    }, {
    name         = "time_zone"
    value        = "UTC"
    apply_method = "immediate"
  }]

  mysql_db_pgroup_params = [{
    name         = "event_scheduler"
    value        = "ON"
    apply_method = "immediate"
    }, {
    name         = "log_bin_trust_function_creators"
    value        = 1
    apply_method = "immediate"
  }]
}
