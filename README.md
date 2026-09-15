# Google PubSub Subscription with Dead Letter

This module create a Google PubSub Subscription as as well as a Topic/Subscription for Dead Letters. 

We found that in order to follow the documentation for the provider, we were constantly having to create a ton of resources which increased the potential for mistakes. This module helps make sure it's more streamlined in our environment. 

## Usage

### Basic Configuration:

```hcl
module "pubsub_subscription_module" {
  source  = "deseretdigital/ddm-pubsub-subscription/google"
  version = "~> 2.0.0"
  
  # Required
  pubsub_service_account = {GKE_PUBSUB_SA_EMAIL}
  subscription_name      = {YOUR_SUBSCRIPTION_NAME}
  topic_id               = {PARENT_TOPIC_ID}

  # Optional
  labels = {
    env    = "prod"
    region = {REGION}
    # etc...
  }

  max_delivery_attempts      = {DEFAULT_100}

  # All optional. Omitted means "leave GCP's own default alone".
  message_retention_duration = {DEFAULT_null_meaning_GCP_7_days}
  ack_deadline_seconds       = {DEFAULT_null_meaning_GCP_10s}
  filter                     = {DEFAULT_null_meaning_deliver_everything}
  expiration_policy_ttl      = {DEFAULT_null_meaning_GCP_31_days_idle}
  retry_policy               = {DEFAULT_null_meaning_immediate_redelivery}
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
  version                = "~> 2.0.0"
  pubsub_service_account = "service-{NUMBERS}@gcp-sa-pubsub.iam.gserviceaccount.com"
  subscription_name      = "Example_SubscriptionName"
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

#### Tuning delivery

Every option below is optional, and omitting it leaves GCP's own default in
place — so an existing module call that sets none of them is unaffected.

```hcl
module "pubsub_subscription_module" {
  source = "deseretdigital/ddm-pubsub-subscription/google"
  # Two-part constraint per platform/terraform/modules.md: patch and minor reach
  # you without a PR, a major does not. A three-part `~> 2.2.0` would pin to
  # patch-only and silently stop receiving minor releases.
  version                = "~> 2.2"
  pubsub_service_account = "service-{NUMBERS}@gcp-sa-pubsub.iam.gserviceaccount.com"
  subscription_name      = "Example_SubscriptionName"
  topic_id               = google_pubsub_topic.example.id
  max_delivery_attempts  = 10

  # Drop an unacked message after 10 minutes (GCP's minimum). Suits a consumer
  # reacting in real time, where a message old enough to have been missed is no
  # longer worth acting on. Default is GCP's 7 days.
  message_retention_duration = "600s"

  # Deliver only messages whose ATTRIBUTES match, so several consumers can share
  # one topic without each receiving and discarding the others' traffic.
  # NOTE: immutable in GCP — changing it recreates the subscription and drops
  # any unacked backlog.
  filter = "attributes.channel = \"github\""

  # Give the handler longer than GCP's 10s default to ack.
  ack_deadline_seconds = 30

  # Back off between redeliveries instead of hot-looping a transient downstream
  # failure toward the dead-letter threshold.
  retry_policy = {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  # Never delete the subscription for inactivity. GCP's default DELETES it after
  # 31 days idle — worth setting for a consumer that can be idle that long.
  expiration_policy_ttl = ""
}
```

#### The dead-letter subscription

`message_retention_duration` and `expiration_policy_ttl` apply to the auto-created
`<subscription_name>_DeadLetter` subscription as well as to the primary one — otherwise
setting either would be honored on one of the two subscriptions this module creates and
silently ignored on the other.

Retention on the DLQ **inherits** the primary's value. A short window is often chosen for
data minimization, and a dead letter is by definition a message that already failed —
frequently the malformed or unexpected payload — so keeping a copy for a week after the
primary dropped it is rarely what was intended.

Override it when you want the opposite, which is a legitimate thing to want: this is the
inspection queue for incident response, and dead letters outliving the primary is a
defensible choice. It just reads better stated than inherited.

```hcl
  message_retention_duration            = "600s"    # primary: 10 minutes
  dead_letter_message_retention_duration = "604800s" # dead letters: keep a week to investigate
```

Setting neither leaves both at GCP's defaults, unchanged.
