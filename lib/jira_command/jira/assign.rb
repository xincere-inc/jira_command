require 'jira_command'
require 'thor'
require 'optparse'

require 'pathname'
require 'fileutils'
require 'json'
require 'faraday'
require 'json'
require_relative 'base'

module JiraCommand
  module Jira
    class Assign < JiraCommand::Jira::Base
      def execute(issue_key:, assignee:)
        request_url = "rest/api/3/issue/#{issue_key}/assignee"
        @conn.put do |req|
          req.url request_url
          req.body = { accountId: assignee }.to_json
        end
      end

      def unassigne(issue_key:)
        request_url = "rest/api/3/issue/#{issue_key}/assignee"
        @conn.put do |req|
          req.url request_url
          req.body = { accountId: -1 }.to_json
        end
      end
    end
  end
end
