require 'jira_command'
require 'pry'
require 'json'
require 'faraday'
require_relative 'base'

module JiraCommand
  module Jira
    class Status < JiraCommand::Jira::Base
      BASE_PATH = 'rest/api/2/status'.freeze

      def list
        res = @conn.get(BASE_PATH)

        body = JSON.parse(res.body)

        body.map { |item| { id: item['id'], name: item['untranslatedName'] } }
      end

      def transite(issue_key:, target_status_id:)
        request_url = "rest/api/2/issue/#{issue_key}/transitions"

        @conn.post do |req|
          req.url request_url
          req.body = { transition: { id: target_status_id } }.to_json
        end
      end
    end
  end
end
