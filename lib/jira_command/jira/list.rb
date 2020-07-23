require 'jira_command'
require 'thor'
require 'optparse'

require 'pathname'
require 'fileutils'
require 'json'
require 'faraday'
require_relative 'base'

module JiraCommand
  module Jira
    class List < JiraCommand::Jira::Base
      BASE_PATH = 'rest/api/2/search?'.freeze

      def list(query = {})
        request_url = BASE_PATH + URI.encode_www_form(query)
        res = @conn.get(request_url)

        JSON.parse(res.body)
      end
    end
  end
end
