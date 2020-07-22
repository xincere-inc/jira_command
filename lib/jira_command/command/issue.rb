require 'jira_command'
require_relative '../config'
require_relative '../jira/issuetype'
require_relative '../jira/project'
require_relative '../jira/issue'

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

        issue_types = if options['refresh-issue-type'].nil?
                        config[:issue_types]
                      else
                        jira_issue_type = JiraCommand::Jira::IssueType.new(config)
                        jira_issue_type.list
                      end

        prompt = TTY::Prompt.new

        issue_type = prompt.select('Which issue type do you want to create?') do |menu|
          issue_types.each do |item|
            menu.choice name: item[:name], value: { id: item[:id], name: item[:name] }
          end
        end

        projects = if options['refresh-project'].nil?
                     config[:projects]
                   else
                     jira_project = JiraCommand::Jira::Project.new(config)
                     jira_project.list
                   end

        project = prompt.select('Which project does the issue belong to?') do |menu|
          projects.each do |item|
            menu.choice name: item[:name], value: { id: item[:id], key: item[:key] }
          end
        end

        user_list = if options['refresh-user'].nil?
                      config[:users]
                    else
                      user_api = JiraCommand::Jira::User.new(config)
                      user_api.all_list(project: project[:key])
                    end

        assignee = prompt.select('Who do you want to assign?') do |menu|
          menu.choice name: 'unassigned', value: nil
          user_list.each do |user|
            menu.choice name: user[:name], value: user[:account_id]
          end
        end

        reporter = prompt.select('Who are you?') do |menu|
          user_list.each do |user|
            menu.choice name: user[:name], value: user[:account_id]
          end
        end

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
      end

      desc 'attach_epic', 'attach epic to issue'
      option 'issue', aliases: 'i', required: true
      option 'refresh-board', aliases: 'b', required: false
      def attach_epic
        config = JiraCommand::Config.new.read

        baord_list = if options['refresh-board'].nil?
                       config[:boards]
                     else
                       agile_board = JiraCommand::Jira::Board.new(config)
                       agile_board.list
                     end

        target_board = baord_list.find { |item| item[:projectKey] == options['issue'].split('-').first }

        agile_epic = JiraCommand::Jira::Epic.new(config)
        epics = agile_epic.list(board_id: target_board[:id])

        prompt = TTY::Prompt.new
        epic_id = prompt.select('Which epic does the created issue belong to?') do |menu|
          epics.each do |item|
            menu.choice name: item[:name], value: item[:id]
          end
        end

        agile_epic.move_issue(epic_id: epic_id, issue_key: options['issue'])
      end
    end
  end
end
