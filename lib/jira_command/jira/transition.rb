require 'jira_command'
require 'pry'
require 'json'
require 'faraday'
require_relative 'base'

module JiraCommand
  module Jira
    class Transition < JiraCommand::Jira::Base
      def list(issue_key:)
        request_url = "rest/api/2/issue/#{issue_key}/transitions"
        res = @conn.get(request_url)

        res = JSON.parse(res.body)

        res['transitions'].map { |item| { id: item['id'].to_i, name: item['name'] } }
      end

      def transite(issue_key:, target_transition_id:)
        request_url = "rest/api/2/issue/#{issue_key}/transitions"

        res = @conn.post do |req|
          req.url request_url
          req.body = { transition: { id: target_transition_id } }.to_json
        end
      end
    end
  end
end
