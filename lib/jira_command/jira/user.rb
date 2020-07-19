require 'jira_command'
require 'thor'
require 'optparse'
require 'pry'
require 'pathname'
require 'fileutils'
require 'json'
require 'faraday'
require 'terminal-table'

module JiraCommand
  module Jira
    class User
      attr_writer :config, :conn

      def initialize(config)
        @config = config
        @conn = Faraday.new(url: config['jira_url']) do |faraday|
          faraday.request  :url_encoded
          faraday.adapter  Faraday.default_adapter
          faraday.headers['Content-Type'] = 'application/json'
        end
      end

      def all_list(project:)
        request_url = 'rest/api/2/user/assignable/search?project=' + project

        res = @conn.get do |req|
          req.url request_url
          req.headers['Content-Type'] = 'application/json'
          req.headers['Authorization'] = 'Basic ' + @config['header_token']
        end

        body = JSON.parse(res.body)

        body.map { |item| { name: item['displayName'], account_id: item['accountId'] } }
      end

      def show_assignable(project:)
        puts all_list(project: project).map { |item| item[:name] }
      end
    end
  end
end
