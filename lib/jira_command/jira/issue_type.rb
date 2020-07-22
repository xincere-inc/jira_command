require 'jira_command'
require 'faraday'
require 'json'
require_relative 'base'

module JiraCommand
  module Jira
    class IssueType < JiraCommand::Jira::Base
      BASE_PATH = 'rest/api/2/issuetype'.freeze

      def list
        res = @conn.get(BASE_PATH)
        body = JSON.parse(res.body)

        body.map { |item| { name: item['untranslatedName'], id: item['id'] } }
      end
    end
  end
end
