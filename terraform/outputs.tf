output "frontend_home_url" {
  value       = "http://${azurerm_public_ip.frontend-public-ip.ip_address}/"
}

output "frontend_health_url" {
  value       = "http://${azurerm_public_ip.frontend-public-ip.ip_address}/health"
}

output "frontend_ready_url" {
  value       = "http://${azurerm_public_ip.frontend-public-ip.ip_address}/ready"
}

output "frontend_items_url" {
  value       = "http://${azurerm_public_ip.frontend-public-ip.ip_address}/items"
}

output "ssh_frontend_example" {
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.frontend-public-ip.ip_address}"
}

output "frontend_public_ip" {
  value       = azurerm_public_ip.frontend-public-ip.ip_address
}

output "backend_private_ip" {
  value       = local.backend_private_ip
}

output "database_host_private" {
  value       = local.database_private_ip
}

output "database_name" {
  value       = var.database_name
}

output "database_user" {
  value       = var.database_user
}

output "database_url_application" {
  value       = local.database_url
  sensitive   = true
}
