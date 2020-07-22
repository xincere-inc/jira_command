require 'jira_command'
require 'thor'
require 'optparse'
require 'pry'
require_relative '../config'
require_relative '../jira/list'
require_relative '../jira/epic'
require 'tty-prompt'
require 'base64'
require 'terminal-table'

module JiraCommand
  module Command
    class List < Thor
      default_command :all

      desc 'all', 'list issues'
      option 'current', aliases: 'c', required: false
      option 'unresolved', aliases: 'u', required: false
      def all
        jql = []
        jql << 'sprint in openSprints()' unless options['current'].nil?
        jql << 'status not in (resolved)' unless options['unresolved'].nil?

        config = JiraCommand::Config.new.read
        list = JiraCommand::Jira::List.new(config)
        issues_list = list.list({ jql: jql.join('&') })
        show_in_console(config[:jira_url], issues_list['issues'])
      end

      desc 'my', 'list your issues'
      option 'current', aliases: 'c', required: false
      option 'unresolved', aliases: 'u', required: false
      def my
        jql = ['assignee=currentUser()']
        jql << 'sprint in openSprints()' unless options['current'].nil?
        jql << 'status not in (resolved)' unless options['unresolved'].nil?

        config = JiraCommand::Config.new.read
        list = JiraCommand::Jira::List.new(config)
        issues_list = list.list({ fields: 'id,key,status,issuetype,assignee,summary',
                                  jql: jql.join('&') })

        show_in_console(config[:jira_url], issues_list['issues'])
      end

      desc 'without_epic', 'list your issues which has not epic'
      def without_epic
        config = JiraCommand::Config.new.read
        agile_epic = JiraCommand::Jira::Epic.new(config)

        jql = ["key in (#{agile_epic.issue_key_without_epic.join(', ')})"]

        list = JiraCommand::Jira::List.new(config)

        issues_list = list.list({ fields: 'id,key,status,issuetype,assignee,summary',
                                  jql: jql.join('&') })

        show_in_console(config[:jira_url], issues_list['issues'])
      end

      private

      def show_in_console(jira_url, issues)
        issue_list = issues.map do |issue|
          { key: issue['key'],
            summary: issue['fields']['summary'],
            assignee: issue['fields']['assignee'].nil? ? 'not assinged' : issue['fields']['assignee']['displayName'],
            type: issue['fields']['issuetype']['name'],
            status: issue['fields']['status']['name'],
            link: jira_url + 'browse/' + issue['key'] }
        end

        table = Terminal::Table.new
        table.headings = issue_list.first.keys
        table.rows = issue_list.sort_by { |data| "#{data['status']}-#{data['key']}-#{data['type']}" }.map(&:values)

        puts table
      end
    end
  end
end
