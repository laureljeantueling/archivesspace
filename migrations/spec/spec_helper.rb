require 'test_utils'
require 'config/config-distribution'

$test_mode = true

$backend_port = TestUtils::free_port_from(3636)
$backend_url = "http://localhost:#{$backend_port}"
$expire = 300

$backend_start_fn = proc {
  TestUtils::start_backend($backend_port,
                           {
                             :session_expire_after_seconds => $expire
                           })
}

AppConfig[:backend_url] = $backend


def start_backend
  $backend_pid = $backend_start_fn.call
  response = JSON.parse(`curl -F'password=admin' #{$backend_url}/users/admin/login`)
  session_id = response['session']
  Thread.current[:backend_session] = session_id
end


def stop_backend
  TestUtils::kill($backend_pid)
end


require_relative "../lib/bootstrap"
require_relative "../../backend/app/lib/request_context"


JSONModel::init( { :strict_mode => true, :enum_source => MockEnumSource, :client_mode => true, :url => $backend_url} )


require 'factory_girl'
require_relative 'factories'
include FactoryGirl::Syntax::Methods


if ENV['COVERAGE_REPORTS'] == 'true'
  require 'tmpdir'
  require 'pp'
  require 'simplecov'

  SimpleCov.root(File.join(File.dirname(__FILE__), "../../"))
  SimpleCov.coverage_dir("migrations/coverage")

  # SimpleCov.start do
  #   # Exclude everything but the Import code
  # 
  # end
  
  env_coverage_reports_tmp = ENV['COVERAGE_REPORTS'].clone
  
  ENV['COVERAGE_REPORTS'] = nil
  
end




def make_test_vocab
  vocab = JSONModel(:vocabulary).from_hash("ref_id" => 'test_vocab',
                                          "name" => "Test Vocabulary")
  vocab.save
  
  vocab.uri
end

if env_coverage_reports_tmp
  ENV['COVERAGE_REPORTS'] = env_coverage_reports_tmp
end












