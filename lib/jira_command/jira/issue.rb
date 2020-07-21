require 'jira_command'
require 'faraday'
require 'json'
require_relative 'base'

module JiraCommand
  module Jira
    class Issue < JiraCommand::Jira::Base
      BASE_PATH = 'rest/api/2/issue'.freeze

      def create(summary:, description:, assignee:, reporter:, project_id:, issuetype_id:)
        request_body = { fields: {
          project: {
            id: project_id
          },
          summary: summary,
          issuetype: {
            id: issuetype_id
          },
          assignee: {
            id: assignee
          },
          reporter: {
            id: reporter
          },
          description: description
        } }.to_json

        res = @conn.post do |req|
          req.url BASE_PATH
          req.body = request_body
        end

        body = JSON.parse(res.body)

        @config['jira_url'] + 'browse/' + body['key']
      end
    end
  end
end
