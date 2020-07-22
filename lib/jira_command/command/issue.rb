require 'jira_command'
require_relative '../config'
require_relative '../prompt/base'
require_relative '../jira/epic'
require_relative '../jira/board'
require_relative '../jira/issue'
require_relative '../jira/sprint'

module JiraCommand
  module Command
    class Issue < Thor
      desc 'create', 'create new issue'
      option 'refresh-project', aliases: 'p', required: false
      option 'refresh-issue-type', aliases: 'i', required: false
      option 'refresh-user', aliases: 'u', required: false
      option 'refresh-board', aliases: 'b', required: false
      def create
        config = JiraCommand::Config.new.read

        prompt_base = JiraCommand::Prompt::Base.new

        issue_type = prompt_base.select_issue_type(
          message: 'Which issue type do you want to create?',
          refresh: !options['refresh-issue-type'].nil?
        )

        project = prompt_base.select_project(
          message: 'Which project does the issue belong to?',
          refresh: !options['refresh-project'].nil?
        )

        assignee = prompt_base.select_user(
          message: 'Who do you want to assign?',
          refresh: !options['refresh-user'].nil?,
          additional: [{ name: 'unassigned', value: nil }]
        )

        reporter = prompt_base.select_user(
          message: 'Who are you?',
          refresh: !options['refresh-user'].nil?
        )

        prompt = TTY::Prompt.new
        summary = prompt.ask('Please input issue summary: ')
        description = prompt.ask('Please input issue description: ')

        jira_issue = JiraCommand::Jira::Issue.new(config)

        issue_key = jira_issue.create(
          summary: summary,
          description: description,
          assignee: assignee,
          reporter: reporter,
          project_id: project[:id],
          issuetype_id: issue_type[:id]
        )

        puts 'the created issue url: ' + config[:jira_url] + 'browse/' + issue_key

        return if issue_type[:name] == 'Epic'

        baord_list = if options['refresh-board'].nil?
                       config[:boards]
                     else
                       agile_board = JiraCommand::Jira::Board.new(config)
                       agile_board.list
                     end

        target_board = baord_list.find { |item| item[:projectId].to_i == project[:id].to_i }

        agile_epic = JiraCommand::Jira::Epic.new(config)
        epics = agile_epic.list(board_id: target_board[:id])

        epic_id = prompt.select('Which epic does the created issue belong to?') do |menu|
          epics.each do |item|
            menu.choice name: item[:name], value: item[:id]
          end
        end

        agile_epic.move_issue(epic_id: epic_id, issue_key: issue_key)

        exit 0 unless prompt.yes?('Do you want to attach to sprint?')

        sprint_id = prompt_base.select_sprint(board_id: target_board[:id])
        jira_sprint = JiraCommand::Jira::Sprint.new(config)
        jira_sprint.move_issue(issue_key: issue_key, sprint_id: sprint_id)
      end

      desc 'comment', 'comment to issue'
      option 'message', aliases: 'm', required: false
      def comment(issue_key)
        config = JiraCommand::Config.new.read
        jira_comment = JiraCommand::Jira::Issue.new(config)

        jira_comment.comment(issue_key: issue_key, message: options['message'])
      end

      desc 'attach_epic', 'attach epic to issue'
      option 'refresh-board', aliases: 'b', required: false
      def attach_epic(issue_key)
        config = JiraCommand::Config.new.read

        baord_list = if options['refresh-board'].nil?
                       config[:boards]
                     else
                       agile_board = JiraCommand::Jira::Board.new(config)
                       agile_board.list
                     end

        target_board = baord_list.find { |item| item[:projectKey] == issue_key.split('-').first }

        agile_epic = JiraCommand::Jira::Epic.new(config)
        epics = agile_epic.list(board_id: target_board[:id])

        prompt = TTY::Prompt.new
        epic_id = prompt.select('Which epic does the created issue belong to?') do |menu|
          epics.each do |item|
            menu.choice name: item[:name], value: item[:id]
          end
        end

        agile_epic.move_issue(epic_id: epic_id, issue_key: issue_key)
      end

      desc 'attach_sprint', 'attach epic to issue'
      option 'refresh-board', aliases: 'b', required: false
      def attach_sprint(issue_key)
        config = JiraCommand::Config.new.read

        baord_list = if options['refresh-board'].nil?
                       config[:boards]
                     else
                       agile_board = JiraCommand::Jira::Board.new(config)
                       agile_board.list
                     end

        target_board = baord_list.find { |item| item[:projectKey] == issue_key.split('-').first }

        sprint_id = JiraCommand::Prompt::Base.new.select_sprint(board_id: target_board[:id])

        jira_sprint = JiraCommand::Jira::Sprint.new(config)

        jira_sprint.move_issue(issue_key: issue_key, sprint_id: sprint_id)
      end
    end
  end
end
