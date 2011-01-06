require 'util'
require 'main'

namespace :follow do
  task :do_all => :environment do
    include Util
    include Main

    start_time = Time.now
    run_for_all_enabled(3) do |user,t|
      begin

        Rails.logger.info "{Thread #{t}}: START doing follows for #{user.login}"
        # check to make sure the user is still authed
        if still_authorized user
          do_follows_for_user user
        else
          Rails.logger.info "Couldn't make an authenticated call for #{user.login}"
        end
        Rails.logger.info "END doing follows for #{user.login}"
      rescue => e
        Rails.logger.error e.message
      end
    end

    run_for_all_enabled(3) do |user,t|
      begin
        Rails.logger.info  "{Thread #{t}}: START doing unfollows for #{user.login}"
        do_unfollows(user)
      rescue => e
        Rails.logger.error e.message
      end
      Rails.logger.info  "{Thread #{t}}: END doing unfollows for #{user.login}"
    end

    num_users = User.all_enabled.size
    Rails.logger.info "for #{num_users} users it to took #{Time.now - start_time}"
    Rails.logger.info "Thats #{((Time.now - start_time )/num_users)} secs/user"


  end

  task :do_unfollows => :environment do
    include Util
    include Main

    User.all_enabled.each do |user|
      puts "doing unfollows for #{user.login}"
      do_unfollows(user)
    end
  end

  task :do_deletes =>:environment do
    include Main

    User.all_enabled.each do |user|
      puts "doing deletes for #{user.login}"
      do_deletes(user)
    end
  end

  task :do_tweets =>:environment do
    include Main
    include Util

    User.all_enabled.each do |user|
      begin
        puts "doing tweets for #{user.login}"
        do_tweet(user)
      rescue =>e
        put_error(e)
      end
    end
  end

end