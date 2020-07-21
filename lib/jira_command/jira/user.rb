require 'jira_command'
require 'thor'
require 'optparse'
require 'pry'
require 'pathname'
require 'fileutils'
require 'json'
require 'faraday'
require_relative 'base'

module JiraCommand
  module Jira
    class User < JiraCommand::Jira::Base
      BASE_PATH = 'rest/api/2/user/assignable/search?project='.freeze

      def all_list(project:)
        request_url = BASE_PATH + project

        res = @conn.get(request_url)

        body = JSON.parse(res.body)

        body.map { |item| { name: item['displayName'], account_id: item['accountId'] } }
      end

      def show_assignable(project:)
        puts all_list(project: project).map(:name)
      end
    end
  end
end
