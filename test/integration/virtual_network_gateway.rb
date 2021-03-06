require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file('credentials/azure.yml')

resource = Fog::Resources::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

network = Fog::Network::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

resource.resource_groups.create(
  name: 'TestRG-VNG',
  location: 'eastus'
)

network.virtual_networks.create(
  name: 'testVnet',
  location: 'eastus',
  resource_group: 'TestRG-VNG',
  network_address_list: '10.1.0.0/16,10.2.0.0/16'
)

network.subnets.create(
  name: 'GatewaySubnet',
  resource_group: 'TestRG-VNG',
  virtual_network_name: 'testVnet',
  address_prefix: '10.2.0.0/24'
)

network.public_ips.create(
  name: 'mypubip',
  resource_group: 'TestRG-VNG',
  location: 'eastus',
  public_ip_allocation_method: 'Dynamic'
)

network.local_network_gateways.create(
  name: 'testlocalnetworkgateway',
  location: 'eastus',
  tags: {
    key1: 'value1',
    key2: 'value2'
  },
  resource_group: 'TestRG-VNG',
  gateway_ip_address: '192.168.1.1',
  local_network_address_space_prefixes: [],
  asn: 100,
  bgp_peering_address: '192.168.1.2',
  peer_weight: 3
)

########################################################################################################################
######################                           Create Virtual Network Gateway                   ######################
########################################################################################################################

network.virtual_network_gateways.create(
  name: 'testnetworkgateway',
  location: 'eastus',
  tags: {
    key1: 'value1',
    key2: 'value2'
  },
  ip_configurations: [
    {
      name: 'default',
      private_ipallocation_method: 'Dynamic',
      public_ipaddress_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VNG/providers/Microsoft.Network/publicIPAddresses/mypubip",
      subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VNG/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/GatewaySubnet",
      private_ipaddress: nil
    }
  ],
  resource_group: 'TestRG-VNG',
  sku_name: 'Standard',
  sku_tier: 'Standard',
  sku_capacity: 2,
  gateway_type: 'vpn',
  enable_bgp: true,
  gateway_size: nil,
  asn: 100,
  bgp_peering_address: nil,
  peer_weight: 3,
  vpn_type: 'RouteBased',
  vpn_client_address_pool: [],
  gateway_default_site: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VNG/providers/Microsoft.Network/localNetworkGateways/testlocalnetworkgateway"
)

########################################################################################################################
######################                      List Virtual Network Gateways                         ######################
########################################################################################################################

network_gateways = network.virtual_network_gateways(resource_group: 'TestRG-VNG')
network_gateways.each do |gateway|
  puts gateway.name.to_s
end

########################################################################################################################
######################                  Get Virtual Network Gateway and CleanUp                   ######################
########################################################################################################################

network_gateway = network.virtual_network_gateways.get('TestRG-VNG', 'testnetworkgateway')
puts network_gateway.name.to_s

network_gateway.destroy

pubip = network.public_ips.get('TestRG-VNG', 'mypubip')
pubip.destroy

local_network_gateway = network.local_network_gateways.get('TestRG-VNG', 'testlocalnetworkgateway')
local_network_gateway.destroy

rg = resource.resource_groups.get('TestRG-VNG')
rg.destroy
