resource "azurecaf_name" "servicebus_subscription" {
  name          = var.settings.name
  resource_type = "azurerm_servicebus_subscription"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_servicebus_subscription" "subscription" {
  name                = azurecaf_name.servicebus_subscription.result
  namespace_name      = var.remote_objects.servicebus_namespace_name
  topic_name          = var.remote_objects.servicebus_topic_name
  resource_group_name = var.remote_objects.resource_group_name
  max_delivery_count  = var.settings.max_delivery_count

  auto_delete_on_idle                       = try(var.settings.auto_delete_on_idle, null)
  default_message_ttl                       = try(var.settings.default_message_ttl, null)
  lock_duration                             = try(var.settings.lock_duration, null)
  dead_lettering_on_message_expiration      = try(var.settings.dead_lettering_on_message_expiration, null)
  dead_lettering_on_filter_evaluation_error = try(var.settings.dead_lettering_on_filter_evaluation_error, null)
  enable_batched_operations                 = try(var.settings.enable_batched_operations, null)
  requires_session                          = try(var.settings.requires_session, null)
  status                                    = try(var.settings.status, null)
  #TODO: to be enhanced for forward_to and forward_dead_lettered_messages_to to use key reference
  forward_to                                = try(var.settings.forward_to.queue_name,var.settings.forward_to.topic_name, null)
  forward_dead_lettered_messages_to         = try(var.settings.forward_to.queue_name,var.settings.forward_to.topic_name, null)
}