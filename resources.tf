resource "google_pubsub_subscription" "subscription" {
  name   = var.subscription_name
  topic  = var.topic_id
  labels = var.labels

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter_subscription_topic.id
    max_delivery_attempts = var.max_delivery_attempts
  }
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
