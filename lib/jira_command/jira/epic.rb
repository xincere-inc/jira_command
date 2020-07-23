require 'jira_command'
require 'json'
require 'faraday'

require_relative 'base'

module JiraCommand
  module Jira
    class Epic < JiraCommand::Jira::Base
      def list(board_id:)
        res = @conn.get("rest/agile/1.0/board/#{board_id}/epic")

        body = JSON.parse(res.body)

        body['values'].map { |item| { name: item['name'], id: item['id'] } }
      end

      def move_issue(issue_key:, epic_id:)
        @conn.post do |req|
          req.url "rest/agile/1.0/epic/#{epic_id}/issue"
          req.body = {
            issues: [
              issue_key
            ]
          }.to_json
        end
      end

      def issue_key_without_epic
        res = @conn.get('rest/agile/1.0/epic/none/issue')
        body = JSON.parse(res.body)

        body['issues'].map { |item| item['key'] }
      end
    end
  end
end
