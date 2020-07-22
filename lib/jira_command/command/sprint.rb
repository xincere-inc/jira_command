require 'thor'
require 'optparse'
require_relative '../config'
require_relative '../jira/sprint'

module JiraCommand
  module Command
    class Sprint < Thor
      desc 'list', 'list all sprints'
      def list
        config = JiraCommand::Config.new.read

        jira_sprint = JiraCommand::Jira::Sprint.new(config)
        res = jira_sprint.list

        puts(res.map { |item| item[:name] })
      end
    end
  end
end
