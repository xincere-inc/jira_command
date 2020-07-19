require 'jira_command'
require 'thor'
require 'optparse'
require 'pry'
require 'pathname'
require 'fileutils'
require 'json'
require 'faraday'
require 'json'

module JiraCommand
  module Jira
    class Assign
      attr_writer :config, :conn

      def initialize(config)
        @config = config
        @conn = Faraday.new(url: config['jira_url']) do |faraday|
          faraday.request :url_encoded
          faraday.headers['Accept'] = 'application/json'
          faraday.headers['Content-Type'] = 'application/json'
          faraday.headers['Authorization'] = 'Basic ' + config['header_token']
          faraday.adapter Faraday.default_adapter
        end
      end

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
