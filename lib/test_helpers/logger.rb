# frozen_string_literal: true

require 'rainbow'

# Logging class used as a class method
module TestHelpers
  class Logger
    class << self
      def log(str, level = :info)
        message = format_message(str, level.to_sym)
        puts message
      end

      private

      def format_message(str, level)
        prefix =  ''
        suffix = ''
        time = "[#{Time.now.utc.strftime('%Y-%m-%d-%H:%M:%S:%L_%Z')}]"
        case level
        when :error
          prefix = '[ERROR]-- '
          suffix = "\n[ERROR END]"
          color = :red
        when :info
          prefix = '[INFO]-- '
          color  = :white
        when :debug
          prefix = '[DEBUG]-- '
          suffix = '[DEBUG END]'
          color  = :yellow
        end
        string = "#{time} #{prefix}#{str}#{suffix}"
        Rainbow(string).send(color)
      end
    end
  end
end
