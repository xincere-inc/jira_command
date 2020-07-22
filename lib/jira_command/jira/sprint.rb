require 'jira_command'
require 'faraday'
require 'json'
require_relative 'base'

module JiraCommand
  module Jira
    class Sprint < JiraCommand::Jira::Base
      # https://docs.atlassian.com/jira-software/REST/7.3.1/#agile/1.0/board/{boardId}/sprint-getAllSprints
      def list(board_id:, query:)
        res = @conn.get("rest/agile/1.0/board/#{board_id}/sprint?" +  + URI.encode_www_form(query))
        body = JSON.parse(res.body)

        body['values'].map { |item| { name: item['name'], id: item['id'], state: item['state'], 
        start_date: name: item['startDate'],
        end_date: name: item['endDate']} }
      end


      # https://docs.atlassian.com/jira-software/REST/7.3.1/#agile/1.0/sprint-createSprint
      def create(name:, board_id:, start_date:, end_date:)
        request_body = {
          name: name,
          originBoardId: board_id,
          startDate: start_date,
          endDate: end_date
        }

        @conn.post do |req|
          req.url 'rest/agile/1.0/sprint'
          req.body = request_body.to_json
        end
      end
    end
  end
end


