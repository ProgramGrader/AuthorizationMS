variable "aws_account_id" {
  default = "048962136615"
}

variable "primary_aws_region" {
  default = "us-east-2"
}

variable "secondary_aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "dev"
}

variable "environment_vars" {
  description = "A set of environment variables for the image definition in JSON format"
  type        = list(map(string))
  default     = []
}

variable "image_definition" {
  description = "The URI of the ECS image definition"
  type        = string
  default     = ""
}
########################################
## Variables used for ecr_push module ##
########################################

variable "project_names" {
  type = list(string)
  default = ["scheduleAssignment"] //"queueScheduledAssignment", "deleteScheduledAssignment", "topicStatusLogger"]

}
