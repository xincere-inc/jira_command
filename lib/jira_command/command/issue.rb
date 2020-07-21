require 'jira_command'
require_relative '../config'
require_relative '../jira/issuetype'
require_relative '../jira/project'
require_relative '../jira/issue'

module JiraCommand
  module Command
    class Issue < Thor
      desc 'create', 'create new issue'
      option 'refresh-project', aliases: 'rp', required: false
      option 'refresh-issue-type', aliases: 'rit', required: false
      option 'refresh-user', aliases: 'ru', required: false
      def create
        config = JiraCommand::Config.new.read

        issue_types = if options['refresh-issue-type'].nil?
                        config['issue_types']
                      else
                        jira_issue_type = JiraCommand::Jira::IssueType.new(config)
                        jira_issue_type.list
                      end

        prompt = TTY::Prompt.new

        issue_type = prompt.select('Which issue type do you want to create?') do |menu|
          issue_types.each do |item|
            menu.choice name: item['name'], value: item['id']
          end
        end

        projects = if options['refresh-project'].nil?
                     config['projects']
                   else
                     jira_project = JiraCommand::Jira::Project.new(config)
                     jira_project.list
                   end

        project = prompt.select('Which project does the issue belong to?') do |menu|
          projects.each do |item|
            menu.choice name: item['name'], value: { id: item['id'], key: item['key'] }
          end
        end

        user_list = if options['refresh-user'].nil?
                      config['users']
                    else
                      user_api = JiraCommand::Jira::User.new(config)
                      user_api.all_list(project: project[:key])
                    end

        assignee = prompt.select('Who do you want to assign?') do |menu|
          user_list.each do |user|
            menu.choice name: user['name'], value: user['account_id']
          end
        end

        reporter = prompt.select('Who are you?') do |menu|
          user_list.each do |user|
            menu.choice name: user['name'], value: user['account_id']
          end
        end

        summary = prompt.ask('Please input issue summary: ')
        description = prompt.ask('Please input issue description: ')

        jira_issue = JiraCommand::Jira::Issue.new(config)

        puts 'the created issue url: ' + jira_issue.create(
          summary: summary,
          description: description,
          assignee: assignee,
          reporter: reporter,
          project_id: project[:id],
          issuetype_id: issue_type
        )
      end
    end
  end
end
