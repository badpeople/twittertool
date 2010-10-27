require 'test_helper'


class UtilTester < Test::Unit::TestCase
  include Util

  def test_get_followers
    user = User.find_by_login('paultweettest')

    followers = get_followers(user)
    puts followers

  end

  def test_unfollow_intersection
    followers = [10,11,12,13]
    friendings = []
    (0..11).each do |num|
      friendings << Friending.new(:follow_id=>num)
    end

    after_remove = remove_following_from_friendings(friendings,followers)
    assert(after_remove.size == 10)

  end

  def test_no_longer_following
    user = User.find_by_login('toosoondude')
    friendlings = Friending.find_all_by_user_id(user.id,:order=>"created_at")

    to_defriend = remove_no_longer_following(friendlings,user)
    assert !to_defriend.nil?



  end

  def test_retain_all
    list1 = (0..10)
    list2 = (5..15)
    list3 = retain_all(list1, list2)
    assert list3.size == 6
    assert list3.include?(5)
    assert list3.include?(10)
    assert !list3.include?(4)
  end

  def test_remove_all
    list1 = (0..10)
    list2 = (5..15)
    list3 = remove_all(list1, list2)
    assert list3.size == 5
    assert !list3.include?(5)
    assert !list3.include?(10)
    assert list3.include?(4)
  end

  def test_get_data_from_ids
    user = User.find_by_login('toosoondude')
    ids = [122083616, 192785447]
    ids = [192785447,192048280]
#    data = ids_to_full_data(user,['toosoondude'] )
    data = ids_to_full_data(user,ids)
#    data = ids_to_full_data(user,[122083616] )


    puts data.to_yaml
    assert !data.nil?

  end

  def test_legit_user
    data = {'profile_image_url'=>'http://s.twimg.com/a/1287010001/images/default_profile_0_bigger.png','followers_count'=>20}
    assert !legit_user?(data)
#    data = {'profile_image_url'=>'the/sweet_one','followers_count'=>0}
#    assert !legit_user?(data)
#    data = {'profile_image_url'=>'the/sweet_one','followers_count'=>10}
#    assert legit_user?(data)



  end

end