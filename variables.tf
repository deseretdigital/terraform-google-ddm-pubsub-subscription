variable "labels" {
  description = "A set of key/value label pairs to assign to this Topic."
  type        = map(string)
  default     = {}
}

variable "max_delivery_attempts" {
  default     = 100
  description = "The maximum number of delivery attempts for any message. The value must be between 5 and 100."
  type        = number

  validation {
    condition     = var.max_delivery_attempts >= 5 && var.max_delivery_attempts <= 100
    error_message = "Value must be between 5 and 100."
  }
}

variable "message_retention_duration" {
  default     = "2678400s"
  description = "Indicates the minimum duration to retain a message after it is published to the topic. If this field is set, messages published to the topic in the last messageRetentionDuration are always available to subscribers. For instance, it allows any attached subscription to seek to a timestamp that is up to messageRetentionDuration in the past. If this field is not set, message retention is controlled by settings on individual subscriptions."
  type        = string

  validation {
    condition     = can(regex("^\\d+s$", var.message_retention_duration))
    error_message = "Value must be a duration represented in seconds. Example: 86400s"
  }
}

variable "pubsub_service_account" {
  description = "The service account to be used by the Pub/Sub system. Looks like 'service-<project-number>@gcp-sa-pubsub.iam.gserviceaccount.com'."
  type        = string
  validation {
    condition     = can(regex("^service-\\d+@gcp-sa-pubsub\\.iam\\.gserviceaccount\\.com$", var.pubsub_service_account))
    error_message = "value must be a valid service account email address."
  }
}

variable "subscription_name" {
  description = "The name of the subscription."
  type        = string
}

variable "topic_id" {
  description = " A reference to a Topic resource, of the form projects/{project}/topics/{{name}} (as in the id property of a google_pubsub_topic), or just a topic name if the topic is in the same project as the subscription."
  type        = string

  validation {
    condition     = can(regex("projects/[^/]+/topics/[^/]+", var.topic_id))
    error_message = "value must be a reference to a Topic resource, of the form projects/{project}/topics/{{name}}."
  }
}
