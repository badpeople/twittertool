require 'test_helper'


class MainTester < Test::Unit::TestCase
  include Main

  def test_do_follow
    User.all.each do |user|
      do_follows_for_user user

    end
  end
end