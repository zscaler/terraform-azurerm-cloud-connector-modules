# Cloud Connector with Gateway Load Balancer (VMSS) — Brownfield

Deploys Cloud Connector Virtual Machine Scale Sets (VMSS) into an existing or new VNet, registered into an Azure Gateway Load Balancer (GWLB) backend pool for transparent inline ingress inspection.

This template combines the auto-scaling characteristics of `cc_vmss` (Flexible Orchestration VMSS + Function App for lifecycle management) with the inline ingress inspection of `cc_gwlb` (GWLB + dual VXLAN tunnel interfaces + optional consumer Public LB chained to the GWLB frontend).

## What this template creates

- `module "network"`        — RG / VNet / subnets / NAT GW (or references existing via the `byo_*` inputs)
- `module "cc_vmss"`        — Flexible Orchestration VMSS for Cloud Connectors (one per zone when `zones_enabled = true`)
- `module "cc_functionapp"` — Function App + Storage / App Insights for VMSS lifecycle (metric scaling, scheduled scaling, unhealthy-instance termination)
- `module "cc_nsg"`         — single shared NSG (mgmt + service) with `gwlb_enabled = true`; supports `byo_nsg`
- `module "cc_identity"`    — references to user-assigned Managed Identities (CC + Function App)
- `module "cc_gwlb"`        — Azure Gateway Load Balancer (`Gateway` SKU) with VXLAN tunnel interfaces
- `module "cc_public_lb"`   — optional consumer Public LB auto-chained to the GWLB frontend (set `create_consumer_public_lb = true`)

## When to use this vs the other examples

| Topology      | Brownfield VMs | Brownfield VMSS    |
|---------------|----------------|--------------------|
| Private LB    | `cc_lb`        | `cc_vmss`          |
| Gateway LB    | `cc_gwlb`      | **`cc_gwlb_vmss`** |

Use `cc_gwlb_vmss` when you need:

- **Inline ingress inspection** of traffic destined for backend workloads (GWLB transparent mode), **and**
- **Elastic / auto-scaling Cloud Connector capacity** (VMSS + Function App), **and**
- An **existing VNet / RG / NAT GW** (brownfield — use `base_cc_gwlb_vmss` for greenfield)

## Brownfield (`byo_*`) inputs

This example exposes the full set of `byo_*` inputs in line with `cc_vmss` and `cc_gwlb`:

- **Network:** `byo_rg`, `byo_vnet`, `byo_subnets`, `byo_pip`, `byo_nat_gw`, plus the `existing_*_association` flags
- **NSG:** `byo_nsg`, `byo_nsg_rg`, `byo_mgmt_nsg_names`, `byo_service_nsg_names`
- **Managed Identity:** `cc_vm_managed_identity_name` / `cc_vm_managed_identity_rg`, and the separate `function_app_managed_identity_name` / `function_app_managed_identity_rg`
- **Storage / Logs:** `existing_storage_account*`, `existing_log_analytics_workspace*`

See `variables.tf` for the complete list with defaults and `terraform.tfvars` for an annotated sample.

## Chaining the GWLB to your own Public LB

If you set `create_consumer_public_lb = false`, this template only provisions the GWLB. To activate ingress inspection you must chain your existing Public LB frontend IP configuration to the GWLB frontend. Take the `gwlb_frontend_ip_config_id` output and attach it via Azure CLI:

```bash
az network lb frontend-ip update \
  --resource-group <rg> \
  --lb-name <public_lb_name> \
  --name <frontend_ip_config_name> \
  --gateway-lb <gwlb_frontend_ip_config_id>
```

Or via Azure Portal: **PLB → Frontend IP configurations → Edit → Gateway Load Balancer → paste the ID → Save**.

## See also

- `examples/base_cc_gwlb_vmss/` — greenfield equivalent with bastion + test workload
- `examples/cc_gwlb/` — brownfield GWLB with fixed-count CC VMs (no VMSS)
- `examples/cc_vmss/` — brownfield VMSS with Private LB (no GWLB)
