# frozen_string_literal: true

require 'aws-sdk-s3'
require_relative 'aws_errors'
require_relative 'aws_base'
module TestHelpers
  module AWS
    # This class is used to collect information for S3 buckets and files provided.
    class S3 < TestHelpers::AWS::Base
      attr_reader :s3_resource, :s3Client

      def initialize(options)
        super options
        @s3_client = Aws::S3::Client.new(@aws_options)
        @s3_resource = Aws::S3::Resource.new(
          client: @s3_client
        )
      rescue StandardError => e
        handle_error e
      end

      ## Lists all the file names in the bucket and path provided
      # bucket :String
      # path: path to the folder (S3 key)
      # return an array of strings
      def list_files(bucket, path)
        files = @s3_resource.bucket(bucket).objects(prefix: path).collect(&:key)
        files.delete_if { |file| file == add_slash(path) }
        files
      end

      ## checks for existence of file in folder (S3 key)
      # bucket: String
      # path: path of the folder in S3
      # file_name: name of the file
      # return boolean
      def file_exists?(bucket, path, file_name)
        files = list_files(bucket, path)
        return false if files.length.zero?

        selected_files = files.select { |file_path| file_path.include? file_name }
        selected_files.length.zero? ? false : true
      end

      ## retrieves the key provided to access the properties.
      # @param bucket: String, name of the bucket in s3
      # @param file_path: String, fully qualified path of the file from the bucket onwards
      # @return Aws::S3::ObjectSummary::Collection or nil if data is not found
      def get_file_details(bucket, file_path)
        return nil unless file_exists?(bucket, file_path, file_path)

        @s3_resource.bucket(bucket).objects(prefix: file_path)
      end

      ## Uploads a single file to S3 bucket
      # @param bucket: STRING, name of the bucket where you want to store the data
      # @param file: STRING, name of the file whose contenst are to be uploaded
      # @param target_key: String, key of the location where the file is to be uploaded
      # @param options: any additional options to be added to the upload
      def upload_file(bucket, file, target_key, options = {})
        payload = {
          body: File.read(file),
          key: target_key.to_s
        }.merge options

        @s3_resource.bucket(bucket).put_object(payload)
      rescue Aws::S3::Errors::NoSuchBucket => e
        puts "Bucket '#{bucket}' does not exist"
        puts 'The operation could not be completed with the options provided'
        puts "Bucket: #{bucket}, File: #{file}, Target: #{target_key}, Options: #{options}"
        handle_error e
      rescue Errno::ENOENT => e
        puts "File '#{file}' does not exist"
        puts 'The operation could not be completed with the options provided'
        puts "Bucket: #{bucket}, File: #{file}, Target: #{target_key}, Options: #{options}"
        handle_error e
      rescue StandardError => e
        puts 'The operation could not be completed with the options provided'
        puts "Bucket: #{bucket}, File: #{file}, Target: #{target_key}, Options: #{options}"
        handle_error e
      end

      ## deletes the key provided
      # return void
      def delete_files(bucket, key)
        @s3_resource.bucket(bucket).objects(prefix: key).each do |file|
          file.delete
          puts "Deleted #{file.key} in #{bucket}"
        end
      rescue Aws::S3::Errors::NoSuchBucket => e
        puts "Bucket '#{bucket}' does not exist"
        handle_error e
      rescue StandardError => e
        handle_error e
      end

      def download_files(bucket, directory, download_target)
        list_files(bucket, directory).each do |file|
          download_file(bucket, file, download_target)
        end
        puts "Downloaded data from #{directory}, under #{bucket}"
      rescue Aws::S3::Errors::NoSuchBucket => e
        puts "Bucket '#{bucket}' does not exist"
        handle_error e
      rescue StandardError => e
        puts "Could not download data from #{directory}, under #{bucket}"
        handle_error e
      end

      def download_file(bucket, key, download_target)
        @download_target = download_target
        raise TestHelpers::AWS::FileNotFound unless file_exists?(bucket, key.split('/')[0...-1].join('/'), key.split('/')[-1])

        download(@s3_resource.bucket(bucket).object(key))
        puts "Downloaded file #{key} to #{download_target}"
      end

      private

      def download(file_object)
        file_object.download_file("#{@download_target}/#{file_object.key.split('/')[-1]}")
      end

      def add_slash(file_name)
        file_name.match?(%r{/$}) ? file_name : "#{file_name}/"
      end

      def handle_error(err)
        puts err.backtrace
        raise err
      end
    end
  end
end
