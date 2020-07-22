require 'thor'
require 'optparse'
require 'date'
require_relative '../config'
require_relative '../jira/sprint'
require_relative '../prompt/base'

module JiraCommand
  module Command
    class Sprint < Thor
      desc 'list', 'list all sprints'
      option 'future', aliases: 'f', required: false
      option 'active', aliases: 'a', required: false
      option 'closed', aliases: 'c', required: false
      def list
        config = JiraCommand::Config.new.read

        board_id = JiraCommand::Prompt::Base.new.select_board
        jira_sprint = JiraCommand::Jira::Sprint.new(config)
        state = []
        state << 'future' unless options['future'].nil?
        state << 'active' unless options['active'].nil?
        state << 'closed' unless options['closed'].nil?
        res = jira_sprint.list(board_id: board_id, query: { state: state })

        puts(res.map { |item| item[:name] })
      end

      desc 'create', 'create sprint'
      option 'start_datetime', aliases: 's', required: true
      option 'end_datetime', aliases: 'e', required: true
      def create(name)
        config = JiraCommand::Config.new.read

        board_id = JiraCommand::Prompt::Base.new.select_board

        jira_sprint = JiraCommand::Jira::Sprint.new(config)

        jira_sprint.create(
          name: name,
          board_id: board_id,
          start_date: DateTime.parse(options['start_datetime']).strftime('%Y-%m-%dT%H:%M:%S.%L+09:00'),
          end_date: DateTime.parse(options['end_datetime']).strftime('%Y-%m-%dT%H:%M:%S.%L+09:00')
        )
      end
    end
  end
end
