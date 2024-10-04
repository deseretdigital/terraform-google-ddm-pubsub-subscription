resource "google_pubsub_subscription" "subscription" {
  name  = var.subscription_name
  topic = var.topic_id

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter_topic.id
    max_delivery_attempts = var.max_delivery_attempts
  }
}

resource "google_pubsub_topic" "dead_letter_topic" {
  name   = "${var.topic_name}_DeadLetter"
  labels = var.labels
}

resource "google_pubsub_subscription" "dead_letter_subscription" {
  name  = "${var.subscription_name}_DeadLetter"
  topic = google_pubsub_topic.dead_letter_topic.id
}
