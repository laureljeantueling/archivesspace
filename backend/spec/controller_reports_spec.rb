require 'spec_helper'

describe 'Reports controller' do

  it "lets you list all registered reports" do
    as_test_user("admin") do
      get '/reports'
      resp = JSON(last_response.body)
      resp['formats'].class.should eq(Array)
      resp['reports'].class.should eq(Hash)
    end
  end

end
