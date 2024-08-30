# frozen_string_literal: true

require 'roo'
# Module to work with the xlsx parser
# This module uses the Roo gem
module TestHelpers
  module Parser
    # Class for the xlsx parser.
    class Xlsx
      attr_accessor :workbook

      # @param file_path [String] the file path for the xlsx file.
      def initialize(file_path)
        @workbook = Roo::Spreadsheet.open(file_path, extension: :xlsx)
      end

      ##
      # Returns a Hash collected from 2 excel columns (key and value columns)
      # @param key_col - [Fixnum] O indexed column number for key
      # @param value_col - [Fixnum] O indexed column number for value
      # @param sheet_no - [Fixnum] 0 indexed number for the sheet
      # @param from_row - [Fixnum] 1 indexed number for row to start from
      # @param to_row - [Fixnum] 1 indexed number for row to end
      #                             -1 means collect till the last row
      # @param name - [String]
      # @return [Hash]
      #
      # The below two functions thast are implementations with keyword parameters. They are made backward compatible
      def row_hash_new(key_col:, value_col:, sheet_no: 0, from_row: 1, to_row: -1, sheet_name: nil)
        sheet = sheet_name.nil? ? @workbook.sheet(sheet_no) : get_sheet_by_name(sheet_name)

        result = {}
        this_row = from_row
        max = to_row == -1 ? sheet.last_row : to_row
        while this_row <= max
          result[sheet.row(this_row)[key_col]] = sheet.row(this_row)[value_col]
          this_row += 1
        end
        result
      end

      ##
      # Returns array of hashes collected from titled table within excel sheet
      # @param title_row - [Fixnum] 1 indexed row in excel sheet
      #                               designated as header of the table.
      # @param sheet_no - [Fixnum] 0 indexed number of the sheet
      # @param to_row - [Fixnum] 1 indexed number for row to end
      #                               -1 means collect till the last row
      def table_hashes_new(title_row: 1, sheet_no: 0, to_row: -1, sheet_name: nil)
        sheet = sheet_name.nil? ? @workbook.sheet(sheet_no) : get_sheet_by_name(sheet_name)

        keys = sheet.row(title_row)
        result = []
        this_row = title_row + 1
        max = to_row == -1 ? sheet.last_row : to_row
        while this_row <= max
          obj = {}
          keys.each_with_index { |key, id| obj[key] = sheet.row(this_row)[id].to_s }
          result << obj
          this_row += 1
        end
        result
      end

      ## Kept here to maintain backward compatibility. Use row_hash_new instead
      def row_hash(key_col, value_col, sheet_no = 0, from_row = 1, to_row = -1)
        row_hash_new(key_col: key_col, value_col: value_col, sheet_no: sheet_no, from_row: from_row, to_row: to_row)
      end

      ## Kept here to maintain backward compatibility. Use table_hashes_new instead
      def table_hashes(title_row = 1, sheet_no = 0, to_row = -1)
        table_hashes_new(title_row: title_row, sheet_no: sheet_no, to_row: to_row)
      end

      def column_array(column, sheet_no = 0, from_row = 1, to_row = -1)
        sheet = @workbook.sheet(sheet_no)
        max = to_row == -1 ? sheet.last_row : to_row
        sheet.column(column)[from_row..max]
      end

      def row_array(row, sheet_no = 0)
        @workbook.sheet(sheet_no).row(row)
      end

      def first_occurrence_row(key_word, sheet_no = 0)
        sheet = @workbook.sheet(sheet_no)
        result = 0
        found = false
        while result < sheet.last_row
          result += 1
          this_row = sheet.row(result)
          if this_row.include?(key_word)
            found = true
            break
          end
        end
        result = -1 unless found
        result
      end

      def count(sheet_no)
        sheet = @workbook.sheet(sheet_no)
        sheet.count
      end

      def get_sheet_by_name(name)
        index = @workbook.sheets.index(name)
        @workbook.sheet(index)
      end
    end
  end
end
