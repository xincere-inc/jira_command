require 'thor'
require 'optparse'
require 'pry'
require_relative '../jira/config'
require_relative '../jira/user'

module JiraCommand
  module Command
    class User < Thor
      default_command :all

      desc 'all', 'list issues'
      option 'project', aliases: 'p', required: true
      def all
        config = JiraCommand::Jira::Config.new.read

        user_api = JiraCommand::Jira::User.new(config)
        user_api.show_assignable(project: options['project'])
      end
    end
  end
end
