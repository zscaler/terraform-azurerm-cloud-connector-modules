# Zscaler Cloud Connector / Azure DNS Private Resolver Module

This module creates the required resource dependencies to deploy Azure Private DNS that can be utilized to facilitate conditional DNS forwarding from Azure to Zscaler Cloud Connector for ZPA resolution and/or ZIA DNS Controls security. This includes the Private DNS Resolver, Rulset, Forwarding Rules, Virtual Network Link and Outbound Endpoint resources. For more information about Azure DNS Private Resolver, check here: https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview

## Considerations

If deploying via one of the Zscaler provider example templates, there is a creation dependency with the terraform-zscc-network-azure module where Terraform will create a new subnet delegated for the dnsResolvers service in the same VNet as the Cloud Connector(s). This subnet is where the Outbound Endpoint gets created. Terraform will also create a new Route Table associated with this subnet pointing a default route (0.0.0.0/0) towards the Cloud Connector service IP or Load Balancer Front-End IP for HA deployments to ensure that conditionally forwarded request get redirected to the Cloud Connector.

This module can create multiple Resolver Rules and link associated with only a single VNet. This follows Azure Well-Architected Framework and Hub-Spoke design model where spokes have access/connectivity directly to the Hub Virtual Network.

Rule domain names must be dot-terminated and have either zero labels (for wildcard) or between 2 and 34 labels). For example, contoso.com. has two labels.

## Azure Limitations

https://learn.microsoft.com/en-us/azure/dns/dns-faq#what-are-the-usage-limits-for-azure-dns-:~:text=limits%20are%20dropped.-,DNS%20private%20resolver,-Resource

Rulesets have the following associations:

- A single ruleset can be associated with multiple outbound endpoints.
- A ruleset can have up to 25 DNS forwarding rules.
- A ruleset can be linked to up to 10 virtual networks in the same region
