require 'jira_command'
require 'thor'
require 'optparse'
require 'tty-prompt'
require_relative '../config'
require_relative '../jira/issuetype'
require_relative '../jira/project'
require_relative '../jira/user'
require 'base64'

module JiraCommand
  module Command
    class Config < Thor
      desc 'create', 'create config file'
      def create
        if JiraCommand::Config.check_exist
          puts 'config file has been already existed. if you want to renew it, please execute `jira_command config clear` first'
          exit 1
        end

        prompt = TTY::Prompt.new

        jira_url = prompt.ask('Please input your site url:')
        email = prompt.ask('Please input your registered email address:')
        token = prompt.mask('Please input your token:')

        jira_url += '/' unless jira_url.end_with?('/')
        config = { jira_url: jira_url, header_token: Base64.strict_encode64("#{email}:#{token}") }

        JiraCommand::Config.new.write(config)
      end

      desc 'update_projects', 'update default projects in config file'
      def update_projects
        config = JiraCommand::Config.new.read

        jira_project = JiraCommand::Jira::Project.new(config)
        config.merge!({
                        projects: jira_project.list
                      })
        JiraCommand::Config.new.write(config)
      end

      desc 'update_users', 'update default users in config file'
      option 'project', aliases: 'p', required: true
      def update_users
        config = JiraCommand::Config.new.read
        user_api = JiraCommand::Jira::User.new(config)
        config.merge!({
                        users: user_api.all_list(project: options[:project])
                      })
        JiraCommand::Config.new.write(config)
      end

      desc 'update_it', 'update default issue_type in config file'
      def update_it
        config = JiraCommand::Config.new.read
        jira_issue_type = JiraCommand::Jira::IssueType.new(config)
        config.merge!({
                        issue_types: jira_issue_type.list
                      })
        JiraCommand::Config.new.write(config)
      end

      desc 'clear', 'clear config file'
      def clear
        prompt = TTY::Prompt.new
        JiraCommand::Config.new.clear if prompt.yes?('Are you sure to clear?')
      end
    end
  end
end
