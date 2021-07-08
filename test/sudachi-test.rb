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

class SudachiTest < Test::Unit::TestCase
  def setup
    @source = GroongaSynonym::Sudachi.new
  end

  def sample_lines(string)
    lines = string.lines
    (lines[0..4] + ["...\n"] + lines[-5..-1]).join
  end

  def test_groonga
    output = StringIO.new
    generator = GroongaSynonym::GroongaGenerator.new(@source.take(31),
                                                     "_key",
                                                     "synonyms",
                                                     output: output)
    generator.generate
    assert_equal(<<-JSON, sample_lines(output.string))
[
["_key","synonyms"],
["曖昧",["曖昧",">-0.2あいまい",">-0.4不明確",">-0.4あやふや",">-0.4不明瞭",">-0.4不確か"]],
["あいまい",[">-0.2曖昧","あいまい",">-0.4不明確",">-0.4あやふや",">-0.4不明瞭",">-0.4不確か"]],
["不明確",[">-0.4曖昧",">-0.4あいまい","不明確",">-0.4あやふや",">-0.4不明瞭",">-0.4不確か"]],
...
["レジュメ",[">-0.4粗筋",">-0.4あらすじ",">-0.4荒筋",">-0.4概略",">-0.4大略",">-0.4概要",">-0.4大要",">-0.4要約",">-0.4要旨",">-0.4梗概",">-0.4サマリー",">-0.4サマリ",">-0.4summary","レジュメ",">-0.2レジメ",">-0.2resume",">-0.2résumé",">-0.4概ね",">-0.4あらまし",">-0.4アブストラクト",">-0.4abstract",">-0.4シノプシス",">-0.4synopsis",">-0.4アウトライン",">-0.4outline"]],
["レジメ",[">-0.4粗筋",">-0.4あらすじ",">-0.4荒筋",">-0.4概略",">-0.4大略",">-0.4概要",">-0.4大要",">-0.4要約",">-0.4要旨",">-0.4梗概",">-0.4サマリー",">-0.4サマリ",">-0.4summary",">-0.2レジュメ","レジメ",">-0.2resume",">-0.2résumé",">-0.4概ね",">-0.4あらまし",">-0.4アブストラクト",">-0.4abstract",">-0.4シノプシス",">-0.4synopsis",">-0.4アウトライン",">-0.4outline"]],
["résumé",[">-0.4粗筋",">-0.4あらすじ",">-0.4荒筋",">-0.4概略",">-0.4大略",">-0.4概要",">-0.4大要",">-0.4要約",">-0.4要旨",">-0.4梗概",">-0.4サマリー",">-0.4サマリ",">-0.4summary",">-0.2レジュメ",">-0.2レジメ",">-0.2resume","résumé",">-0.4概ね",">-0.4あらまし",">-0.4アブストラクト",">-0.4abstract",">-0.4シノプシス",">-0.4synopsis",">-0.4アウトライン",">-0.4outline"]],
["シノプシス",[">-0.4粗筋",">-0.4あらすじ",">-0.4荒筋",">-0.4概略",">-0.4大略",">-0.4概要",">-0.4大要",">-0.4要約",">-0.4要旨",">-0.4梗概",">-0.4サマリー",">-0.4サマリ",">-0.4summary",">-0.4レジュメ",">-0.4レジメ",">-0.4resume",">-0.4résumé",">-0.4概ね",">-0.4あらまし",">-0.4アブストラクト",">-0.4abstract","シノプシス",">-0.2synopsis",">-0.4アウトライン",">-0.4outline"]]
]
    JSON
  end

  def test_pgroonga
    output = StringIO.new
    generator = GroongaSynonym::PGroongaGenerator.new(@source.take(31),
                                                      "thesaurus",
                                                      "term",
                                                      "synonyms",
                                                      output: output)
    generator.generate
    assert_equal(<<-SQL, sample_lines(output.string))
