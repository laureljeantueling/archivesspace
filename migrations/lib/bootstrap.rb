require 'config/config-distribution'
require 'jsonmodel'
require 'logger'

$log = Logger.new(STDOUT)
$log.level = Logger::WARN

class MockEnumSource
  def self.valid?(enum_name, value)
    [true, false].sample
  end

  def self.values_for(enum_name)
    %w{alpha beta epsilon}
  end
end


$dry_mode ||= false

unless $test_mode
  begin
    json_model_opts = { :client_mode => true, :url => AppConfig[:backend_url], :strict_mode => true }
    JSONModel::init(json_model_opts)
  rescue StandardError => e
    if e.to_s =~ /Connection refused/ && $dry_mode
      $log.warn("Exception #{e.to_s}")
      $log.warn("Cannot connect to the backend, it seems. But since this is a dry run, we'll proceed anyway, using mock terms for controlled vocabularies.")
      json_model_opts[:enum_source] = MockEnumSource
      JSONModel::init( json_model_opts )
    else
      raise e
    end
  end  
end

require_relative "crosswalk"
require_relative "importer"
require_relative "parse_queue"

ASpaceImport::init

# require_relative "exporter"
# 
# ASpaceExport::init

unless $dry_mode || $test_mode
  response = JSON.parse(`curl -F'password=admin' #{AppConfig[:backend_url]}/users/admin/login`)
  session_id = response['session']
  Thread.current[:backend_session] = session_id
end







