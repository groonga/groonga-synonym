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

module GroongaSynonym
  class Synonym
    attr_reader :term
    attr_reader :weight
    def initialize(term, weight=nil)
      @term = term
      @weight = weight
    end

    def to_groonga
      formatted = ""
      if @weight and @weight != 1.0
        formatted << ">" << ("%f" % (@weight - 1)).gsub(/0+\z/, "")
      end
      formatted << escape_term(@term)
      formatted
    end

    def ==(other)
      other.is_a?(self.class) and
        @term == other.term and
        @weight == other.weight
    end

    def eql?(other)
      self == other
    end

    def hash
      [@term, @weight].hash
    end

    private
    def escape_term(term)
      return "\"#{term}\"" if term == "OR"
      term = term.gsub(/["()\\*:+-]/) do |matched|
        "\\#{matched}"
      end
      if term.include?(" ")
        "\"#{term}\""
      else
        term
      end
    end
  end
end
