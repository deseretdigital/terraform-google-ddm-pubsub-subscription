## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription.subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bigquery_table"></a> [bigquery\_table](#input\_bigquery\_table) | The name of the table to which to write data, of the form {projectId}.{datasetId}.{tableId} | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | A set of key/value label pairs to assign to this Topic. | `map(string)` | `{}` | no |
| <a name="input_pubsub_service_account"></a> [pubsub\_service\_account](#input\_pubsub\_service\_account) | The service account to be used by the Pub/Sub system. Looks like 'service-<project-number>@gcp-sa-pubsub.iam.gserviceaccount.com'. | `string` | n/a | yes |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | The name of the subscription. | `string` | n/a | yes |
| <a name="input_topic_id"></a> [topic\_id](#input\_topic\_id) | A reference to a Topic resource, of the form projects/{project}/topics/{{name}} (as in the id property of a google\_pubsub\_topic), or just a topic name if the topic is in the same project as the subscription. | `string` | n/a | yes |
| <a name="input_use_topic_schema"></a> [use\_topic\_schema](#input\_use\_topic\_schema) | When true, use the topic's schema as the columns to write to in BigQuery, if it exists. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | The ID of the created subscription. |
| <a name="output_subscription_name"></a> [subscription\_name](#output\_subscription\_name) | The name of the created subscription. |