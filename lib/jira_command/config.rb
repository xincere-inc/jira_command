require 'jira_command'
require 'thor'
require 'optparse'
require 'pathname'
require 'fileutils'
require 'json'

module JiraCommand
  class Config
    CONFIG_PATH_CLASS = Pathname(ENV['HOME'] + '/.jira_command/config.json')

    def read
      unless FileTest.exists?(CONFIG_PATH_CLASS)
        puts 'please create config file first'
        exit 1
      end

      file = File.read(CONFIG_PATH_CLASS)
      JSON.parse(file, symbolize_names: true)
    end

    def self.check_exist
      FileTest.exists?(CONFIG_PATH_CLASS)
    end

    def write(hash_params)
      FileUtils.mkdir_p(CONFIG_PATH_CLASS.dirname) unless Dir.exist?(CONFIG_PATH_CLASS.dirname)

      File.open(CONFIG_PATH_CLASS, 'w') do |f|
        f.puts hash_params.to_json
      end
    end

    def clear
      FileUtils.rm(CONFIG_PATH_CLASS)
    end
  end
end
