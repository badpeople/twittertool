require 'rand'
require 'json'
require 'tweetutil'
require 'util'

module Main

  include Util
  include DateUtils
  include Tweetutil

  def follow_from_list(user, twitter_users, max=10)
    puts "for user #{user.login}, attempting to follow #{twitter_users.to_yaml}"


    just_friended = []

    #follow each one of them
    twitter_users.each do |twitter_user|
      begin
        # check if we have followed too many
        if just_friended.size >= max
          break
        end

        follow_result = user.twitter.post('/friendships/create.json','user_id'=>twitter_user)
        # execute the follow
        just_friended << twitter_user
        puts "just followed #{twitter_user}"

        #save as a friending
        friending = Friending.new(:follow_id=>twitter_user)
        friending.user = user
        if friending.save
          "puts just saved friendling #{friending.to_yaml}"
        end
      rescue => e
        puts "error trying to friend #{twitter_user}"
        puts e.message
#        puts e.backtrace
      end

    end

    just_friended
  end



  def get_users_to_follow(user)

    users_to_follow = []
    # get all the users the user is currently following
    friends = get_friends(user)

    # add all the users in the db
    User.all_enabled_random.each do |db_user|
      db_user_twitter_id = db_user.twitter_id.to_i
      if !friends.include?(db_user_twitter_id) &&  !already_attempted_friending?(user, db_user_twitter_id) && db_user_twitter_id != user.twitter_id.to_i
        users_to_follow << db_user_twitter_id
      end
    end

    # for each keyword, get a list of users
    tweets = []
    user.keywords.each do|keyword|
      begin
        search_updates(keyword.word).each do |tweet|
          tweets << tweet
        end
      rescue => e
        puts e.message
      end
    end

    # get all from mimic
    from_mimic = get_potential_follows_from_mimic(user)

    tweets = shuffle_array(tweets)
    tweets.each do |tweet|
      search_user = tweet["from_user_id"]
      #make sure they arent in the list of already followed
      # make sure they arent already in the current search list,
      # last make sure we havent tried to friend them before
      if !friends.include?(search_user) && !users_to_follow.include?(search_user) && !already_attempted_friending?(user, search_user) && legit_user?(tweet)
        # add to list
        users_to_follow << search_user

        from_mimic.each do |mimic_list|
          id_from_mimic = mimic_list.delete_at(rand(mimic_list.size))
          if !friends.include?(id_from_mimic) && !users_to_follow.include?(id_from_mimic) && !already_attempted_friending?(user, id_from_mimic)
            users_to_follow << id_from_mimic
          end
        end
      end

      if users_to_follow.size > 100
        break
      end
    end

    from_mimic.each do |mimic_list|
      if users_to_follow.size > 100
        break
      end

      users_to_follow << mimic_list.delete_at(rand(mimic_list.size))
    end


    users_to_follow[0..100]

    # filter out all the spam users

#    filtered_users_to_follow = []
#    users_to_follow.each do |id|
#      data = id_to_full_data(user,id)
#      filtered_users_to_follow << id unless !legit_user?(data)
#    end
#
#    filtered_users_to_follow

  end


  def do_follows_for_user(user)
    Rails.logger.debug "doing follows for #{user.login}"
    if should_do_follows(user) then
      users_to_follow = get_users_to_follow(user)

      past_friendings_size = past_friendings_one_day(user).size
      Rails.logger.debug "in the past day we have created #{past_friendings_size} friendings"
      max = 100 - past_friendings_size
      just_followed = follow_from_list(user, users_to_follow, max)

      Rails.logger.debug "for user: #{user.login}, just followed #{just_followed.to_yaml}"
    else
      Rails.logger.debug "too many follows for #{user.login}"
    end

  end

  def user_ids_to_usernames(user, ids)
