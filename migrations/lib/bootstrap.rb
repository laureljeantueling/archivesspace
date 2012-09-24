# written for Ruby 1.9.3

require_relative "../config/config"
require_relative "../../common/jsonmodel"
require_relative "jsonmodel_queue"

unless $test_mode
  JSONModel::init( { :client_mode => true, :url => ASpaceImportConfig::ASPACE_BASE, :strict_mode => true } )
  JSONModel::init( { :client_mode => true, :strict_mode => true } )
end

require_relative "crosswalk"
require_relative "importer"

require_relative "parse_queue"









