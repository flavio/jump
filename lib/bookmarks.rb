# This file is part of the jump project
#
# Copyright (C) 2010 Flavio Castelli <flavio@castelli.name>
# Copyright (C) 2010 Giuseppe Capizzi <gcapizzi@gmail.com>
#
# kaveau is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# kaveau is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Keep; if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Steet, Fifth Floor, Boston, MA 02110-1301, USA.

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
        t.headings = "Bookmark", "Path"
        @bookmarks.keys.sort.each do |bookmark|
          t << [bookmark, @bookmarks[bookmark]]
        end
      end
      bookmarks_table.to_s
    end
  end

  def bash_completion text
    if text.nil? || text.empty?
      # nothing is provided -> return all the bookmarks
      @bookmarks.keys.sort.join(' ')
    elsif text.include? '/'
      if text.index('/') == 0
        # this is an absolute path (eg: /foo)
        return text
      end

      # [bookmark]/path
      bookmark = text[0, text.index('/')]
      path = text[text.index('/')+1, text.size]
      if @bookmarks.has_key?(bookmark)
        # this is a known bookmark
        entries = []
        Dir.foreach(@bookmarks[bookmark]) do |filename|
          next if !path.empty? && (filename =~ /\A#{path}.*/).nil?
          if File.directory?(File.join(@bookmarks[bookmark], filename))
            next if filename == "." || filename == ".."
            entries << File.join(bookmark, filename)
          end
        end

        if entries.empty?
          text
        else
          entries << "#{bookmark}/"
          entries.sort.join(' ')
        end
      else
        # this is an unknown bookmark
        text
      end
    else
      # text could match one of the bookmarks
      matches = @bookmarks.keys.find_all { |b| b =~ /\A#{text}/ }
      if matches.empty?
        text
      else
        matches.sort.join(' ')
      end
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
      name = path_with_bookmark[0, path_with_bookmark.index('/')]
      path = path_with_bookmark[path_with_bookmark.index('/')+1,
                                path_with_bookmark.size]
      return @bookmarks[name] + "/" + path;
    end
  end
end
