require "eventmachine"
require "twitter"
require "tweetstream"
require "logger"

log = Logger.new STDOUT
STDOUT.sync = true

rest = Twitter::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY"],
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
  oauth_token: ENV["TWITTER_ACCESS_TOKEN"],
  oauth_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"],
)

TweetStream.configure do |config|
  config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
  config.oauth_token = ENV["TWITTER_ACCESS_TOKEN"]
  config.oauth_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
  config.auth_method = :oauth
end

stream = TweetStream::Client.new

EventMachine.error_handler do |ex|
  log.error ex.message
end

EventMachine.run do
  EventMachine.add_periodic_timer(300) do
    friends = rest.friend_ids.all
    followers = rest.follower_ids.all
    to_follow = followers - friends
    to_unfollow = friends - followers

    # follow
    to_follow.each do |id|
      log.info "following #{id}"
      log.info "done." if rest.follow id
    end

    # unfollow
    to_unfollow.each do |id|
      log.info "unfollowing #{id}"
      log.info "done." if rest.unfollow id
    end
  end

  stream.on_inited do
    log.info "init"
  end

  stream.userstream do |status|
    log.info "status from @#{status.from_user}: #{status.text}"
    next unless status.from_user == "buzztter"
    tweet = rest.update "#{status.id}やめろ"
    log.info "tweeted: #{tweet.text}" if tweet
  end
end
