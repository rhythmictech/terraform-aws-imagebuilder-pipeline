########################################
# General Vars
########################################
variable "additional_tags" {
  default     = {}
  description = "Additional tags to add to supported resources"
  type        = map(string)
}
