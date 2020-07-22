require 'thor'
require 'optparse'
require 'pry'
require_relative '../config'
require_relative '../jira/user'

module JiraCommand
  module Command
    class User < Thor
      default_command :project

      desc 'project', 'list issues in specified project'
      def project(pro)
        config = JiraCommand::Config.new.read

        user_api = JiraCommand::Jira::User.new(config)
        user_api.show_assignable(project: pro)
      end
    end
  end
end
