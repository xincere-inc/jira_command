require 'thor'
require 'optparse'
require 'tty-prompt'
require_relative '../config'
require_relative '../jira/assign'
require_relative '../prompt/base'

module JiraCommand
  module Command
    class Assign < Thor
      desc 'exec', 'assign to user'
      option 'refresh-user', aliases: 'u', required: false
      def exec(issue_key)
        config = JiraCommand::Config.new.read

        prompt_base = JiraCommand::Prompt::Base.new
        assignee = prompt_base.select_user(
          message: 'Who do you want to assign?',
          project_key: issue_key.split('-').first,
          refresh: !options['refresh-user'].nil?
        )

        assign = JiraCommand::Jira::Assign.new(config)
        assign.execute(issue_key: issue_key, assignee: assignee)
      end

      desc 'clear', 'set to unassigned'
      def clear(issue_key)
        config = JiraCommand::Config.new.read

        assign = JiraCommand::Jira::Assign.new(config)
        assign.unassigne(issue_key: issue_key)
      end
    end
  end
end
