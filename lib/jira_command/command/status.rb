require 'thor'
require 'optparse'
require_relative '../config'
require_relative '../jira/status'

module JiraCommand
  module Command
    class Status < Thor
      desc 'project', 'list status in specified project'
      def project
        config = JiraCommand::Config.new.read

        jira = JiraCommand::Jira::Status.new(config)
        res = jira.list

        puts(res.map { |item| item[:name] })
      end
    end
  end
end
