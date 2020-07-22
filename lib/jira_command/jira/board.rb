require 'jira_command'
require 'json'
require 'faraday'
require_relative 'base'

module JiraCommand
  module Jira
    class Board < JiraCommand::Jira::Base
      BASE_PATH = 'rest/agile/1.0/board'.freeze

      def list
        res = @conn.get(BASE_PATH)

        body = JSON.parse(res.body)

        body['values'].map do |item|
          location = item['location']
          { name: item['name'],
            id: item['id'],
            projectId: location['projectId'],
            projectName: location['projectName'],
            projectKey: location['projectKey'] }
        end
      end
    end
  end
end
