module Fog
  module Network
    class AzureRM
      # Mock class for Network Request
      class Real
        def check_for_public_ip(resource_group, name)
          begin
            @network_client.public_ipaddresses.get(resource_group, name)
            return true
          rescue MsRestAzure::AzureOperationError => e
            raise_azure_exception(e, "Checking Public IP #{name}") if e.body['error']['code'] == 'ResourceGroupNotFound'
            return false if e.body['error']['code'] == 'ResourceNotFound'
          end
        end
      end

      # Mock class for Network Request
      class Mock
        def check_for_public_ip(resource_group, name)
          Fog::Logger.debug "Public IP #{name} from Resource group #{resource_group} is available."
          true
        end
      end
    end
  end
end
