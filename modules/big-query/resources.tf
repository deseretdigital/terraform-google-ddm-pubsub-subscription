locals {
  bigquery_table_parts = split(".", var.bigquery_table)
  bigquery_project_id  = local.bigquery_table_parts[0]
  bigquery_dataset_id  = local.bigquery_table_parts[1]
  bigquery_table_id    = local.bigquery_table_parts[2]
}

resource "google_pubsub_subscription" "subscription" {
  name   = var.subscription_name
  topic  = var.topic_id
  labels = var.labels

  bigquery_config {
    use_topic_schema = var.use_topic_schema
    table            = var.bigquery_table
  }

  depends_on = [google_bigquery_table_iam_member.viewer, google_bigquery_table_iam_member.editor]
}

resource "google_bigquery_table_iam_member" "viewer" {
  project    = local.bigquery_project_id
  dataset_id = local.bigquery_dataset_id
  table_id   = local.bigquery_table_id
  role       = "roles/bigquery.metadataViewer"
  member     = "serviceAccount:${var.pubsub_service_account}"
}

resource "google_bigquery_table_iam_member" "editor" {
  project    = local.bigquery_project_id
  dataset_id = local.bigquery_dataset_id
  table_id   = local.bigquery_table_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${var.pubsub_service_account}"
}
