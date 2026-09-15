## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.5.0, < 8.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 7.46.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_pubsub_subscription.dead_letter_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription.subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription_iam_member.assign_pubsub_subscriber](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_member) | resource |
| [google_pubsub_topic.dead_letter_subscription_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.assign_pubsub_publisher](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ack_deadline_seconds"></a> [ack\_deadline\_seconds](#input\_ack\_deadline\_seconds) | How long Pub/Sub waits for the subscriber to ack before redelivering, in seconds (10-600). Null uses the GCP default of 10s. The DDM subscriptions standard asks that this be set explicitly whenever the handler makes external HTTP calls that could outlive the default before the client library's ack-deadline auto-extension kicks in. | `number` | `null` | no |
| <a name="input_dead_letter_message_retention_duration"></a> [dead\_letter\_message\_retention\_duration](#input\_dead\_letter\_message\_retention\_duration) | How long the auto-created <subscription\_name>\_DeadLetter subscription retains an unacked message. Null inherits message\_retention\_duration, so dead letters do not silently outlive the window configured for the primary subscription. Set it explicitly to diverge — wanting dead letters to live LONGER than the primary is a legitimate choice for an inspection queue, and stating it is better than inheriting it by accident. | `string` | `null` | no |
| <a name="input_expiration_policy_ttl"></a> [expiration\_policy\_ttl](#input\_expiration\_policy\_ttl) | How long the SUBSCRIPTION ITSELF survives with no activity before Pub/Sub DELETES it, as a duration (e.g. '2678400s'). Not to be confused with message\_retention\_duration, which governs messages rather than the subscription. Null keeps the GCP default of 31 days of inactivity; set to "" (empty string) to never expire — the right choice for a subscription whose consumer is expected to be idle for long stretches. Pub/Sub enforces a floor of 1 day on a non-empty ttl; that is documented here rather than validated, because the exact floor was not verified against the API and a wrong constraint would reject a legal value. | `string` | `null` | no |
| <a name="input_filter"></a> [filter](#input\_filter) | An expression matched against message ATTRIBUTES (never the body); only matching messages are delivered. Null delivers everything. Lets several consumers share one topic without each receiving and discarding the others' traffic. NOTE: GCP treats this as immutable — changing it destroys and recreates the subscription, which drops any unacked backlog. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A set of key/value label pairs to assign to this Topic. | `map(string)` | `{}` | no |
| <a name="input_max_delivery_attempts"></a> [max\_delivery\_attempts](#input\_max\_delivery\_attempts) | The maximum number of delivery attempts for any message. The value must be between 5 and 100. | `number` | `100` | no |
| <a name="input_message_retention_duration"></a> [message\_retention\_duration](#input\_message\_retention\_duration) | How long Pub/Sub retains an UNACKED message before dropping it, as a duration (e.g. '600s'). Null uses the GCP default of 7 days. Valid range is 10 minutes (600s) to 7 days (604800s), or up to 31 days where extended retention is enabled. Short values suit a consumer reacting in real time, where a message old enough to have been missed is no longer worth acting on. | `string` | `null` | no |
| <a name="input_pubsub_service_account"></a> [pubsub\_service\_account](#input\_pubsub\_service\_account) | The service account to be used by the Pub/Sub system. Looks like 'service-<project-number>@gcp-sa-pubsub.iam.gserviceaccount.com'. | `string` | n/a | yes |
| <a name="input_retry_policy"></a> [retry\_policy](#input\_retry\_policy) | Exponential backoff applied between redelivery attempts. Null uses the GCP default (immediate redelivery). The DDM subscriptions standard asks that this be set explicitly alongside ack\_deadline\_seconds for handlers that call external services, so a transient downstream failure backs off instead of hot-looping toward the dead-letter threshold. | <pre>object({<br/>    minimum_backoff = string<br/>    maximum_backoff = string<br/>  })</pre> | `null` | no |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | The name of the subscription. | `string` | n/a | yes |
| <a name="input_topic_id"></a> [topic\_id](#input\_topic\_id) | A reference to a Topic resource, of the form projects/{project}/topics/{{name}} (as in the id property of a google\_pubsub\_topic), or just a topic name if the topic is in the same project as the subscription. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | The ID of the created subscription. |
| <a name="output_subscription_name"></a> [subscription\_name](#output\_subscription\_name) | The name of the created subscription. |