# Copyright (C) 2021  Sutou Kouhei <kou@clear-code.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "optparse"

module GroongaSynonym
  module CommandLine
    class Generator
      AVAILABLE_SOURCES = [
        :sudachi,
      ]

      AVAILABLE_FORMATS = [
        :groonga,
        :pgroonga,
      ]

      def initialize(output=nil)
        @source = AVAILABLE_SOURCES.first
        @format = AVAILABLE_FORMATS.first
        @table = nil
        @term_column = nil
        @synonyms_column = nil
        @synonyms_column_is_vector = true
        @output = output || "-"
        @defaults = {
          groonga: {
            table: "Thesaurus",
            term_column: "_key",
            synonyms_column: "synonyms",
          },
          pgroonga: {
            table: "thesaurus",
            term_column: "term",
            synonyms_column: "synonyms",
          },
        }
      end

      def run(args)
        catch do |tag|
          parse_args(args, tag)
          source = create_source
          open_output do |output|
            generator = create_generator(source, output)
            generator.generate
            true
          end
        end
      end

      private
      def format_availables(availables)
        "[" + availables.join(", ") + "]"
      end

      def format_defaults(key)
        AVAILABLE_FORMATS.collect do |format|
          "#{format}: (#{@defaults[format][key]})"
        end
      end

      def parse_args(args, tag)
        parser = OptionParser.new
        parser.on("--source=SOURCE",
                  AVAILABLE_SOURCES,
                  "Synonym source",
                  format_availables(AVAILABLE_SOURCES),
                  "(#{@source})") do |source|
          @source = source
        end
        parser.on("--format=FORMAT",
                  AVAILABLE_FORMATS,
                  "Output format",
                  format_availables(AVAILABLE_FORMATS),
                  "(#{@format})") do |format|
          @format = format
        end
        parser.on("--table=TABLE",
                  "Synonyms table's name",
                  *format_defaults(:table)) do |table|
          @table = table
        end
        parser.on("--term-column=COLUMN",
                  "Term column's name",
                  *format_defaults(:term_column)) do |column|
          @term_column = column
        end
        parser.on("--synonyms-column=COLUMN",
                  "Synonyms column's name",
                  *format_defaults(:synonyms_column)) do |column|
          @synonyms_column = column
        end
        parser.on("--no-synonyms-column-is-vector",
                  "Synonyms column isn't a vector column",
                  "This is only for 'groonga' source") do |boolean|
          @synonyms_column_is_vector = boolean
        end
        parser.on("--output=OUTPUT",
                  "Output path",
                  "'-' means the standard output",
                  "(#{@output})") do |output|
          @output = output
        end
        parser.on("--version",
                  "Show version and exit") do
          puts(VERSION)
          throw(tag, true)
        end
        parser.on("--help",
                  "Show this message and exit") do
          puts(parser.help)
          throw(tag, true)
        end
        parser.parse!(args.dup)
      end

      def open_output(&block)
        case @output
        when "-"
          yield($stdout)
        when String
          File.open(@output, "w", &block)
        else
          yield(@output)
        end
      end

      def create_source
        case @source
        when :sudachi
          Sudachi.new
        end
      end

      def create_generator(source, output)
        options = {
          output: output,
        }
        case @format
        when :groonga
          default = @defaults[:groonga]
          term_column = @term_column || default[:term_column]
          synonyms_column = @synonyms_column || default[:synonyms_column]
          options[:synonyms_column_is_vector] = @synonyms_column_is_vector
          GroongaGenerator.new(source,
                               term_column,
                               synonyms_column,
                               **options)
        when :pgroonga
          default = @defaults[:pgroonga]
          table = @table || default[:table]
          term_column = @term_column || default[:term_column]
          synonyms_column = @synonyms_column || default[:synonyms_column]
          PGroongaGenerator.new(source,
                                table,
                                term_column,
                                synonyms_column,
                                **options)
        end
      end
    end
  end
end
