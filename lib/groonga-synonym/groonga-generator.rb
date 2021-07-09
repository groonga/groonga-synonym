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

require "json"

module GroongaSynonym
  class GroongaGenerator
    def initialize(source,
                   term_column,
                   synonyms_column,
                   synonyms_column_is_vector: true,
                   output: $stdout)
      @source = source
      @term_column = term_column
      @synonyms_column = synonyms_column
      @synonyms_column_is_vector = synonyms_column_is_vector
      @output = output
    end

    def generate
      @output.print("[\n")
      @output.print([@term_column, @synonyms_column].to_json)
      @source.each do |term, synonyms|
        @output.print(",\n")
        record = [term]
        formatted_synonyms = synonyms.collect do |synonym|
          formatted_synonym = synonym.to_groonga
          unless @synonyms_column_is_vector
            formatted_synonym = "(#{formatted_synonym})"
          end
          formatted_synonym
        end
        if @synonyms_column_is_vector
          record << formatted_synonyms
        else
          record << formatted_synonyms.join(" OR ")
        end
        @output.print(record.to_json)
      end
      @output.print("\n]\n")
    end
  end
end
