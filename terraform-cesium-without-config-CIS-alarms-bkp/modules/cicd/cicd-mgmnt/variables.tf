//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//Data to get current AWS Region
//Data to get account ID

variable "region" {
  type        = string
  description = "default aws region to deploy the resources"
}

variable "profile" {
  type        = string
  description = "Your different aws configuration profile to separate the aws account"
}

variable "environment" {
  type        = string
  description = "Application different environment like dev/qa/prod"
}

variable "project" {
  type        = string
  description = "Your project name"
}

variable "owner" {
  type        = string
  description = "Owner of the terraform modules"
}

# variable "event_type_ids" {
#   type        = list(any)
#   description = "The list of event type to trigger a notification on"
#   default = [
#     # "codepipeline-pipeline-action-execution-succeeded",
#     # "codepipeline-pipeline-action-execution-failed",
#     # "codepipeline-pipeline-action-execution-canceled",
#     # "codepipeline-pipeline-action-execution-started",
#     # "codepipeline-pipeline-stage-execution-started",
#     # "codepipeline-pipeline-stage-execution-succeeded",
#     # "codepipeline-pipeline-stage-execution-resumed",
#     # "codepipeline-pipeline-stage-execution-canceled",
#     # "codepipeline-pipeline-stage-execution-failed",
#     "codepipeline-pipeline-pipeline-execution-failed",
#     "codepipeline-pipeline-pipeline-execution-canceled",
#     "codepipeline-pipeline-pipeline-execution-started",
#     "codepipeline-pipeline-pipeline-execution-resumed",
#     "codepipeline-pipeline-pipeline-execution-succeeded",
#     "codepipeline-pipeline-pipeline-execution-superseded",
#     # "codepipeline-pipeline-manual-approval-failed",
#     # "codepipeline-pipeline-manual-approval-needed",
#     # "codepipeline-pipeline-manual-approval-succeeded"

#   ]
# }

##Used to get values from another modules.

# variable "ecs-pipeline_arn" {
#   type        = string
#   description = "ecs pipeline arn"
# }

# variable "front-back-end-pipeline_arn" {
#   type        = string
#   description = "frontend backend pipeline arn"
# }

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
