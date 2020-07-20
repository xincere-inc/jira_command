require 'jira_command'
require 'thor'
require 'optparse'
require 'pry'
require_relative 'command/list'
require_relative 'command/config'
require_relative 'command/user'
require_relative 'command/assign'
require 'tty-prompt'
require 'base64'

module JiraCommand
  class CLI < Thor
    register(JiraCommand::Command::List, 'list', 'list', 'list up issues')
    register(JiraCommand::Command::Config, 'config', 'config', 'create or clear configuration')
    register(JiraCommand::Command::User, 'user', 'user', 'list all users')
    register(JiraCommand::Command::Assign, 'assign', 'assign', 'assign features')
  end
end
