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

class CommandLineGeneratorTest < Test::Unit::TestCase
  def sample_output(output)
    lines = output.lines
    (lines[0..2] + ["...\n"] + lines[-3..-1]).join
  end

  def run_command(*args)
    output = StringIO.new
    generator = GroongaSynonym::CommandLine::Generator.new(output)
    success = generator.run(args)
    [success, sample_output(output.string)]
  end

  test("default") do
    assert_equal([true, <<-OUTPUT], run_command)
[
["_key","synonyms"],
["曖昧",["曖昧",">-0.2あいまい",">-0.4不明確",">-0.4あやふや",">-0.4不明瞭",">-0.4不確か"]],
...
["gigabyte",[">-0.2ギガバイト","gigabyte",">-0.2GB"]],
["GB",[">-0.2ギガバイト",">-0.2gigabyte","GB"]]
]
    OUTPUT
  end

  sub_test_case("--source") do
    test("sudachi") do
      assert_equal([true, <<-OUTPUT], run_command("--source", "sudachi"))
[
["_key","synonyms"],
["曖昧",["曖昧",">-0.2あいまい",">-0.4不明確",">-0.4あやふや",">-0.4不明瞭",">-0.4不確か"]],
...
["gigabyte",[">-0.2ギガバイト","gigabyte",">-0.2GB"]],
["GB",[">-0.2ギガバイト",">-0.2gigabyte","GB"]]
]
      OUTPUT
    end
  end

  sub_test_case("--format=groonga") do
    test("--term-column") do
      args = [
        "--format", "groonga",
        "--term-column", "term",
      ]
      assert_equal([true, <<-OUTPUT], run_command(*args))
[
["term","synonyms"],
["曖昧",["曖昧",">-0.2あいまい",">-0.4不明確",">-0.4あやふや",">-0.4不明瞭",">-0.4不確か"]],
...
["gigabyte",[">-0.2ギガバイト","gigabyte",">-0.2GB"]],
["GB",[">-0.2ギガバイト",">-0.2gigabyte","GB"]]
]
      OUTPUT
    end

    test("--synonyms-column") do
      args = [
        "--format", "groonga",
        "--synonyms-column", "other_terms",
      ]
      assert_equal([true, <<-OUTPUT], run_command(*args))
[
["_key","other_terms"],
["曖昧",["曖昧",">-0.2あいまい",">-0.4不明確",">-0.4あやふや",">-0.4不明瞭",">-0.4不確か"]],
...
["gigabyte",[">-0.2ギガバイト","gigabyte",">-0.2GB"]],
["GB",[">-0.2ギガバイト",">-0.2gigabyte","GB"]]
]
      OUTPUT
    end

    test("--no-synonyms-column-is-vector") do
      args = [
        "--format", "groonga",
        "--no-synonyms-column-is-vector",
      ]
      assert_equal([true, <<-OUTPUT], run_command(*args))
[
["_key","synonyms"],
["曖昧","(曖昧) OR (>-0.2あいまい) OR (>-0.4不明確) OR (>-0.4あやふや) OR (>-0.4不明瞭) OR (>-0.4不確か)"],
...
["gigabyte","(>-0.2ギガバイト) OR (gigabyte) OR (>-0.2GB)"],
["GB","(>-0.2ギガバイト) OR (>-0.2gigabyte) OR (GB)"]
]
      OUTPUT
    end
  end

  sub_test_case("--format=pgroonga") do
    test("--table") do
      args = [
        "--format", "pgroonga",
        "--table", "dictionary",
      ]
      assert_equal([true, <<-OUTPUT], run_command(*args))
INSERT INTO dictionary (term, synonyms) VALUES
  ('曖昧', ARRAY['曖昧', '>-0.2あいまい', '>-0.4不明確', '>-0.4あやふや', '>-0.4不明瞭', '>-0.4不確か']),
  ('あいまい', ARRAY['>-0.2曖昧', 'あいまい', '>-0.4不明確', '>-0.4あやふや', '>-0.4不明瞭', '>-0.4不確か']),
...
  ('ギガバイト', ARRAY['ギガバイト', '>-0.2gigabyte', '>-0.2GB']),
  ('gigabyte', ARRAY['>-0.2ギガバイト', 'gigabyte', '>-0.2GB']),
  ('GB', ARRAY['>-0.2ギガバイト', '>-0.2gigabyte', 'GB']);
      OUTPUT
    end

    test("--term-column") do
      args = [
        "--format", "pgroonga",
        "--term-column", "word",
      ]
      assert_equal([true, <<-OUTPUT], run_command(*args))
INSERT INTO thesaurus (word, synonyms) VALUES
  ('曖昧', ARRAY['曖昧', '>-0.2あいまい', '>-0.4不明確', '>-0.4あやふや', '>-0.4不明瞭', '>-0.4不確か']),
  ('あいまい', ARRAY['>-0.2曖昧', 'あいまい', '>-0.4不明確', '>-0.4あやふや', '>-0.4不明瞭', '>-0.4不確か']),
...
  ('ギガバイト', ARRAY['ギガバイト', '>-0.2gigabyte', '>-0.2GB']),
  ('gigabyte', ARRAY['>-0.2ギガバイト', 'gigabyte', '>-0.2GB']),
  ('GB', ARRAY['>-0.2ギガバイト', '>-0.2gigabyte', 'GB']);
      OUTPUT
    end

    test("--synonyms-column") do
      args = [
        "--format", "pgroonga",
        "--synonyms-column", "other_terms",
      ]
      assert_equal([true, <<-OUTPUT], run_command(*args))
INSERT INTO thesaurus (term, other_terms) VALUES
  ('曖昧', ARRAY['曖昧', '>-0.2あいまい', '>-0.4不明確', '>-0.4あやふや', '>-0.4不明瞭', '>-0.4不確か']),
  ('あいまい', ARRAY['>-0.2曖昧', 'あいまい', '>-0.4不明確', '>-0.4あやふや', '>-0.4不明瞭', '>-0.4不確か']),
...
  ('ギガバイト', ARRAY['ギガバイト', '>-0.2gigabyte', '>-0.2GB']),
  ('gigabyte', ARRAY['>-0.2ギガバイト', 'gigabyte', '>-0.2GB']),
  ('GB', ARRAY['>-0.2ギガバイト', '>-0.2gigabyte', 'GB']);
      OUTPUT
    end
  end
end