#    /users/lookup.json?user_id=67517688
    names = []
    ret = user.twitter.get("/1/users/lookup.json",'user_id'=>ids.join(","))
    users = JSON.parse(ret)

  end

  def recent_followed_usernames user
    ids = []

    Friending.find_all_by_user_id(current_user.id,:order=>"created_at").each do |friending|
      ids << friending.follow_id
    end

    user_ids_to_usernames(user, ids)


  end


  def unfollow_from_list(removables, user)
    removables.each do |removable|
      begin
        unfriend_result = user.twitter.post("/friendships/destroy/#{removable.to_s}.json")
        Rails.logger.debug "unfriend result: #{unfriend_result.to_s}"
      rescue => e
        put_error(e)
      end
    end
  end

  def do_unfollows(user)
    #    get the followers list for the user, get all the follows that are at least 3 days old
    # remove all the people that are following and on the friendings list
    followers = get_followers(user)
    # get the ones we could possibly remove
    friendings = Friending.find_all_by_user_id(user.id,:order=>"created_at",:conditions=>["created_at < ?", add_days(Time.now, -3)])
    friendings_ids = []
    friendings.each do |friending|
      friendings_ids << friending.follow_id
    end
    Rails.logger.debug "Created #{friendings_ids.size.to_s} friendings for #{user.login}"

    # if we arent actually following them, dont try to unfollow them
    friendings = remove_no_longer_following(friendings, user)

    # if they are followed us back, remove them from the to-unfollow list
    removables = remove_following_from_friendings(friendings, followers)

    # we have found all the people that we are going to unfollow, do the unfollows
    Rails.logger.debug "removables (#{removables.size}): \n#{removables.sort.join(", ").to_s}"

    unfollow_from_list(removables, user)




  end

  def do_tweet(user)
    # delete all the old ones
    do_deletes(user)

    # checl for something we have rewtweeted or needs to be retweeted
    _tweet = tweet_or_retweet(user)

    if _tweet.nil?
      # there is nothing that we need to tweet or retweet, do the default
      _tweet = default_tweet(user)
      if !_tweet.nil?
        _tweet = Tweet.new(:promotion=>nil, :user=>user,:tweet_id=>_tweet['id'],:deleted=>false)
        _tweet.user = user
        _tweet.save
      end

    end

    if !_tweet.nil?
      Rails.logger.debug "For #{user.login}, we tweeted http://twitter.com/#{user.login}/statuses/#{_tweet.tweet_id}"
    end
  end


  def do_deletes(user)
    Rails.logger.debug "doing deletes for #{user.login}"

    # get all the tweets created by this twitter app, remove them
    user_timeline = user.twitter.get("/statuses/user_timeline.json")
    user_timeline.each do |user_tweet|
      if !user_tweet['source'].nil? && user_tweet['source'].include?(APP_CONFIG[:app_name])

        begin
          user.twitter.post("/statuses/destroy/#{user_tweet['id']}.json")
          #find it in our db, mark it deleted
          _tweet = Tweet.find_by_tweet_id(user_tweet['id'])
          if !_tweet.nil?
            _tweet.update_attribute(:deleted,true)
          end
        rescue => e
          Rails.logger.debug e
        end
      end
    end

    all_non_deleted_tweets = non_deleted_tweets(user, 1,true)
    non_deleted_tweets(user, days_ago=1,has_promotion=false).each { |non_deleted_tweet| all_non_deleted_tweets << non_deleted_tweet}
    all_non_deleted_tweets.each do |non_deleted_tweet|
      Rails.logger.debug "found this non-deleted default tweet #{non_deleted_tweet.to_yaml}"
      delete_tweet(non_deleted_tweet,user)
      non_deleted_tweet.update_attributes({:deleted=>true})
    end



  end

  # returns a list of lists of ids, one list for each mimic
  def get_potential_follows_from_mimic(user)
    # iterate over the mimics in the table
    follow_lists = []
    user.mimics.each do |mimic|
      follow_lists << get_followers(user, mimic.twitter_id)
    end

#    Rails.logger.debug follow_lists.to_yaml
    follow_lists

  end

end