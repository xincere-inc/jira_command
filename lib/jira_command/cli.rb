require 'jira_command'
require 'thor'
require_relative 'command/list'
require_relative 'command/config'
require_relative 'command/user'
require_relative 'command/assign'
require_relative 'command/status'
require_relative 'command/transition'

module JiraCommand
  class CLI < Thor
    register(JiraCommand::Command::List, 'list', 'list', 'list up issues')
    register(JiraCommand::Command::Config, 'config', 'config', 'create or clear configuration')
    register(JiraCommand::Command::User, 'user', 'user', 'list all users')
    register(JiraCommand::Command::Assign, 'assign', 'assign', 'set or unset assign in issue')
    register(JiraCommand::Command::Status, 'status', 'status', 'show all status in project')
    register(JiraCommand::Command::Transition, 'transition', 'transition', 'transition issues')
  end
end
