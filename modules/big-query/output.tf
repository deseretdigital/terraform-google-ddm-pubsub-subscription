output "subscription_id" {
  value       = google_pubsub_subscription.subscription.id
  description = "The ID of the created subscription."
}

output "subscription_name" {
  value       = google_pubsub_subscription.subscription.name
  description = "The name of the created subscription."
}