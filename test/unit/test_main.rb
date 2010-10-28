require 'test_helper'


class MainTester < Test::Unit::TestCase
  include Main
  include Util

  def test_do_follow
#    User.all.each do |user|
      do_follows_for_user User.find_by_login('toosoondude')

#    end
  end

  def test_should_run
    user = User.find_by_login('paultweettest')
    assert should_do_follows(user)

    user = User.find_by_login('toosoondude')

    assert(!should_do_follows(user))

  end

  def test_do_unfollows
    user = User.find_by_login('toosoondude')
    do_unfollows(user)

  end

  def test_unfollow_all_nonfollowers
    user = User.find_by_login('toosoondude')

    # get all followers

    followers = get_followers(user)
    puts "number of followers: #{followers.size}"

    # get all friends

    friends = user.twitter.get("/friends/ids.json",'cursor'=>-1.to_s)
    puts "number of friends: #{friends.size}"


    to_unfollow = remove_all(friends, followers)

    puts "to unfollow size: #{to_unfollow.size}"

    unfollow_from_list(to_unfollow, user)



  end

  def test_do_deletes
    user = User.find_by_login('paultweettest2')
    do_deletes(user)

  end

  def test_get_potential_follows_from_mimic
    user = User.find_by_login('paultweettest2')
    list_of_follows = get_potential_follows_from_mimic(user)
    puts "size: #{list_of_follows.size}"
    puts list_of_follows.to_yaml

  end


end