require 'jira_command'
require 'thor'
require 'optparse'
require 'pry'
require_relative '../config'
require 'base64'

module JiraCommand
  module Command
    class Config < Thor
      desc 'create', 'list issues'
      def create
        prompt = TTY::Prompt.new

        jira_url = prompt.ask('Please input your site url:')
        email = prompt.ask('Please input your registered email address:')
        token = prompt.mask('Please input your token:')

        jira_url += '/' unless jira_url.end_with?('/')
        config = { jira_url: jira_url, header_token: Base64.strict_encode64("#{email}:#{token}") }

        JiraCommand::Jira::Config.new.write(config)
      end

      desc 'clear', 'list issues'
      def clear
        JiraCommand::Jira::Config.new.clear
      end
    end
  end
end
