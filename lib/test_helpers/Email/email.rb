# frozen_string_literal: true

require 'mail'

module TestHelpers
  class Email
    attr_reader :server, :port, :address, :user, :password, :email

    SEARCH_TYPE = %w[subject body].freeze

    def initialize(user_name:, password:, address: 'outlook.office365.com', port: 995, method: :pop3)
      default_values = {
        address: address,
        port: port,
        user_name: user_name,
        password: password,
        enable_ssl: true
      }
      Mail.defaults do
        retriever_method method,
                         default_values
      end
    end

    def all_mail_since(timestamp)
      return Mail.all if timestamp.nil?

      Mail.all.select { |mail| mail.date.to_time.to_i >= timestamp }
    end

    ## Retrieves the last mail since the time stamp
    def last_mail_since(timestamp)
      all_mail_since(timestamp).last
    end

    # MEta programming to get the methods as last_<search>_since timestamp
    # This will return the last email after the time stamp.
    ##### Be aware that if there is another email AFTER the email you are looking for,
    # there might be an error
    SEARCH_TYPE.each do |search_type|
      define_method("last_#{search_type}_since") do |time_stamp|
        search_in = search_method(search_type)
        search_in.inject(last_mail_since(time_stamp), :send)
      end
    end

    # Meta programming to filter emails. You can search by find_by_<search_type>
    # Returns an Array of mails.
    SEARCH_TYPE.each do |search_type|
      define_method("find_by_#{search_type}") do |search_field|
        search_in = search_method(search_type)
        Mail.all.select { |mail| search_in.inject(mail, :send).include? search_field }
      end
    end

    SEARCH_TYPE.each do |search_type|
      define_method("find_by_#{search_type}_since") do |search_field, timestamp|
        search_in = search_method(search_type)
        mails = all_mail_since(timestamp)
        mails.select { |mail| search_in.inject(mail, :send).include? search_field }
      end
    end

    def delete_all_mail_since(timestamp)
      Mail.find_and_delete(delete_after_find: true, count: 20) do |mail|
        if mail.date.to_time.to_i < timestamp
          mail.skip_deletion
          next
        end
      end
    end

    SEARCH_TYPE.each do |search_type|
      define_method("delete_by_#{search_type}_since") do |search_char, timestamp|
        Mail.find_and_delete(delete_after_find: true, count: 20) do |mail|
          if mail.date.to_time.to_i < timestamp
            mail.skip_deletion
            next
          end
          search_using_methods = search_method(search_type)

          search_in = search_using_methods.inject(mail, :send)
          if search_in.include? search_char
            puts "Deleting mail Subject: #{mail.subject}"
          else
            mail.skip_deletion
          end
        end
      end
    end

    private

    def search_method(search_type)
      method = []
      case search_type
      when 'subject'
        method = [:subject]
      when 'body'
        method = %i[text_part decoded]
      end
      method
    end
  end
end
