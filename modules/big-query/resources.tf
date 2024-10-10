resource "google_pubsub_subscription" "subscription" {
  name   = var.subscription_name
  topic  = var.topic_id
  labels = var.labels

  bigquery_config {
    use_topic_schema = var.use_topic_schema
    table            = var.bigquery_table
  }

  depends_on = [google_project_iam_member.viewer, google_project_iam_member.editor]
}

resource "google_project_iam_member" "viewer" {
  project = data.google_project.project.project_id
  role    = "roles/bigquery.metadataViewer"
  member  = "serviceAccount:${var.pubsub_service_account}"
}

resource "google_project_iam_member" "editor" {
  project = data.google_project.project.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${var.pubsub_service_account}"
}
