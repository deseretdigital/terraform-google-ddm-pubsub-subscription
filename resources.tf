resource "google_pubsub_subscription" "subscription" {
  name   = var.subscription_name
  topic  = var.topic_id
  labels = var.labels

  # Each of these is null by default, which omits the field and leaves GCP's own
  # default in place — so a caller that sets none of them gets exactly the
  # subscription this module produced before they existed.
  message_retention_duration = var.message_retention_duration
  ack_deadline_seconds       = var.ack_deadline_seconds
  filter                     = var.filter

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter_subscription_topic.id
    max_delivery_attempts = var.max_delivery_attempts
  }

  # dynamic, not a plain block with null fields: expiration_policy and
  # retry_policy are blocks rather than attributes, so the only way to express
  # "leave this to GCP" is to not emit the block at all.
  #
  # The empty-string ttl is meaningful and is why the condition tests for null
  # specifically rather than truthiness — "" is how GCP spells "never expire",
  # so it must still emit the block.
  dynamic "expiration_policy" {
    for_each = var.expiration_policy_ttl == null ? [] : [var.expiration_policy_ttl]
    content {
      ttl = expiration_policy.value
    }
  }

  dynamic "retry_policy" {
    for_each = var.retry_policy == null ? [] : [var.retry_policy]
    content {
      minimum_backoff = retry_policy.value.minimum_backoff
      maximum_backoff = retry_policy.value.maximum_backoff
    }
  }

  depends_on = [
    google_pubsub_topic_iam_member.assign_pubsub_publisher
  ]
}

resource "google_pubsub_topic" "dead_letter_subscription_topic" {
  name   = "${var.subscription_name}_DeadLetter"
  labels = var.labels
}

resource "google_pubsub_topic_iam_member" "assign_pubsub_publisher" {
  project = google_pubsub_topic.dead_letter_subscription_topic.project
  topic   = google_pubsub_topic.dead_letter_subscription_topic.id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${var.pubsub_service_account}"
}

resource "google_pubsub_subscription_iam_member" "assign_pubsub_subscriber" {
  subscription = google_pubsub_subscription.subscription.id
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.pubsub_service_account}"
}

resource "google_pubsub_subscription" "dead_letter_subscription" {
  name   = "${var.subscription_name}_DeadLetter"
  topic  = google_pubsub_topic.dead_letter_subscription_topic.id
  labels = var.labels
}
