module Tweetutil
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
            _tweet = Tweet.new(:promotion=>retweet, :user=>user,:tweet_id=>result['id'],:deleted=>false)
            _tweet.save
          rescue => e
            put_error e
          end

        end
      end
    end

    _tweet
  end

  def tweet_or_retweet(user)
    _tweet = retweet_for_user(user)

  end
end