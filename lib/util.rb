
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

    puts "fetching: #{uri_str}"

    response = Net::HTTP.get_response(URI.parse(uri_str))
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
end