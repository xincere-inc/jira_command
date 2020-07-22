require 'jira_command'
require 'faraday'
require 'json'
require_relative 'base'

module JiraCommand
  module Jira
    class Issue < JiraCommand::Jira::Base
      BASE_PATH = 'rest/api/2/issue'.freeze

      def comment(issue_key:, message:)
        @conn.post do |req|
          req.url "rest/api/2/issue/#{issue_key}/comment"
          req.body = {
            body: message
          }.to_json
        end
      end

      def create(summary:, description:, assignee:, reporter:, project_id:, issuetype_id:)
        request_body = { fields: {
          project: {
            id: project_id
          },
          summary: summary,
          issuetype: {
            id: issuetype_id
          },
          reporter: {
            id: reporter
          },
          description: description
        } }

        unless assignee.nil?
          request_body.merge!(assignee: {
                                id: assignee
                              })
        end

        res = @conn.post do |req|
          req.url BASE_PATH
          req.body = request_body.to_json
        end

        body = JSON.parse(res.body)

        body['key']
      end
    end
  end
end
