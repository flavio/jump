require "test_helper"
require 'bookmarks'
require 'fileutils'

class BookmarksTest < Test::Unit::TestCase
  def setup
    @test_bookmarks = {"foo" => "/tmp/foo",
                  "bar" => "/tm[/bar"}
    FakeFS do
      File.open(Bookmarks::BOOKMARKS_PATH, 'w') do |file|
        file << YAML::dump(@test_bookmarks)
      end

      @bookmarks = Bookmarks.new
    end

  end

  def test_expand_path
    @test_bookmarks.each do |bookmark, expected_path|
      current_path = @bookmarks.expand_path bookmark
      assert_equal expected_path, current_path
    end
    #TODO: cover other cases
  end

  def test_add
    # should add a new bookmark
    bookmark = "flavio_home"
    path = "/home/flavio"
    @bookmarks.add(path, bookmark)
    assert_equal path, @bookmarks.expand_path(bookmark)

    #should update a bookmark
    new_path = "/tmp"
    @bookmarks.add(new_path, bookmark)
    assert_equal new_path, @bookmarks.expand_path(bookmark)
  end

  def test_to_s
    output = <<EOF
+----------+----------+
| Bookmark | Path     |
+----------+----------+
| foo      | /tmp/foo |
| bar      | /tm[/bar |
+----------+----------+
EOF
    assert_equal output, @bookmarks.to_s
  end

  def test_save
    bookmark = "flavio_home"
    path = "/home/flavio"
    @bookmarks.add(path, bookmark)

    expected_bookmarks = @test_bookmarks.dup
    expected_bookmarks[bookmark] = path

    FakeFS do
      @bookmarks.save

      assert File.exists?(Bookmarks::BOOKMARKS_PATH)
      contents = YAML::load_file Bookmarks::BOOKMARKS_PATH
      assert_equal expected_bookmarks, contents
    end
  end

  def test_bash_completion
    FakeFS do
      FileUtils.rm "~/.jumprc"
      bookmarks = Bookmarks.new
      bookmarks.add("/home/flavio/templates", "templates")
      bookmarks.add("/home/flavio/templates", "test")
      bookmarks.add("/home/flavio/test/rails_app", "rails")

      FileUtils.mkdir_p "/home/flavio/templates/foo/bar"
      FileUtils.mkdir_p "/home/flavio/test/rails_app/log"
      FileUtils.mkdir_p "/home/flavio/test/rails_app/locale"
      FileUtils.mkdir_p "/home/flavio/test/rails_app/app/model"
      FileUtils.touch "/home/flavio/test/rails_app/local_file"

      # should return all the bookmarks
      assert_equal "rails templates test", bookmarks.bash_completion(nil)
      assert_equal "rails templates test", bookmarks.bash_completion('')

      # no matches => should return the same text
      assert_equal "foo", bookmarks.bash_completion("foo")

      # should complete the text
      assert_equal "templates test", bookmarks.bash_completion("te")
      assert_equal "rails", bookmarks.bash_completion("ra")

      # /home/flavio/templates/bar doesn't exist => should return the same text
      assert_equal "templates/bar", bookmarks.bash_completion("templates/bar")

      # should expand the path
      assert_equal  "rails/ rails/locale rails/log",
                    bookmarks.bash_completion("rails/lo")

      # should expand the path
      assert_equal  "rails/ rails/app rails/locale rails/log",
                    bookmarks.bash_completion("rails/")
    end
  end

end