require 'spec_helper'

resource "Gnip instances" do
  let(:user) { users(:owner) }

  before do
    log_in user
  end

  post "/gnip_instances" do
    parameter :name, "gnip account name"
    parameter :description, "gnip account description"
    parameter :host, "gnip host url"
    parameter :port, "gnip host port"
    parameter :username, "gnip account username"
    parameter :password, "gnip account password"

    let(:name) { "example name" }
    let(:description) { "Can you tell me how to get..." }
    let(:host) { "https://stream.gnip.com" }
    let(:port) { 443 }
    let(:username) { "example_user" }
    let(:password) { "sample_password" }

    required_parameters :name, :host, :port, :username, :password

    example_request "Register a Gnip Account" do
      status.should == 201
    end
  end

  get "/gnip_instances" do
    example_request "Get a list of registered Gnip Instances" do
      status.should == 200
    end
  end

  get "/gnip_instances/:id" do
    let(:id) { gnip_instances(:default).id }
    example_request "Get a registered Gnip Instance" do
      status.should == 200
    end
  end
end