require File.expand_path '../../test_helper', __dir__

# Test class for Servers Collection
class TestServers < Minitest::Test
  def setup
    @service = Fog::Compute::AzureRM.new(credentials)
    @servers = Fog::Compute::AzureRM::Servers.new(resource_group: 'fog-test-rg', service: @service)
    @compute_client = @service.instance_variable_get(:@compute_mgmt_client)
    @response = ApiStub::Models::Compute::Server.create_windows_virtual_machine_response(@compute_client)
  end

  def test_collection_methods
    methods = [
      :all,
      :get
    ]
    methods.each do |method|
      assert @servers.respond_to? method, true
    end
  end

  def test_collection_attributes
    assert @servers.respond_to? :resource_group, true
  end

  def test_all_method_response
    response = [@response]
    @service.stub :list_virtual_machines, response do
      assert_instance_of Fog::Compute::AzureRM::Servers, @servers.all
      assert @servers.all.size >= 1
      @servers.all.each do |s|
        assert_instance_of Fog::Compute::AzureRM::Server, s
      end
    end
  end

  def test_get_method_response
    @service.stub :get_virtual_machine, @response do
      assert_instance_of Fog::Compute::AzureRM::Server, @servers.get('fog-test-rg', 'fog-test-server')
    end
  end
end
