require_relative '../config'
require_relative '../jira/sprint'
require_relative '../jira/user'
require_relative '../jira/issue_type'
require 'tty-prompt'

module JiraCommand
  module Prompt
    class Base
      attr_writer :prompt, :config

      def initialize
        @prompt = TTY::Prompt.new
        @config = JiraCommand::Config.new.read
      end

      def select_board(message: 'Please select board', refresh: false)
        baord_list = if refresh
                       agile_board = JiraCommand::Jira::Board.new(@config)
                       agile_board.list
                     else
                       @config[:boards]
                     end

        @prompt.select(message) do |menu|
          baord_list.each do |item|
            menu.choice name: item[:name], value: item[:id]
          end
        end
      end

      def select_issue_type(message:, refresh: false)
        issue_types = if refresh
                        jira_issue_type = JiraCommand::Jira::IssueType.new(@config)
                        jira_issue_type.list
                      else
                        @config[:issue_types]
                      end

        @prompt.select(message) do |menu|
          issue_types.each do |item|
            menu.choice name: item[:name], value: { id: item[:id], name: item[:name] }
          end
        end
      end

      def select_project(message:, refresh: false)
        projects = if refresh
                     jira_project = JiraCommand::Jira::Project.new(@config)
                     jira_project.list
                   else
                     @config[:projects]
                   end

        @prompt.select(message) do |menu|
          projects.each do |item|
            menu.choice name: item[:name], value: { id: item[:id], key: item[:key] }
          end
        end
      end

      def select_user(message:,
                      project_key: nil,
                      refresh: false,
                      additional: [])
        user_list = if refresh
                      user_api = JiraCommand::Jira::User.new(@config)
                      user_api.all_list(project: project_key)
                    else
                      @config[:users]
                    end

        @prompt.select(message) do |menu|
          additional.each do |item|
            menu.choice name: item[:name], value: item[:account_id]
          end
          user_list.each do |item|
            menu.choice name: item[:name], value: item[:account_id]
          end
        end
      end

      def select_sprint(message: 'Please select sprint:', board_id:, state: 'active,future')
        jira_sprint = JiraCommand::Jira::Sprint.new(@config)
        res = jira_sprint.list(
          board_id: board_id,
          query: { state: state }
        )

        @prompt.select(message) do |menu|
          res.each do |item|
            menu.choice name: item[:name], value: item[:id]
          end
        end
      end
    end
  end
end
