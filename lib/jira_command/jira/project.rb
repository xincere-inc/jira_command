require 'jira_command'
require 'faraday'
require 'json'
require_relative 'base'

module JiraCommand
  module Jira
    class Project < JiraCommand::Jira::Base
      BASE_PATH = 'rest/api/2/project'.freeze

      def list
        res = @conn.get(BASE_PATH)
        body = JSON.parse(res.body)

        body.map { |item| { name: item['name'], id: item['id'], key: item['key'] } }
      end
    end
  end
end
