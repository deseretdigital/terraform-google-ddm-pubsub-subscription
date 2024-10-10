# Google PubSub Subscription

This module create a Google PubSub Subscription as as well as a Topic/Subscription for Dead Letters. 

We found that in order to follow the documentation for the provider, we were constantly having to create a ton of resources which increased the potential for mistakes. This module helps make sure it's more streamlined in our environment. 

## Usage

### Basic Configuration:

```hcl
module "ddm-pubsub-subscription" {
  source  = "deseretdigital/ddm-pubsub-subscription/google"
  version = "1.0.0"
  
  # Required
  pubsub_service_account = {GKE_PUBSUB_SA_EMAIL}
  subscription_name      = {YOUR_SUBSCRIPTION_NAME}
  topic_id               = {PARENT_TOPIC_ID}
  topic_name             = {PARENT_TOPIC_NAME}

  # Optional
  labels = {
    env    = "prod"
    region = {REGION}
    # etc...
  }

  max_delivery_attempts      = {DEFAULT_100}
  message_retention_duration = {DEFAULT_2678400s}
}
```

This module creates a Google PubSub Subscription, a Google PubSub Topic for the dead letter messages, and a Google PubSub Subscription for the dead letters. It also applies the correct IAM bindings for the dead letter topic and subscription. 

#### Example Usage

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

module "pubsub_subscription_module" {
  source                 = "deseretdigital/ddm-pubsub-subscription/google"
  version                = "~> 1.0.0"
  pubsub_service_account = "service-{NUMBERS}@gcp-sa-pubsub.iam.gserviceaccount.com"
  subscription_name      = "Example_SubscriptionName"
  topic_name             = google_pubsub_topic.example.name
  topic_id               = google_pubsub_topic.example.id
  
  labels = {
    date   = "2024-10-08"
    region = "us-west3"
    env    = "prod"
  }

  max_delivery_attempts      = 10
  message_retention_duration = "84000s"
}
```
