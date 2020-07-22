require_relative '../config'
require_relative '../jira/sprint'
require_relative '../jira/user'
require 'tty-prompt'

module JiraCommand
  module Prompt
    class Base
      attr_writer :prompt, :config

      def initialize
        prompt = TTY::Prompt.new
        config = JiraCommand::Config.new.read
      end

      def select_user(message = 'who are you?')
        user_list = if options['refresh-user'].nil?
                      @config[:users]
                    else
                      user_api = JiraCommand::Jira::User.new(@config)
                      user_api.all_list(project: project[:key])
        end

        @prompt.select(message) do |menu|
          user_list.each do |user|
            menu.choice name: user[:name], value: user[:account_id]
          end
        end
      end
    end
  end
end
