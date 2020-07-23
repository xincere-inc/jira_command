require 'jira_command'
require 'optparse'

require 'pathname'
require 'fileutils'
require 'json'
require 'faraday'

module JiraCommand
  module Jira
    class Base
      attr_writer :config, :conn

      def initialize(config)
        @config = config
        @conn = Faraday.new(url: config[:jira_url]) do |faraday|
          faraday.request :url_encoded
          faraday.headers['Accept'] = 'application/json'
          faraday.headers['Content-Type'] = 'application/json'
          faraday.headers['Authorization'] = 'Basic ' + @config[:header_token]
          faraday.adapter Faraday.default_adapter
        end
      end
    end
  end
end
