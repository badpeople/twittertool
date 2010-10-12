require 'rand'
require 'json'

module Main

  include Util

  def follow_from_list(user, twitter_users)
    puts "for user #{user.login}, attempting to follow #{twitter_users.to_yaml}"


    just_friended = []

    #follow each one of them
    twitter_users.each do |twitter_user|
      begin
        # execute the follow
        follow_result = user.twitter.post('/friendships/create','user_id'=>twitter_user)
#        follow_result = user.twitter.friendship_create(twitter_user)
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
        puts e.backtrace
      end

    end

    just_friended
  end

  def get_users_to_follow(user)
    # get all the users the user is currently following
    friends = user.twitter.get('/friends/ids')

    # for each keyword, get a list of users
    search_users = []
    user.keywords.each do|keyword|
      users_from_keyword_search(keyword.word).each do |user_to_follow|
        search_users << user_to_follow
      end
    end

    users_to_follow = []
    search_users = shuffle_array(search_users)
    i=0
    while users_to_follow.size < 10 && i < search_users.size # end if we have enough to follow or we run out of users
      i += 1
      search_user = search_users[i]
      #make sure they arent in the list of already followed
      # make sure they arent already in the current seach list,
      # last make sure we havent tried to friend them before
      if !friends.include?(search_user) && !users_to_follow.include?(search_user) && !already_attempted_friending?(user, search_user)
        # add to list
        users_to_follow << search_user
      end
    end
    users_to_follow
  end

  def should_do_follows(user)
    friendings = Friending.find_all_by_user_id(user.id,:conditions=>["created_at > ?",Time.now - (60 * 60 * 24)])
    !friendings.nil? || friendings.size < 100

  end

  def do_follows_for_user(user)
    if should_do_follows(user) then
      users_to_follow = get_users_to_follow(user)
      just_followed = follow_from_list(user, users_to_follow)

      puts "for user: #{user.login}, just followed #{just_followed.to_yaml}"
    else
      puts "too many follows for #{user.login}"
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


end