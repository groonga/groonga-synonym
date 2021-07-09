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

class SynonymTest < Test::Unit::TestCase
  sub_test_case("#to_groonga") do
    def to_groonga(term, weight=nil)
      GroongaSynonym::Synonym.new(term, weight).to_groonga
    end

    test("normal") do
      assert_equal("Groonga", to_groonga("Groonga"))
    end

    test("OR") do
      assert_equal("\"OR\"", to_groonga("OR"))
    end

    test("\"") do
      assert_equal("\\\"", to_groonga("\""))
    end

    test("(") do
      assert_equal("\\(", to_groonga("("))
    end

    test(")") do
      assert_equal("\\)", to_groonga(")"))
    end

    test("\\") do
      assert_equal("\\\\", to_groonga("\\"))
    end

    test("*") do
      assert_equal("\\*", to_groonga("*"))
    end

    test(":") do
      assert_equal("\\:", to_groonga(":"))
    end

    test("+") do
      assert_equal("\\+", to_groonga("+"))
    end

    test("-") do
      assert_equal("\\-", to_groonga("-"))
    end

    test("space") do
      assert_equal("\"ice cream\"", to_groonga("ice cream"))
    end

    test("weight") do
      assert_equal(">-0.2Groonga", to_groonga("Groonga", 0.8))
    end
  end
end
