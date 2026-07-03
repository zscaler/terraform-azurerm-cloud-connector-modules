# cc_public_lb — Brownfield: CC VMs + Standalone Public LB + ILB (BYO VNet)

This example deploys Cloud Connector VMs with a **standalone Public Load Balancer (PLB)** and a downstream **Internal Load Balancer (ILB)** into an **existing (BYO) Azure VNet**. It implements the routed-mode ingress topology where the PLB fronts inbound internet traffic, CC VMs perform ZIA inspection, and the ILB steers return traffic back through the CCs to downstream workloads.

> **Greenfield variant:** See [`base_cc_public_lb`](../base_cc_public_lb) for a version that creates all network infrastructure (VNet, subnets, NAT GW) automatically.

---

## Topology

```
Internet
    │
    ▼
Public Load Balancer (PLB)
  • Public IP frontend
  • disable_outbound_snat = true  ← preserves client IP for CC DNAT
  • Standard SKU, TCP 80/443 rules (customisable via var.public_lb_rules)
    │
    ▼
CC VM Service NICs  (backend pool of PLB)
  • CC performs DNAT: PLB frontend IP → workload destination
  • CC performs SNAT: uses ILB frontend IP as source for return path
    │
    ▼
Internal Load Balancer (ILB)
  • Private IP frontend on CC subnet
  • Protocol = All, ports 0/0, enable_floating_ip = true
  • Workload route tables: 0.0.0.0/0 → ILB frontend IP
    │
    ▼
Downstream Workloads
```

### Key design points

| Component | Setting | Reason |
|-----------|---------|--------|
| PLB | `disable_outbound_snat = true` | Preserves original client IP so CC can DNAT correctly |
| PLB | `enable_floating_ip = true` | CC receives the PLB frontend IP directly for DNAT |
| ILB | `enable_floating_ip = true` | CC uses ILB frontend IP as SNAT source for return traffic |
| ILB | Protocol = All, ports 0/0 | HA ports rule — passes all traffic to CC |

### CC-side configuration (outside Terraform)

The following must be configured on each Cloud Connector after deployment:

1. **DNAT rule** — translate the PLB frontend public IP to the workload private IP/port.
2. **SNAT rule** — use the ILB frontend private IP as the source address for traffic forwarded to workloads (ensures return traffic is steered back through the CC).
3. **Workload route tables** — add a `0.0.0.0/0` UDR pointing to the ILB frontend IP (`output.ilb_ip`) so that workload return traffic traverses the CC.

---

## Usage

```bash
cd examples/cc_public_lb
cp terraform.tfvars terraform.tfvars.local   # fill in required values
terraform init
terraform plan
terraform apply
```

### Required variables

| Variable | Description |
|----------|-------------|
| `env_subscription_id` | Azure Subscription ID |
| `cc_vm_managed_identity_name` | Managed Identity name for CC VMs |
| `cc_vm_managed_identity_rg` | Resource Group of the Managed Identity |
| `cc_vm_prov_url` | Zscaler CC Provisioning URL |
| `azure_vault_url` | Azure Key Vault URL for CC secrets |

### BYO VNet variables

Set `byo_rg`, `byo_vnet`, `byo_subnets` (and related `*_name`/`*_rg` variables) to `true` to deploy into an existing VNet instead of creating new network infrastructure.

---

## Outputs

| Output | Description |
|--------|-------------|
| `public_lb_ip` | Public IP of the PLB frontend — use this as the inbound entry point |
| `public_lb_backend_pool_id` | PLB backend pool ID |
| `ilb_ip` | Private IP of the ILB frontend — set as next-hop in workload UDRs |
| `ilb_backend_pool_id` | ILB backend pool ID |

---

## Scope note

This example is scoped to a **single Azure subscription**. Cross-subscription deployments (e.g. Managed Identity in a different subscription) are supported via `managed_identity_subscription_id` but cross-tenant scenarios are out of scope.