INSERT INTO thesaurus (term, synonyms) VALUES
  ('曖昧', ARRAY['曖昧', '>-0.2あいまい', '>-0.4不明確', '>-0.4あやふや', '>-0.4不明瞭', '>-0.4不確か']),
  ('あいまい', ARRAY['>-0.2曖昧', 'あいまい', '>-0.4不明確', '>-0.4あやふや', '>-0.4不明瞭', '>-0.4不確か']),
  ('不明確', ARRAY['>-0.4曖昧', '>-0.4あいまい', '不明確', '>-0.4あやふや', '>-0.4不明瞭', '>-0.4不確か']),
  ('あやふや', ARRAY['>-0.4曖昧', '>-0.4あいまい', '>-0.4不明確', 'あやふや', '>-0.4不明瞭', '>-0.4不確か']),
...
  ('summary', ARRAY['>-0.4粗筋', '>-0.4あらすじ', '>-0.4荒筋', '>-0.4概略', '>-0.4大略', '>-0.4概要', '>-0.4大要', '>-0.4要約', '>-0.4要旨', '>-0.4梗概', '>-0.2サマリー', '>-0.2サマリ', 'summary', '>-0.4レジュメ', '>-0.4レジメ', '>-0.4resume', '>-0.4résumé', '>-0.4概ね', '>-0.4あらまし', '>-0.4アブストラクト', '>-0.4abstract', '>-0.4シノプシス', '>-0.4synopsis', '>-0.4アウトライン', '>-0.4outline']),
  ('レジュメ', ARRAY['>-0.4粗筋', '>-0.4あらすじ', '>-0.4荒筋', '>-0.4概略', '>-0.4大略', '>-0.4概要', '>-0.4大要', '>-0.4要約', '>-0.4要旨', '>-0.4梗概', '>-0.4サマリー', '>-0.4サマリ', '>-0.4summary', 'レジュメ', '>-0.2レジメ', '>-0.2resume', '>-0.2résumé', '>-0.4概ね', '>-0.4あらまし', '>-0.4アブストラクト', '>-0.4abstract', '>-0.4シノプシス', '>-0.4synopsis', '>-0.4アウトライン', '>-0.4outline']),
  ('レジメ', ARRAY['>-0.4粗筋', '>-0.4あらすじ', '>-0.4荒筋', '>-0.4概略', '>-0.4大略', '>-0.4概要', '>-0.4大要', '>-0.4要約', '>-0.4要旨', '>-0.4梗概', '>-0.4サマリー', '>-0.4サマリ', '>-0.4summary', '>-0.2レジュメ', 'レジメ', '>-0.2resume', '>-0.2résumé', '>-0.4概ね', '>-0.4あらまし', '>-0.4アブストラクト', '>-0.4abstract', '>-0.4シノプシス', '>-0.4synopsis', '>-0.4アウトライン', '>-0.4outline']),
  ('résumé', ARRAY['>-0.4粗筋', '>-0.4あらすじ', '>-0.4荒筋', '>-0.4概略', '>-0.4大略', '>-0.4概要', '>-0.4大要', '>-0.4要約', '>-0.4要旨', '>-0.4梗概', '>-0.4サマリー', '>-0.4サマリ', '>-0.4summary', '>-0.2レジュメ', '>-0.2レジメ', '>-0.2resume', 'résumé', '>-0.4概ね', '>-0.4あらまし', '>-0.4アブストラクト', '>-0.4abstract', '>-0.4シノプシス', '>-0.4synopsis', '>-0.4アウトライン', '>-0.4outline']),
  ('シノプシス', ARRAY['>-0.4粗筋', '>-0.4あらすじ', '>-0.4荒筋', '>-0.4概略', '>-0.4大略', '>-0.4概要', '>-0.4大要', '>-0.4要約', '>-0.4要旨', '>-0.4梗概', '>-0.4サマリー', '>-0.4サマリ', '>-0.4summary', '>-0.4レジュメ', '>-0.4レジメ', '>-0.4resume', '>-0.4résumé', '>-0.4概ね', '>-0.4あらまし', '>-0.4アブストラクト', '>-0.4abstract', 'シノプシス', '>-0.2synopsis', '>-0.4アウトライン', '>-0.4outline']);
    SQL
  end
end
