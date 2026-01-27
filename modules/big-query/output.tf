output "subscription_id" {
  value       = google_pubsub_subscription.subscription.id
  description = "The ID of the created subscription."
}

output "subscription_name" {
  value       = google_pubsub_subscription.subscription.name
  description = "The name of the created subscription."
}

output "dead_letter_topic_id" {
  value       = google_pubsub_topic.dead_letter_topic.id
  description = "The ID of the dead letter topic."
}

output "dead_letter_topic_name" {
  value       = google_pubsub_topic.dead_letter_topic.name
  description = "The name of the dead letter topic."
}

output "dead_letter_subscription_id" {
  value       = google_pubsub_subscription.dead_letter_subscription.id
  description = "The ID of the dead letter subscription."
}

output "dead_letter_subscription_name" {
  value       = google_pubsub_subscription.dead_letter_subscription.name
  description = "The name of the dead letter subscription."
}