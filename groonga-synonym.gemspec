# -*- ruby -*-
#
# Copyright (C) 2021-2023  Sutou Kouhei <kou@clear-code.com>
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

clean_white_space = lambda do |entry|
  entry.gsub(/(\A\n+|\n+\z)/, '') + "\n"
end

require_relative "lib/groonga-synonym/version"

Gem::Specification.new do |spec|
  spec.name = "groonga-synonym"
  spec.version = GroongaSynonym::VERSION
  spec.homepage = "https://github.com/groonga/groonga-synonym"
  spec.authors = ["Sutou Kouhei"]
  spec.email = ["kou@clear-code.com"]

  readme = File.read("README.md")
  readme.force_encoding("UTF-8")
  entries = readme.split(/^\#\#\s(.*)$/)
  clean_white_space.call(entries[entries.index("Description") + 1])
  description = clean_white_space.call(entries[entries.index("Description") + 1])
  spec.summary, spec.description, = description.split(/\n\n+/, 3)
  spec.license = "GPL-3.0+"
  spec.files = [
    "README.md",
    "LICENSE.txt",
    "Rakefile",
    "Gemfile",
    "#{spec.name}.gemspec",
  ]
  spec.files += Dir.glob("lib/**/*.rb")
  Dir.chdir("bin") do
    spec.executables = Dir.glob("*")
  end

  spec.add_runtime_dependency("red-datasets", ">= 0.1.6")
end
