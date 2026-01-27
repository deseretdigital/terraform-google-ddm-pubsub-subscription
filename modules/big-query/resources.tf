resource "google_pubsub_subscription" "subscription" {
  name   = var.subscription_name
  topic  = var.topic_id
  labels = var.labels

  bigquery_config {
    use_topic_schema = var.use_topic_schema
    table            = var.bigquery_table
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter_topic.id
    max_delivery_attempts = var.max_delivery_attempts
  }

  depends_on = [
    google_project_iam_member.viewer,
    google_project_iam_member.editor,
    google_pubsub_topic_iam_member.dead_letter_publisher
  ]
}

# Dead Letter Queue Topic
resource "google_pubsub_topic" "dead_letter_topic" {
  name   = "${var.subscription_name}_DeadLetter"
  labels = var.labels
}

# Dead Letter Queue Subscription
resource "google_pubsub_subscription" "dead_letter_subscription" {
  name   = "${var.subscription_name}_DeadLetter"
  topic  = google_pubsub_topic.dead_letter_topic.id
  labels = var.labels
}

# IAM: Allow Pub/Sub to publish to DLQ
resource "google_pubsub_topic_iam_member" "dead_letter_publisher" {
  project = google_pubsub_topic.dead_letter_topic.project
  topic   = google_pubsub_topic.dead_letter_topic.id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${var.pubsub_service_account}"
}

# IAM: Allow Pub/Sub to acknowledge messages from main subscription
resource "google_pubsub_subscription_iam_member" "subscriber" {
  subscription = google_pubsub_subscription.subscription.id
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.pubsub_service_account}"
}

# IAM: Allow Pub/Sub to read BigQuery table metadata
resource "google_project_iam_member" "viewer" {
  project = data.google_project.project.project_id
  role    = "roles/bigquery.metadataViewer"
  member  = "serviceAccount:${var.pubsub_service_account}"
}

# IAM: Allow Pub/Sub to write to BigQuery table
resource "google_project_iam_member" "editor" {
  project = data.google_project.project.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${var.pubsub_service_account}"
}
