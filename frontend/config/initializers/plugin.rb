# Be sure to restart your server when you modify this file.

module Plugins

  def self.init
    @config = {'plugins' => [], 'plugin' => {}}
    Array(AppConfig[:plugins]).each do |plugin|
      @config['plugin'][plugin] = {'parents' => []}
      @config['parents'] = {}
      if Dir.glob(Rails.root.join('..', 'plugins', plugin, 'frontend', 'controllers', '*_controller.rb')).length > 0
        @config['plugins'] << plugin
      end

      Dir.glob(Rails.root.join('..', 'plugins', plugin, 'config.yml')).each do |config|
        @config['plugin'][plugin] = cfg = YAML.load_file File.absolute_path(config)
        puts "Loaded config for #{plugin}: #{cfg.inspect}"

        (cfg['parents'] || {}).keys.each do |parent|
          @config['parents'][parent] ||= []
          @config['parents'][parent] << plugin
        end
      end
      puts "done plugin init: #{@config.inspect}"
    end

    if @config['plugins'].length > 0
      puts "Found controllers for plug-ins: #{@config['plugins'].inspect}"
    end
  end


  def self.list
    @config['plugins']
  end


  def self.plugins?
    @config['plugins'].length > 0
  end


  def self.config_for(plugin)
    @config['plugin'][plugin]
  end

  def self.plugins_for(parent)
    @config['parents'][parent] || []
  end

end

Plugins::init
