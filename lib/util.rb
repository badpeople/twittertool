
module Util
  def search_updates(keyword)
    keyword =   CGI::escape keyword
    url = "http://search.twitter.com/search.json?q=#{keyword}"
    body = fetch(url).body

    json = JSON.parse(body)["results"]

    json
  end

  def users_from_keyword_search(keyword)
    tweets = search_updates(keyword)
    twitter_users = []
    tweets.each do |tweet|
      twitter_users << tweet["from_user_id"]
    end

    twitter_users

  end

  def fetch(uri_str, limit = 10)
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    print "fetching: #{uri_str}"

    response = Net::HTTP.get_response(URI.parse(uri_str))
    print "rate limit remaining: #{response.header['x-ratelimit-remaining']}\n"

    case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        fetch(response['location'], limit - 1)
      else
        response.error!
    end
  end

  def shuffle_array(arr)
    arr.size.downto(1) { |n| arr.push(arr.delete_at(rand(n))) }
    arr
  end

  def already_attempted_friending?(user, to_follow)
    Friending.find(:all,:conditions=>{:user_id=>user.id,:follow_id=>to_follow}).size > 0
  end

  def get_followers(user, cursor="-1")
    followers = user.twitter.get("/followers/ids.json",'cursor'=>cursor)
#    followers_json = user.twitter.get("/followers/ids/#{user.login}.json",'cursor'=>cursor)
#    followers_obj = JSON.parse(followers_json)
#    followers = followers_obj[:ids].nil? ? [] : followers_obj[:ids]
    followers = [] unless !followers.nil?

#    if !followers_obj[:next_cursor_str].nil? && followers_obj[:next_cursor_str] != 0
#      get_followers(user, followers_obj[:next_cursor_str]).each do |follower|
#        followers << follower
#      end
#
#    end

    followers

  end

  def remove_following_from_friendings(friendings, following)
    # remove everyone we did not follow
    to_unfollow = []
    following_set = following.to_set
    friendings.each do | friending|
      to_unfollow << friending.follow_id unless following_set.include?(friending.follow_id)
    end

    to_unfollow

  end

#  from the friendlings list it removes all the people that the user is no longer following
#  to be used for
  def remove_no_longer_following(friendings, user,cursor=-1)
    # get all the people this user is following
    friends = user.twitter.get("/friends/ids.json",'cursor'=>cursor.to_s)
    puts "people #{user.login} is following\n#{friends.sort.join(', ').to_s}"

    friends = friends.to_set

    ret_friendings = []
    friendings.each do |friending|
      if friends.include?(friending.follow_id)
        ret_friendings << friending
      end
    end

    ret_friendings

  end

  def put_error(e)
    puts "#{Time.now.to_s}: #{e}"
    puts e.message
    puts e.backtrace
  end

  def retain_all(to_filter, must_be_in)
    new_list = []
    set2 = must_be_in.to_set
    to_filter.each do |item|
      if set2.include?(item)
        new_list << item
      end
    end

    new_list

  end

  def remove_all(to_filter, remove_these)
    to_filter_set = to_filter.to_set
    remove_these.each do |to_remove|
      to_filter_set.delete(to_remove)
    end
    to_filter_set.to_a

  end

  def past_friendings_one_day(user)
    Friending.find_all_by_user_id(user.id, :conditions=>["created_at > ?", Time.now - 1 *(60 * 60 * 24)])
  end


  def ids_to_full_data(user, ids)
#    data = user.twitter.get("/users/show.json?user_id=#{ids[0].to_s}")
#    data = user.twitter.get("/users/show.json?user_id=#{CGI::escape(ids.join(","))}")
    data = {}
    ids.each do |id|
      data[id] = id_to_full_data(user, id)
    end
    data
  end

  def id_to_full_data(user, id)
    begin
      user.twitter.get("/users/show.json?user_id=#{id.to_s}")
    rescue => e
      return nil
    end
  end



  def should_do_follows(user)
    friendings = past_friendings_one_day(user)
    if friendings.nil? then
      true
    else
      friendings.size < 100
    end

  end


  def legit_user?(data)
    begin
      return false unless !data.nil?
      return false unless !data['profile_image_url'].include?('default')
#      return false unless data['followers_count'] > 5
      return true
    rescue => e
      put_error e
      return true
    end
  end


end