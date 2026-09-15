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
  # Default is null, not the "2678400s" this variable used to declare. Until now
  # the value was never wired into the subscription, so every caller silently got
  # GCP's 7-day default no matter what they passed. Defaulting to null preserves
  # that ACTUAL behavior for callers who never set it, while callers who do set it
  # now get what they asked for instead of being ignored. Defaulting to the old
  # declared 2678400s would instead have quietly stretched every existing
  # subscription from 7 to 31 days of retention on its next apply.
  default     = null
  description = "How long Pub/Sub retains an UNACKED message before dropping it, as a duration (e.g. '600s'). Null uses the GCP default of 7 days. Valid range is 10 minutes (600s) to 7 days (604800s), or up to 31 days where extended retention is enabled. Short values suit a consumer reacting in real time, where a message old enough to have been missed is no longer worth acting on."
  type        = string

  validation {
    condition     = var.message_retention_duration == null || can(regex("^\\d+s$", var.message_retention_duration))
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

variable "ack_deadline_seconds" {
  description = "How long Pub/Sub waits for the subscriber to ack before redelivering, in seconds (10-600). Null uses the GCP default of 10s. The DDM subscriptions standard asks that this be set explicitly whenever the handler makes external HTTP calls that could outlive the default before the client library's ack-deadline auto-extension kicks in."
  type        = number
  default     = null

  validation {
    condition     = var.ack_deadline_seconds == null || (var.ack_deadline_seconds >= 10 && var.ack_deadline_seconds <= 600)
    error_message = "Value must be between 10 and 600 seconds."
  }
}

variable "filter" {
  description = "An expression matched against message ATTRIBUTES (never the body); only matching messages are delivered. Null delivers everything. Lets several consumers share one topic without each receiving and discarding the others' traffic. NOTE: GCP treats this as immutable — changing it destroys and recreates the subscription, which drops any unacked backlog."
  type        = string
  default     = null
}

variable "expiration_policy_ttl" {
  description = "How long the SUBSCRIPTION ITSELF survives with no activity before Pub/Sub DELETES it, as a duration (e.g. '2678400s'). Not to be confused with message_retention_duration, which governs messages rather than the subscription. Null keeps the GCP default of 31 days of inactivity; set to \"\" (empty string) to never expire — the right choice for a subscription whose consumer is expected to be idle for long stretches."
  type        = string
  default     = null

  validation {
    condition     = var.expiration_policy_ttl == null || var.expiration_policy_ttl == "" || can(regex("^\\d+s$", var.expiration_policy_ttl))
    error_message = "Value must be empty (never expire) or a duration represented in seconds. Example: 2678400s"
  }
}

variable "retry_policy" {
  description = "Exponential backoff applied between redelivery attempts. Null uses the GCP default (immediate redelivery). The DDM subscriptions standard asks that this be set explicitly alongside ack_deadline_seconds for handlers that call external services, so a transient downstream failure backs off instead of hot-looping toward the dead-letter threshold."
  type = object({
    minimum_backoff = string
    maximum_backoff = string
  })
  default = null

  validation {
    condition     = var.retry_policy == null || can(regex("^\\d+(\\.\\d+)?s$", var.retry_policy.minimum_backoff))
    error_message = "retry_policy.minimum_backoff must be a duration in seconds. Example: 10s"
  }

  validation {
    condition     = var.retry_policy == null || can(regex("^\\d+(\\.\\d+)?s$", var.retry_policy.maximum_backoff))
    error_message = "retry_policy.maximum_backoff must be a duration in seconds. Example: 600s"
  }
}
