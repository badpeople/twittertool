namespace :follow do
  task :do_all => :environment do
    include Util
    include Main

    User.all.each do |user|
      puts "doing all follows for: #{user.login}"
      followed = follow(user)
      puts "followed: #{followed.to_yaml}"
    end
  end

end