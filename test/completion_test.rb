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

require "test_helper"
require 'bookmarks'
require 'fileutils'

class BookmarkCompletionTest < Test::Unit::TestCase
  
  def setup
    FakeFS do
      @bookmarks = Bookmarks.new
      @bookmarks.add("/home/flavio/templates", "templates")
      @bookmarks.add("/home/flavio/templates", "test")
      @bookmarks.add("/home/flavio/test/rails_app", "rails")
      @bookmarks.add("/home/flavio/test/another_rails_app", "rails2")

      FileUtils.mkdir_p "/home/flavio/templates/foo/bar"
      FileUtils.mkdir_p "/home/flavio/templates/baz"
      FileUtils.mkdir_p "/home/flavio/test/rails_app/log"
      FileUtils.mkdir_p "/home/flavio/test/rails_app/locale"
      FileUtils.mkdir_p "/home/flavio/test/rails_app/app/model"
      FileUtils.touch   "/home/flavio/test/rails_app/local_file"
      FileUtils.mkdir_p "/home/flavio/test/another_rails_app"
    end
  end

  def test_absolute_path
    FakeFS do
      assert_equal "/rails", @bookmarks.complete('/rails')
    end
  end

  def test_empty_completes_to_all
    FakeFS do
      assert_equal "rails rails2 templates test", @bookmarks.complete(nil)
      assert_equal "rails rails2 templates test", @bookmarks.complete('')
    end
  end

  def test_no_matches # => should return the same text
    FakeFS do
      assert_equal "foo", @bookmarks.complete("foo")
    end
  end

  def test_no_matches_with_suffix
    FakeFS do
      assert_equal "foo/meh/zzz", @bookmarks.complete("foo/meh/zzz")
    end
  end

  def test_prefix
    FakeFS do
      assert_equal "templates/ test/", @bookmarks.complete("te")
      assert_equal "rails/ rails2/", @bookmarks.complete("ra")
    end
  end

  def test_nonexisting_suffix
    FakeFS do
      # /home/flavio/templates/bar doesn't exist => should return the same text
      assert_equal "templates/bar", @bookmarks.complete("templates/bar")
      assert_equal "templates/bar/1/2",
                   @bookmarks.complete("templates/bar/1/2")
    end
  end

  def test_completes_children_after_separator
    FakeFS do
      assert_equal "rails/app/ rails/locale/ rails/log/",
                   @bookmarks.complete("rails/")
    end
  end

  def test_completes_suffix
    FakeFS do
      assert_equal "rails/locale/ rails/log/",
                   @bookmarks.complete("rails/lo")
    end
  end

  def test_completes_suffix_path
    FakeFS do
      assert_equal "rails/app/model/",
                   @bookmarks.complete("rails/app/")
    end
  end

end
