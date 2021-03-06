module Fog
  module Network
    class AzureRM
      # Real class for Network Request
      class Real
        def create_or_update_express_route_circuit_peering(circuit_peering_params)
          msg = "Exception creating/updating Express Route Circuit Peering #{circuit_peering_params[:peering_name]} in Resource Group: #{circuit_peering_params[:resource_group_name]}."
          Fog::Logger.debug msg
          circuit_peering = get_circuit_peering_object(circuit_peering_params)
          begin
            peering = @network_client.express_route_circuit_peerings.create_or_update(circuit_peering_params[:resource_group_name], circuit_peering_params[:circuit_name], circuit_peering_params[:peering_name], circuit_peering)
          rescue MsRestAzure::AzureOperationError => e
            raise_azure_exception(e, msg)
          end
          Fog::Logger.debug "Express Route Circuit Peering #{circuit_peering_params[:peering_name]} created/updated successfully."
          peering
        end

        private

        def get_circuit_peering_object(circuit_peering_params)
          circuit_peering = Azure::ARM::Network::Models::ExpressRouteCircuitPeering.new
          circuit_peering.name = circuit_peering_params[:peering_name]
          circuit_peering.peering_type = circuit_peering_params[:peering_type]
          circuit_peering.peer_asn = circuit_peering_params[:peer_asn]
          circuit_peering.primary_peer_address_prefix = circuit_peering_params[:primary_peer_address_prefix]
          circuit_peering.secondary_peer_address_prefix = circuit_peering_params[:secondary_peer_address_prefix]
          circuit_peering.vlan_id = circuit_peering_params[:vlan_id]

          if circuit_peering_params[:peering_type].casecmp(MICROSOFT_PEERING) == 0
            peering_config = Azure::ARM::Network::Models::ExpressRouteCircuitPeeringConfig.new
            peering_config.advertised_public_prefixes = circuit_peering_params[:advertised_public_prefixes]
            peering_config.advertised_public_prefixes_state = circuit_peering_params[:advertised_public_prefix_state]
            peering_config.customer_asn = circuit_peering_params[:customer_asn]
            peering_config.routing_registry_name = circuit_peering_params[:routing_registry_name]
            circuit_peering.microsoft_peering_config = peering_config
          end

          circuit_peering
        end
      end

      # Mock class for Network Request
      class Mock
        def create_or_update_express_route_circuit_peering(*)
          {
            'name' => 'PeeringName',
            'properties' => {
              'peeringType' => 'MicrosoftPeering',
              'peerASN' => 100,
              'primaryPeerAddressPrefix' => '192.168.1.0/30',
              'secondaryPeerAddressPrefix' => '192.168.2.0/30',
              'vlanId' => 200,
              'microsoftPeeringConfig' => {
                'advertisedpublicprefixes' => [
                  '11.2.3.4/30',
                  '12.2.3.4/30'
                ],
                'advertisedPublicPrefixState' => 'NotConfigured',
                'customerAsn' => 200,
                'routingRegistryName' => '<name>'
              }
            }
          }
        end
      end
    end
  end
end
