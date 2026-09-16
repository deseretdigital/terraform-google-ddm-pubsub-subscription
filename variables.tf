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

  # Floor only, deliberately no ceiling. 600s is Pub/Sub's hard minimum and
  # anything under it is always rejected, so catching it at plan time is free.
  # The upper bound is NOT enforced: the ordinary maximum is 7 days, but a topic
  # with extended retention enabled accepts up to 31 days, and this module cannot
  # see the topic's configuration to tell which applies. A ceiling here would
  # reject a value that is legal for the caller's topic.
  validation {
    condition     = var.message_retention_duration == null || tonumber(trimsuffix(var.message_retention_duration, "s")) >= 600
    error_message = "message_retention_duration must be at least 600s (10 minutes), the Pub/Sub minimum."
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
  description = "How long the SUBSCRIPTION ITSELF survives with no activity before Pub/Sub DELETES it, as a duration (e.g. '2678400s'). Not to be confused with message_retention_duration, which governs messages rather than the subscription. Null keeps the GCP default of 31 days of inactivity; set to \"\" (empty string) to never expire — the right choice for a subscription whose consumer is expected to be idle for long stretches. Pub/Sub enforces a floor of 1 day on a non-empty ttl; that is documented here rather than validated, because the exact floor was not verified against the API and a wrong constraint would reject a legal value."
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

  # Ordering and ceiling are checked here, not left to the API. A module's
  # validation failure is cheap — it happens at plan time; the API's is not, as
  # the root module is mid-apply by then and this module has already created its
  # dead-letter topic and IAM member, so a rejected value means fix-and-reapply
  # rather than edit-and-re-plan.
  validation {
    condition = var.retry_policy == null || (
      can(regex("^\\d+(\\.\\d+)?s$", var.retry_policy.minimum_backoff)) &&
      can(regex("^\\d+(\\.\\d+)?s$", var.retry_policy.maximum_backoff)) &&
      tonumber(trimsuffix(var.retry_policy.minimum_backoff, "s")) <= tonumber(trimsuffix(var.retry_policy.maximum_backoff, "s"))
    )
    error_message = "retry_policy.minimum_backoff must be less than or equal to maximum_backoff."
  }

  validation {
    condition = var.retry_policy == null || (
      can(regex("^\\d+(\\.\\d+)?s$", var.retry_policy.maximum_backoff)) &&
      tonumber(trimsuffix(var.retry_policy.maximum_backoff, "s")) <= 600
    )
    error_message = "retry_policy.maximum_backoff must be at most 600s (the Pub/Sub maximum)."
  }
}

variable "dead_letter_message_retention_duration" {
  description = "How long the auto-created <subscription_name>_DeadLetter subscription retains an unacked message. Null inherits message_retention_duration, so dead letters do not silently outlive the window configured for the primary subscription. Set it explicitly to diverge — wanting dead letters to live LONGER than the primary is a legitimate choice for an inspection queue, and stating it is better than inheriting it by accident."
  type        = string
  default     = null

  validation {
    condition     = var.dead_letter_message_retention_duration == null || can(regex("^\\d+s$", var.dead_letter_message_retention_duration))
    error_message = "Value must be a duration represented in seconds. Example: 604800s"
  }

  validation {
    condition     = var.dead_letter_message_retention_duration == null || tonumber(trimsuffix(var.dead_letter_message_retention_duration, "s")) >= 600
    error_message = "dead_letter_message_retention_duration must be at least 600s (10 minutes), the Pub/Sub minimum."
  }
}
