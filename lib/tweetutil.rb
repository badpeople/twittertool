module Tweetutil
  include DateUtils
  def tweet(user, message)
    user.twitter.post('/statuses/update.json','status'=>message)
  end

  def retweet(user, tweet_id)
    puts "retweeting #{tweet_id}"
    user.twitter.post("/statuses/retweet/#{tweet_id}.json")
  end

  def retweet_for_user(user)
    # find something to retweet, go randomnly over the retweets in the db, retweet it.  if there isnt one in there that you havent retweeted then return nil

    # all retweetables

    promotions = Promotion.find_all_by_active(true,:order=>"created_at DESC")

    _tweet = nil

    promotions.each do |retweet|
      # see if the user has already retweeted this one
      if is_retweet?(retweet)
        retweets_found = Tweet.find(:first,:conditions=>["user_id = ? AND promotion_id = ?",user.id,retweet.id])
        if retweets_found.nil?
          begin
            result = retweet(user, retweet.status_id)
            #retweet was successful, save it
            _tweet = Tweet.new(:promotion=>retweet, :tweet_id=>result['id'],:deleted=>false)
            _tweet.user = user
            _tweet.save
            break
          rescue => e
            put_error e
          end

        end
      end
    end

    _tweet
  end

  def tweet_or_retweet(user)
    # find a rewtweet first
    _tweet = retweet_for_user(user)

    if _tweet.nil?
      _tweet = regular_tweet(user)
    end

    _tweet

  end

  def regular_tweet(user)
    # we didnt end up retweeting anything.  find a message that we have yet to retweet.
    promotions = Promotion.find_all_by_active(true, :order=>"created_at DESC")

    _tweet = nil

    promotions.each do |promotion|
      # see if the user has already retweeted this one
      if !is_retweet?(promotion)
        promotions_found = Tweet.find(:first, :conditions=>["user_id = ? AND promotion_id = ?", user.id, promotion.id])
        if promotions_found.nil?
          begin
            result = tweet(user, promotion.text)
            #retweet was successful, save it
            _tweet = Tweet.new(:promotion=>promotion,:tweet_id=>result['id'], :deleted=>false)
            _tweet.user = user
            _tweet.save
            break
          rescue => e
            put_error e
          end

        end
      end
    end

    _tweet
  end


  def delete_tweet(non_deleted_tweet, user)

    begin
      return user.twitter.post("/statuses/destroy/#{non_deleted_tweet.tweet_id}.json")
    rescue => e
      return nil
    end

  end

  def default_tweet(user)
    # check to make sure the old tweet isnt still there
    # find all defaulted ones, remove them all
    non_deleted_tweets = non_deleted_tweets(user, 0, false)

    non_deleted_tweets.each do |non_deleted_tweet|
      puts "found this non-deleted default tweet #{non_deleted_tweet.to_yaml}"
      delete_tweet(non_deleted_tweet, user)
    end

    # now get the default message and tweeet that shit
    default_tweet = APP_CONFIG[:default_tweet]
    if default_tweet.nil? || default_tweet.size < 5
      raise "default tweet was null or length < 5"
    end
    tweet(user, default_tweet)

  end

  def non_deleted_tweets(user, days_ago, has_promotion)
    # get user timeline
    user_timeline = user.twitter.get("/statuses/user_timeline.json")

    non_deleted_tweets = []

    # for each status, if the id mathes something we added, add to list
    created_at = add_hours(add_days(Time.now, -1 * days_ago),4)
    user_tweets = Tweet.find_all_by_deleted(false,
                                            :conditions=>["user_id = ? AND created_at < ? ",user.id, created_at])
    user_timeline.each do |tweeted|
      user_tweets.each do |user_tweet|
        if user_tweet.tweet_id == tweeted['id'] && has_promotion == (user_tweet.promotion.nil?)
          non_deleted_tweets << user_tweet
          break
        end
      end
    end

    non_deleted_tweets
  end
end