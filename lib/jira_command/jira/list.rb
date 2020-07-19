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
    class List
      attr_writer :config, :conn

      def initialize(config)
        @config = config
        @conn = Faraday.new(url: config['jira_url']) do |faraday|
          faraday.request  :url_encoded
          faraday.adapter  Faraday.default_adapter
          faraday.headers['Content-Type'] = 'application/json'
        end
      end

      def list(unresolved:)
        request_url = 'rest/api/2/search?' + URI.encode_www_form({ fields: 'id,key,status,issuetype,assignee,summary',
                                                                   jql: 'status not in (resolved)' })

        res = @conn.get do |req|
          req.url request_url
          req.headers['Content-Type'] = 'application/json'
          req.headers['Authorization'] = 'Basic ' + @config['header_token']
        end

        body = JSON.parse(res.body)

        issue_list = body['issues'].map do |issue|
          { key: issue['key'],
            summary: issue['fields']['summary'],
            assignee: issue['fields']['assignee'].nil? ? 'not assinged' : issue['fields']['assignee']['displayName'],
            type: issue['fields']['issuetype']['name'],
            status: issue['fields']['status']['name'],
            link: @config['jira_url'] + 'browse/' + issue['key'] }
        end

        table = Terminal::Table.new
        table.headings = issue_list.first.keys
        table.rows = issue_list.sort_by { |data| "#{data['status']}-#{data['key']}-#{data['type']}" }.map(&:values)

        puts table
      end
    end
  end
end
