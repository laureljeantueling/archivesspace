#!/usr/bin/env ruby
require 'optparse'

options = {:dry => false, 
           :debug => false,
           :relaxed => false, 
           :verbose => false, 
           :repo_id => 2, 
           :vocab_id => 1}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: import.rb [options] IMPORTER_ARGS"
  
  opts.on( '-a', '--allow-failures', 'Do not stop because an import fails') do
    options[:relaxed] = true
  end
  opts.on( '-d', '--debug', 'Debug mode' ) do
    options[:debug] = true
  end 
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
  opts.on( '-i', '--importer KEY', 'Select an importer' ) do|importer|
    options[:importer] = importer
  end
  opts.on( '-l', '--list-importers', 'List available importers') do
    options[:list] = true
  end
  opts.on( '-n', '--dry-run', 'Do a dry run' ) do
    options[:dry] = true
  end
  opts.on( '-p', '--profile', 'Use the Jruby profiling tools' ) do
    options[:profile] = true
  end
  opts.on( '-r', '--repository REPO-ID', 'Override default repository id') do|repo_id|
    options[:repo_id] = repo_id
  end
  opts.on( '-w', '--vocabulary VOCAB-ID', 'Override default vocabulary id') do|vocab_id|
    options[:vocab_id] = repo_id
  end
  opts.on( '-s', '--source-file PATH', 'Import from file at PATH' ) do|path|
    options[:input_file] = path
  end
  opts.on( '-v', '--verbose', 'Exude verbosity') do
    options[:verbose] = true
  end
  opts.on( '-x', '--crosswalk KEY', 'Use crosswalk at crosswalks/KEY.yml' ) do|path|
    options[:crosswalk] = path
  end
end

optparse.parse!

$dry_mode = true if options[:dry]

if $dry_mode
  require 'mocha/setup'
  include Mocha::API
end

require_relative 'lib/bootstrap'

options[:log] = $log

if options[:list]
  ASpaceImport::Importer.list
  exit
end

x = Proc.new do
  if options[:importer]
    i = ASpaceImport::Importer.create_importer(options)
  
    if options[:debug]
      i.run
    else
      i.run_safe
    end
  
    puts i.report
  end
end


if options[:profile]
  require 'jruby/profiler'
  $log.debug "Profiling import using the JRuby profiler"
  
  profile_data = JRuby::Profiler.profile do
    x.call
  end
  
  profile_printer = JRuby::Profiler::GraphProfilePrinter.new(profile_data)
  profile_printer.printProfile(STDOUT)

else
  x.call
end



