require 'str_convert_utils'
require 'thor'

module StrConvertUtils
  class CLI < Thor
    desc 'camelize {snake_case_string}', 'convert {snake_case_string} to {camelCaseString}'
    def camelize(str)
      puts str.split('_').map do |w|
        w[0] = w[0].upcase
        w
      end.join
    end

    desc 'snake {CamelCaseString}', 'convert {CamelCaseString} to {snake_case_string}'
    def snake(str)
      puts str
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
    end
  end
end
