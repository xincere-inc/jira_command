require 'jira_command'
require 'thor'
require 'optparse'
require 'pry'
require_relative 'jira/config'
require_relative 'jira/list'
require_relative 'jira/user'
require_relative 'jira/assign'
require 'tty-prompt'
require 'base64'

module JiraCommand
  class CLI < Thor
    desc 'list', 'list issues'
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

      list = JiraCommand::Jira::List.new(config)
      list.list(unresolved: options['unresolved'])
    end

    desc 'users', 'list all users'
    option 'project', aliases: 'p', required: false
    def users
      config = JiraCommand::Jira::Config.new.read

      user_api = JiraCommand::Jira::User.new(config)
      user_api.show_assignable(project: options['project'])
    end

    desc 'assign', 'list issues'
    option 'issue', aliases: 'i', required: false
    option 'clear', aliases: 'c', required: false
    def assign
      config = JiraCommand::Jira::Config.new.read

      if options['clear']
        assign = JiraCommand::Jira::Assign.new(config)
        assign.unassigne(issue_key: options['issue'])
        return
      end

      user_api = JiraCommand::Jira::User.new(config)
      user_list = user_api.all_list(project: options['issue'].split('-').first)

      prompt = TTY::Prompt.new

      assignee = prompt.select('Who do you want to assign?') do |menu|
        user_list.each do |user|
          menu.choice name: user[:name], value: user[:account_id]
        end
      end

      assign = JiraCommand::Jira::Assign.new(config)
      user_list = assign.execute(issue_key: options['issue'], assignee: assignee)
    end

    desc 'config', 'config jira'
    option 'help', aliases: 'h', required: false
    def config
      return puts '--help (-h): show help' unless options['help'].nil?

      prompt = TTY::Prompt.new

      jira_url = prompt.ask('Please input your site url:')
      email = prompt.ask('Please input your registered email address:')
      token = prompt.mask('Please input your token:')

      jira_url += '/' unless jira_url.end_with?('/')
      config = { jira_url: jira_url, header_token: Base64.strict_encode64("#{email}:#{token}") }

      JiraCommand::Jira::Config.new.write(config)
    end
  end
end
