require 'test_helper'
require 'main'


class TweetTester < Test::Unit::TestCase
  include Main
#  include Util
#  include Tweetutil

  def test_tweet
    user = User.find_by_login('paultweettest2')
    result = tweet(user,"hello world & your mother,? #{Time.now.to_i.to_s}")
    id = result['id']
    assert(!id.nil?)
    assert(!result.nil?)
  end

  def test_retweet
    user = User.find_by_login('paultweettest2')
    retweet_ids = APP_CONFIG['tweets'].split(",")
    i = rand(retweet_ids.size)
    result = retweet(user,retweet_ids[i])
    id = result['id']
    assert(!id.nil?)
    assert(!result.nil?)


  end

  def test_do_retweet
    user = User.find_by_login('paultweettest2')
    _tweet = retweet_for_user(user)



  end

  def test_do_tweet
    user = User.find_by_login('toosoondude')
    do_tweet(user)

  end

end
