require 'thor'
require 'optparse'
require 'tty-prompt'
require_relative '../config'
require_relative '../jira/assign'

module JiraCommand
  module Command
    class Assign < Thor
      desc 'assign', 'assign to user'
      option 'issue', aliases: 'i', required: false
      def assign
        config = JiraCommand::Config.new.read

        user_api = JiraCommand::Jira::User.new(config)
        user_list = user_api.all_list(project: options['issue'].split('-').first)

        prompt = TTY::Prompt.new

        assignee = prompt.select('Who do you want to assign?') do |menu|
          user_list.each do |user|
            menu.choice name: user[:name], value: user[:account_id]
          end
        end

        assign = JiraCommand::Jira::Assign.new(config)
        user_list = assign.execute(issue_key: options['issue'], assignee: assignee)
      end

      desc 'clear', 'set to unassigned'
      option 'issue', aliases: 'i', required: false
      def clear
        config = JiraCommand::Config.new.read

        assign = JiraCommand::Jira::Assign.new(config)
        assign.unassigne(issue_key: options['issue'])
      end
    end
  end
end
