namespace :follow do
  task :do_all => :environment do
    include Util
    include Main

    User.all.each do |user|
      puts "doing follows for #{user.login}"
      do_follows_for_user user

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

end