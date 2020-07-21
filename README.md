# JiraCommand

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/jira_command`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jira_command'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jira_command

## Usage

You need to get token in [JIRA](https://id.atlassian.com/manage-profile/security).

```bash
$ jira_command config create
> Please input your site url: https://<your-domain>.atlassian.net/
> Please input your registered email address: <example@xincere.jp>
> Please input your token: <token got in jira>

$ jira_command help
Commands:
  jira_command assign          # set or unset assign in issue
  jira_command config          # create or clear configuration
  jira_command help [COMMAND]  # Describe available commands or one specific command
  jira_command issue           # create a issue
  jira_command list            # list up issues
  jira_command status          # show all status in project
  jira_command transition      # transition issues
  jira_command user            # list all users
```

<b>if you want to cache items in your local to reduce api call, you can refer the following commands.</b>

```bash
$ jira_command config help
Commands:
  jira_command config clear                              # clear config file
  jira_command config create                             # create config file
  jira_command config help [COMMAND]                     # Describe subcommands or one specific subcommand
  jira_command config update_it                          # update default issue_type in config file
  jira_command config update_projects                    # update default projects in config file
  jira_command config update_users p, --project=PROJECT  # update default users in config file

$ jira_command config help update_it
Usage:
  jira_command config update_it

update default issue_type in config file

$ bundle exec exe/jira_command config help update_projects
Usage:
  jira_command config update_projects

update default projects in config file

$ bundle exec exe/jira_command config help update_users
Usage:
  jira_command config update_users p, --project=PROJECT

Options:
  p, --project=PROJECT

update default users in config file
```

<b>the most useful commands</b>

```bash
$ jira_command list help my
Usage:
  jira_command list my

Options:
  c, [--current=CURRENT]
  u, [--unresolved=UNRESOLVED]

list your issues


$ jira_command list help my
Usage:
  jira_command list my

Options:
  c, [--current=CURRENT]
  u, [--unresolved=UNRESOLVED]

list your issues

$ jira_command transition help issue
Usage:
  jira_command transition issue

Options:
  c, [--current=CURRENT]
  m, [--mine=MINE]

transit issue status

$ jira_command assign help exec
Usage:
  jira_command assign exec i, --issue=ISSUE

Options:
  i, --issue=ISSUE
  ru, [--refresh-user=REFRESH-USER]

assign to user
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jira_command. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/jira_command/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JiraCommand project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jira_command/blob/master/CODE_OF_CONDUCT.md).
