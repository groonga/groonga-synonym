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

require "datasets"

require_relative "synonym"

module GroongaSynonym
  class Sudachi
    include Enumerable

    def initialize
      @dataset = Datasets::SudachiSynonymDictionary.new
    end

    def each
      return to_enum(__method__) unless block_given?

      groups = {}
      group_id = nil
      group = nil
      emit_synonyms = lambda do
        return if group.nil?
        target_synonyms = group.reject do |synonym|
          synonym.expansion_type == :never
        end
        return if target_synonyms.size <= 1
        target_synonyms.each_with_index do |typical, i|
          next unless typical.expansion_type == :always
          term = typical.notation
          synonyms = []
          target_synonyms.each_with_index do |synonym, j|
            if i == j
              weight = nil
            elsif synonym.lexeme_id == typical.lexeme_id
              weight = 0.8
            else
              weight = 0.6
            end
            synonyms << Synonym.new(synonym.notation, weight)
          end
          # e.g.: 働き手
          if groups.key?(term)
            groups[term] |= synonyms
          else
            groups[term] = synonyms
          end
        end
      end
      @dataset.each do |synonym|
        if synonym.group_id != group_id
          emit_synonyms.call
          group_id = synonym.group_id
          group = [synonym]
        else
          group << synonym
        end
      end
      emit_synonyms.call
      groups.each do |term, synonyms|
        typical_synonym = nil
        other_synonyms = []
        synonyms.each do |synonym|
          if synonym.weight.nil?
            typical_synonym = synonym
          else
            other_synonyms << synonym
          end
        end
        others_sub_synonyms = []
        sub_synonyms = []
        super_synonyms = []
        other_synonyms.each do |synonym|
          is_sub_synonym = other_synonyms.any? do |other_synonym|
            other_synonym != synonym and
              synonym.term.include?(other_synonym.term)
          end
          if is_sub_synonym
            others_sub_synonyms << synonym
          elsif term.include?(synonym.term)
            sub_synonyms << synonym
          elsif synonym.term.include?(term)
            super_synonyms << synonym
          end
        end
        synonyms -= others_sub_synonyms
        synonyms -= super_synonyms
        unless sub_synonyms.empty?
          sorted_sub_synonyms = sub_synonyms.sort_by do |synonym|
            synonym.term.size
          end
          typical_sub_synonym, *other_sub_synonyms = sorted_sub_synonyms
          synonyms -= other_sub_synonyms
          synonyms.delete(typical_synonym)
          synonyms << Synonym.new(typical_synonym.term,
                                  (1.0 - typical_sub_synonym.weight).round(2))
        end
        yield(term, synonyms)
      end
    end
  end
end
