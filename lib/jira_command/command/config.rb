require 'jira_command'
require 'thor'
require 'optparse'
require 'pry'
require_relative '../config'
require 'base64'

module JiraCommand
  module Command
    class Config < Thor
      desc 'create', 'create config file'
      def create
        if JiraCommand::Config.check_exist
          puts 'config file has been already existed. if you want to renew it, please execute `jira_command config clear` first'
          exit 1
        end

        prompt = TTY::Prompt.new

        jira_url = prompt.ask('Please input your site url:')
        email = prompt.ask('Please input your registered email address:')
        token = prompt.mask('Please input your token:')

        jira_url += '/' unless jira_url.end_with?('/')
        config = { jira_url: jira_url, header_token: Base64.strict_encode64("#{email}:#{token}") }

        JiraCommand::Config.new.write(config)
      end

      desc 'clear', 'clear config file'
      def clear
        JiraCommand::Config.new.clear
      end
    end
  end
end
