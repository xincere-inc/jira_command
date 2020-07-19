require 'jira_command'
require 'thor'
require 'optparse'
require 'pry'
require_relative 'jira/config'
require 'faraday'
require 'terminal-table'

module JiraCommand
  class CLI < Thor
    desc 'list', 'list all issues'
    option 'assginee', aliases: 'a', required: false
    option 'help', aliases: 'h', required: false
    option 'project', aliases: 'p', required: false
    option 'unresolved', aliases: 'n', required: false
    def list
      unless options['help'].nil?
        puts '--help (-h): show help'
        puts '--assginee (-a): specify assginee'
        puts '--project (-p): specify project'
        puts '--unresolved (-n): filter out resolved issues'
      end

      config = JiraCommand::Jira::Config.new.read

      conn = Faraday.new(url: config['jira_url']) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end

      request_url = '/rest/api/2/search?fields=id,key,status,issuetype,assignee,summary&jql='
      request_url += 'status not in (resolved)' unless options['unresolved'].nil?

      res = conn.get do |req|
        req.url request_url
        req.headers['Content-Type'] = 'application/json'
      end

      body = JSON.parse(res.body)

      issue_list = body['issues'].map do |issue|
        { key: issue['key'],
          summary: issue['fields']['summary'],
          assignee: issue['fields']['assignee'].nil? ? 'not assinged' : issue['fields']['assignee']['displayName'],
          type: issue['fields']['issuetype']['name'],
          status: issue['fields']['status']['name'],
          link: 'https://xincere-inc.atlassian.net/browse/' + issue['key'] }
      end

      table = Terminal::Table.new
      table.headings = issue_list.first.keys
      table.rows = issue_list.sort_by { |data| "#{data['status']}-#{data['key']}-#{data['type']}" }.map(&:values)

      puts table
    end

    desc 'config', 'config jira'
    option 'url', aliases: 'u', required: true
    option 'help', aliases: 'h', required: false
    def config
      unless options['help'].nil?
        puts '--help (-h): show help'
        puts '--url (-u): specify base url'
      end

      jira_url = options['url']
      jira_url += '/' unless jira_url.end_with?('/')
      config = { jira_url: jira_url }

      JiraCommand::Jira::Config.new.write(config)
    end
  end
end
