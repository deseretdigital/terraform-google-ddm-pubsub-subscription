# Google PubSub Subscription with BigQuery Output

This module create a Google PubSub Subscription that will automagically write to a BigQuery table. 

## Usage

### Basic Configuration:

```hcl
module "pubsub_subscription_module" {
  source  = "deseretdigital/ddm-pubsub-subscription/google//modules/big-query"
  version = "~> 2.0.0"
  
  # Required
  bigquery_table         = {TABLE_NAME}
  pubsub_service_account = "service-{NUMBERS}@gcp-sa-pubsub.iam.gserviceaccount.com"
  subscription_name      = {YOUR_SUBSCRIPTION_NAME}
  topic_id               = {PARENT_TOPIC_ID}

  # Optional
  labels = {
    env    = "prod"
    region = {REGION}
    # etc...
  }

  use_topic_schema = false
}
```

#### Example Usage

This example assumes you are not using the topic schema and instead are using the table schema. You'll need to know this before you go in which schema you will use as your source of truth.

```hcl
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  # Configuration options
}

resource "google_pubsub_topic" "example" {
  name = "Example_TopicName"
}

resource "google_bigquery_dataset" "test" {
  dataset_id = "example_dataset"
}

resource "google_bigquery_table" "test" {
  deletion_protection = false
  table_id            = "example_table"
  dataset_id          = google_bigquery_dataset.test.dataset_id

  schema = <<EOF
[
  {
    "name": "data",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The data"
  }
]
EOF
}


module "pubsub_subscription_module" {
  source  = "deseretdigital/ddm-pubsub-subscription/google//modules/big-query"
  version = "~> 2.0.0"
  
  # Required
  bigquery_table         = "${google_bigquery_table.test.project}.${google_bigquery_table.test.dataset_id}.${google_bigquery_table.test.table_id}"
  pubsub_service_account = "service-{NUMBERS}@gcp-sa-pubsub.iam.gserviceaccount.com"
  subscription_name      = "Example_SubscriptionName"
  topic_id               = google_pubsub_topic.example.id

  # Optional
  labels = {
    env    = "prod"
    region = {REGION}
    # etc...
  }

  use_topic_schema = false # Since we're using the scheme of 'google_bigquery_table.test'
}
```
