terraform {
  cloud {
    organization = "TheInternetBox"

    workspaces {
      name = "internetbox-ci-runner"
    }
  }
}

resource "random_id" "random" {
  byte_length = 20
}

data "aws_caller_identity" "current" {}

module "runners" {
  source                          = "philips-labs/github-runner/aws"
  aws_region                      = var.aws_region
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets

  environment = var.environment
  tags = {
    Project = "TheInternetBox"
  }

  github_app = {
    key_base64     = var.github_app_key_base64
    id             = var.github_app_id
    webhook_secret = random_id.random.hex
  }

  webhook_lambda_zip                = "webhook.zip"
  runner_binaries_syncer_lambda_zip = "runner-binaries-syncer.zip"
  runners_lambda_zip                = "runners.zip"

  enable_organization_runners = true
  runner_extra_labels         = "default,ephemeral"

  # enable workflow labels check
  # runner_enable_workflow_job_labels_check = true

  # enable access to the runners via SSM
  enable_ssm_on_runners = true

  instance_max_spot_price = "1.00"

  # Let the module manage the service linked role
  create_service_linked_role_spot = true

  instance_types = ["c5ad.8xlarge", "c5d.9xlarge", "c5d.12xlarge", "m5.8xlarge", "m5a.8xlarge", "m5ad.8xlarge", "c6i.12xlarge", "c6i.8xlarge", "c5n.9xlarge", "c5ad.16xlarge", "c5ad.12xlarge", "c4.8xlarge", "c5.9xlarge", "c5.12xlarge", "c5.18xlarge", "c5.24xlarge", "c5a.8xlarge", "c5a.12xlarge", "c5a.16xlarge", "c5a.24xlarge"]

  # override delay of events in seconds
  delay_webhook_event = 0

  # Ensure you set the number not too low, each build require a new instance
  runners_maximum_count = 5

  # override scaling down
  # scale_down_schedule_expression = "cron(* * * * ? *)"

  enable_ephemeral_runners = true

  # # Example of simple pool usages
  pool_runner_owner = "TheInternetBox"
  pool_config = [{
    size                = 5
    schedule_expression = "cron(* * * * ? *)"
  }]

  # configure your pre-built AMI
  # enabled_userdata = false
  # ami_filter       = { name = ["github-runner-amzn2-x86_64-2021*"] }
  # ami_owners       = [data.aws_caller_identity.current.account_id]

  # Enable logging
  log_level = "debug"

  volume_size = 60

  # Setup a dead letter queue, by default scale up lambda will kepp retrying to process event in case of scaling error.
  # redrive_policy_build_queue = {
  #   enabled             = true
  #   maxReceiveCount     = 50 # 50 retries every 30 seconds => 25 minutes
  #   deadLetterTargetArn = null
  # }
}
