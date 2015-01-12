# This file is part of the jump project
#
# Copyright (C) 2010 Flavio Castelli <flavio@castelli.name>
# Copyright (C) 2010 Giuseppe Capizzi <gcapizzi@gmail.com>
#
# jump is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# jump is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Keep; if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

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
      raise "Can't load configuration file"
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
      true
    else
      false
    end
  end

  # Prints the bookmarks list.
  def to_s
    if @bookmarks.empty?
      "No bookmarks saved"
    else
      bookmarks_table = table do |t|
        t.style = { :border_y => '', :border_i => '' }
        t.headings = "Bookmark", "Path"
        @bookmarks.keys.sort.each do |bookmark|
          t << [bookmark, simplify_path(@bookmarks[bookmark])]
        end
      end
      bookmarks_table.to_s
    end
  end

  def sorted_bookmarks()  sorted_list @bookmarks.keys  end
  def sorted_list(terms)  terms.sort.join ' '  end

  # Provide a list of completion options, starting with given prefix
  def complete prefix
    # Special cases:
    #   - nothing is provided: return all the bookmarks
    #   - absolute path: don't complete
    return sorted_bookmarks if prefix.nil? || prefix.empty?
    return prefix if prefix.start_with? File::SEPARATOR

    bookmark, path = prefix.split File::SEPARATOR, 2 # File.split only does path/basename

    completions = [  ]
    if path.nil?
      # still in 1st element, could match several bookmarks
      completions += @bookmarks.keys.find_all { |b| b.start_with? prefix }
    elsif @bookmarks.has_key?(bookmark)
      # bookmark known, complete further
      completions += Dir.chdir(@bookmarks[bookmark]) do
        Dir.glob(["#{path}*"]) \
          .select { |f| File.directory? f } \
          .collect { |f| File.join bookmark, f }
      end
    end
    completions.map! { |d| d + File::SEPARATOR }
    completions << prefix if completions.empty?
    sorted_list completions
  end

  # Simplifies given path by replacing the user's homedir with ~
  def simplify_path(path)
    path.gsub /^#{File.expand_path '~'}/, '~'
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
      name = path_with_bookmark[0, path_with_bookmark.index('/')]
      path = path_with_bookmark[path_with_bookmark.index('/')+1,
                                path_with_bookmark.size]
      return @bookmarks[name] + "/" + path;
    end
  end
end
