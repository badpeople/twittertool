namespace :follow do
  task :do_all => :environment do
    include Util
    include Main

    User.all.each do |user|
      puts "doing follows for #{user.login}"
      do_follows_for_user user

    end

    User.all.each do |user|
      puts "doing unfollows for #{user.login}"
      do_unfollows(user)
    end

  end

  task :do_unfollows => :environment do
    include Util
    include Main

    User.all.each do |user|
      puts "doing unfollows for #{user.login}"
      do_unfollows(user)
    end
  end

  task :do_deletes =>:environment do
    include Main

    User.all.each do |user|
      do_deletes(user)
    end
  end

  task :do_tweets =>:environment do
    include Main
    include Util

    User.all.each do |user|
      begin
        puts "doing tweets for #{user.login}"
        do_tweet(user)
      rescue =>e
        put_error(e)
      end
    end
  end

end