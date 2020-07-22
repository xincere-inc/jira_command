require 'thor'
require 'optparse'
require 'tty-prompt'
require_relative '../config'
require_relative '../jira/transition'

module JiraCommand
  module Command
    class Transition < Thor
      desc 'exec', 'transit issue status'
      option 'issue', aliases: 'i', required: true
      def exec
        config = JiraCommand::Config.new.read

        jira = JiraCommand::Jira::Transition.new(config)
        res = jira.list(issue_key: options['issue'])

        prompt = TTY::Prompt.new

        target_transition_id = prompt.select('Which status do you want to transite?') do |menu|
          res.each do |transition|
            menu.choice name: transition[:name], value: transition[:id]
          end
        end

        jira.transite(issue_key: options['issue'], target_transition_id: target_transition_id)
      end

      desc 'issue', 'transite issue status'
      option 'current', aliases: 'c', required: false
      option 'mine', aliases: 'm', required: false
      def issue
        jql = []
        jql << 'sprint in openSprints()' unless options['current'].nil?
        jql << 'assignee=currentUser()' unless options['mine'].nil?

        config = JiraCommand::Config.new.read

        list = JiraCommand::Jira::List.new(config)
        issues_list = list.list({ fields: 'key,status,assignee,summary',
                                  jql: jql.join('&') })

        prompt = TTY::Prompt.new

        issue_key = prompt.select('Which issue do you want to transite?') do |menu|
          issues_list['issues'].map do |i|
            assignee = i['fields']['assignee']
            menu.choice(name: "#{assignee.nil? ? 'not assigned' : assignee['displayName']}: #{i['fields']['summary']}(#{i['fields']['status']['name']})",
                        value: i['key'])
          end
        end

        jira = JiraCommand::Jira::Transition.new(config)
        res = jira.list(issue_key: issue_key)

        target_transition_id = prompt.select('Which status do you want to transite?') do |menu|
          res.each do |transition|
            menu.choice name: transition[:name], value: transition[:id]
          end
        end

        jira.transite(issue_key: issue_key, target_transition_id: target_transition_id)
      end
    end
  end
end
