require 'fog/core/collection'
require 'fog/azurerm/models/network/local_network_gateway'

module Fog
  module Network
    class AzureRM
      # LocalNetworkGateways collection class for Network Service
      class LocalNetworkGateways < Fog::Collection
        model Fog::Network::AzureRM::LocalNetworkGateway
        attribute :resource_group

        def all
          requires :resource_group
          local_network_gateways = []
          service.list_local_network_gateways(resource_group).each do |gateway|
            local_network_gateways << LocalNetworkGateway.parse(gateway)
          end
          load(local_network_gateways)
        end

        def get(resource_group_name, name)
          local_network_gateway = service.get_local_network_gateway(resource_group_name, name)
          local_network_gateway_obj = LocalNetworkGateway.new(service: service)
          local_network_gateway_obj.merge_attributes(LocalNetworkGateway.parse(local_network_gateway))
        end
      end
    end
  end
end
