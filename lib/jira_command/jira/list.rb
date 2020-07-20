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

      def list(query = {})
        request_url = 'rest/api/2/search?' + URI.encode_www_form(query)

        res = @conn.get do |req|
          req.url request_url
          req.headers['Content-Type'] = 'application/json'
          req.headers['Authorization'] = 'Basic ' + @config['header_token']
        end

        JSON.parse(res.body)
      end
    end
  end
end
