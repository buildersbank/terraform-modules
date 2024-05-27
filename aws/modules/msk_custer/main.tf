resource "random_password" "password" {
  length           = 16
  special          = false
}

module "msk_cluster" {
  source = "terraform-aws-modules/msk-kafka-cluster/aws"

  name                   = var.name
  kafka_version          = var.msk_kafka_version
  number_of_broker_nodes = var.number_of_brokers
  enhanced_monitoring    = "PER_TOPIC_PER_PARTITION"

  broker_node_client_subnets = var.subnet_ids
  broker_node_storage_info = {
    ebs_storage_info = { volume_size = "${var.broker_volume_size}" }
  }

  scaling_max_capacity = var.max_scaling_volume
  scaling_target_value = var.scaling_target

  broker_node_instance_type   = var.broker_instance_type
  broker_node_security_groups = [module.broker_security_group.security_group_id]

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true

  configuration_name        = "${var.name}-configuration"
  configuration_description = "Basic Configuration of the cluster"
  configuration_server_properties = {
    "auto.create.topics.enable" = true
    "delete.topic.enable"       = true
  }

  jmx_exporter_enabled    = var.jmx_enabled
  node_exporter_enabled   = var.node_enabled
  cloudwatch_logs_enabled = true
  s3_logs_enabled         = false

  client_authentication = {
    sasl = { scram = true }
  }

  create_scram_secret_association = true
  scram_secret_association_secret_arn_list = [
    module.secrets_manager.secret_arn
  ]

  tags = {
    environment = var.environment
  }

  depends_on = [module.broker_security_group, module.secrets_manager]

}

module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  # Secret
  name_prefix             = "AmazonMSK_${var.name}_"
  description             = "Secrets Generated by MSK Cluster"
  recovery_window_in_days = 30

  # Policy
  create_policy         = false
  block_public_policy   = true
  ignore_secret_changes = false
  kms_key_id            = module.kms.key_arn
  secret_string = jsonencode({
    "username": "kafka",
    "password": "${random_password.password.result}"
  })
  tags = {
    environment = var.environment
  }

  depends_on = [module.kms]
}

module "kms" {
  source = "terraform-aws-modules/kms/aws"

  description = "Used by MSK Secrets Manager"
  key_usage   = "ENCRYPT_DECRYPT"

  # Policy
  key_administrators = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/kafka.amazonaws.com/AWSServiceRoleForKafka"]

  # Aliases
  aliases = ["msk/${var.name}"]
  aliases_use_name_prefix = false

  tags = {
    environment = var.environment
  }
}

module "broker_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.name}-msk-security-group"
  description = "Security group for MSK Cluster"
  vpc_id      = var.vpc_id

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 9092
      to_port                  = 9092
      protocol                 = "tcp"
      description              = "Allow security groups to MSK Cluster"
      source_security_group_id = var.source_security_group_id_allowed
    },
    {
      from_port                = 9094
      to_port                  = 9094
      protocol                 = "tcp"
      description              = "Allow security groups to MSK Cluster"
      source_security_group_id = var.source_security_group_id_allowed
    },
    {
      from_port                = 9096
      to_port                  = 9096
      protocol                 = "tcp"
      description              = "Allow security groups to MSK Cluster"
      source_security_group_id = var.source_security_group_id_allowed
    },
    {
      from_port                = 9196
      to_port                  = 9196
      protocol                 = "tcp"
      description              = "Allow security groups to MSK Cluster"
      source_security_group_id = var.source_security_group_id_allowed
    },
  ]

  tags = {
    environment = var.environment
  }

}


