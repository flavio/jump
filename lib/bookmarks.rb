#!/usr/bin/env ruby

# Jump, a bookmarking system for the bash shell.
# Copyright (c) 2010 Giuseppe Capizzi
# mailto: g.capizzi@gmail.com
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

require 'rubygems'
require 'yaml'
require 'terminal-table/import'

class Bookmarks
  BOOKMARKS_PATH = File.expand_path "~/.jumprc"

  def initialize
    # Loads the bookmarks list from the bookmarks file.
    begin
      @bookmarks = YAML::load_file(BOOKMARKS_PATH)
    rescue Errno::ENOENT
      @bookmarks = {}
    rescue
      raise "Can't save configuration file"
    end
  end

  # Checks if +bookmark+ name is valid
  def self.is_valid_name? bookmark
    return (bookmark =~/\A\W/).nil?
  end

  # Saves the bookmarks list in the bookmarks file.
  def save
    begin
      File.open(BOOKMARKS_PATH, 'w') do |file|
        file << YAML::dump(@bookmarks)
      end
    rescue
      raise "Can't save configuration file"
    end
  end

  # Adds +bookmark+ pointing to +path+
  def add path, bookmark
    @bookmarks[bookmark] = path
  end

  # Deletes +bookmark+
  def del bookmark
    if @bookmarks.has_key? bookmark
      @bookmarks.delete bookmark
    else
      puts "'#{bookmark}' is an unknown bookmark"
    end
  end

  # Prints the bookmarks list.
  def to_s
    if @bookmarks.empty?
      "No bookmarks saved"
    else
      bookmarks_table = table do |t|
        t.headings = "Bookmark", "Path"
        @bookmarks.each do |bookmark, path|
          t << [bookmark, path]
        end
      end
      bookmarks_table.to_s
    end
  end

  # Expands paths that could start with a bookmark (e.g. [bookmark]/sub/path)
  def expand_path(path_with_bookmark)
    if path_with_bookmark.index("/").nil?
      # the path is just a bookmark
      return @bookmarks[path_with_bookmark]
    elsif path_with_bookmark.index("/") == 0
      # the path is an absolute path (no bookmark, e.g. /absolute/path)
      return path_with_bookmark
    else
      # the path is composed of a bookmark and a subpath
      name, path = path_with_bookmark.split("/")
      return @bookmarks[name] + "/" + path;
    end
  end
end
