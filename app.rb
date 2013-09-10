require "sinatra"
require "slim"
require "sass"
require "coffee-script"
require "yaml"
require "active_support/all"

class Commando < Sinatra::Base
  titles = HashWithIndifferentAccess.new
  Dir.glob("./titles/*").each {|file| titles.update YAML.load_file file}

  get "/" do
    @titles = titles
    slim :index
  end

  titles.each do |key, value|
    get "/" + key do
      @title = value
      slim :application
    end
  end
end
