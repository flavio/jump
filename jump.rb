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

BOOKMARKS_PATH = File.expand_path "~/.jumprc"

def exit_with_error(message)
  puts "*** ERROR: " + message
  exit 1
end

def print_usage
  puts "jump to [bookmark]    Jumps to the directory pointed by [bookmark]"
  puts "jump add [bookmark]   Saves the current directory in [bookmark]"
  puts "jump del [bookmark]   Deletes [bookmark]"
  puts "jump list             Prints the list of all saved bookmarks"
  puts "jump help             Displays this message"
end

# Saves the bookmarks list in the bookmarks file.
def save_bookmarks(bookmarks, bookmarks_path)
  begin
    file = File.open(bookmarks_path, 'w') do |f|
      bookmarks.each do |name, path|
        f.puts name + "\t" + path
      end
    end
  rescue
    exit_with_error "can't save configuration file"
  end
end

# Loads the bookmarks list from the bookmarks file.
def load_bookmarks(bookmarks_path)
  bookmarks = {}
  
  begin
    file = File.open(bookmarks_path, 'r') do |f|
      while line = f.gets  
        name, path = line.split("\t")
        bookmarks[name] = path
      end
    end
    
    return bookmarks
  rescue
    exit_with_error "can't load configuration file"
  end
end

# Prints the bookmarks list.
def print_bookmarks(bookmarks)
  name_col_title = "Bookmark"
  path_col_title = "Path"
  name_col_size = 20
  row_length = 75

  if !bookmarks.empty?
    print name_col_title
    (name_col_size - name_col_title.length).times do print " " end
    puts path_col_title
    puts "-" * row_length

    bookmarks.each do |name, path|
      print name
      (name_col_size - name.length).times do
        print " "
      end
      puts " " + path
    end
  else
    puts "No bookmarks saved"
  end
end

# Expands paths that could start with a bookmark (e.g. [bookmark]/sub/path)
def expand_path(path_with_bookmark, bookmarks)
  if path_with_bookmark.index("/").nil?
    # the path is just a bookmark
    return bookmarks[path_with_bookmark]
  elsif path_with_bookmark.index("/") == 0
    # the path is an absolute path (no bookmark, e.g. /absolute/path)
    return path_with_bookmark
  else
    # the path is composed of a bookmark and a subpath
    name, path = path_with_bookmark.split("/")
    return bookmarks[name] + "/" + path;
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.size > 0
    if ARGV[0] == "list"
      print_bookmarks(load_bookmarks(BOOKMARKS_PATH))
      # p load_bookmarks(BOOKMARKS_PATH).to_s
    elsif ARGV[0] == "help"
      print_usage
    elsif ARGV[0] == "to" && ARGV.size > 1
      path = expand_path(ARGV[1], load_bookmarks(BOOKMARKS_PATH));
      print path.chomp if !path.nil?
    elsif ARGV[0] == "add" && ARGV.size > 1
      bookmarks = load_bookmarks(BOOKMARKS_PATH)
      bookmarks[ARGV[1]] = Dir.pwd
      save_bookmarks(bookmarks, BOOKMARKS_PATH)
    elsif ARGV[0] == "del" && ARGV.size > 1
      bookmarks = load_bookmarks(BOOKMARKS_PATH)
      bookmarks.delete ARGV[1]
      save_bookmarks(bookmarks, BOOKMARKS_PATH)
    else
      print_usage
      exit 1
    end
  else # wrong number of arguments
    print_usage
    exit 1;
  end
end
