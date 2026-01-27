variable "bigquery_table" {
  description = "The name of the table to which to write data, of the form {projectId}.{datasetId}.{tableId}"
  type        = string

  validation {
    condition     = can(regex("^[^\\.]+\\.[^\\.]+\\.[^\\.]+$", var.bigquery_table))
    error_message = "Value must be a valid BigQuery table name."
  }
}

variable "labels" {
  description = "A set of key/value label pairs to assign to this Topic."
  type        = map(string)
  default     = {}
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

variable "use_topic_schema" {
  description = "When true, use the topic's schema as the columns to write to in BigQuery, if it exists."
  type        = bool
  default     = false
}

variable "max_delivery_attempts" {
  default     = 10
  description = "The maximum number of delivery attempts for any message. The value must be between 5 and 100."
  type        = number

  validation {
    condition     = var.max_delivery_attempts >= 5 && var.max_delivery_attempts <= 100
    error_message = "Value must be between 5 and 100."
  }
}