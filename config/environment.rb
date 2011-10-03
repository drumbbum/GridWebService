# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
GridClient::Application.initialize!

#ActionController::AbstractRequest.relative_url_root = "localhost:3000"

require "lib/GridClient.rb"
@client = GridClientClass.new
@client.periodicSync
@client.periodicPopulateDatabase


unless ENV['RAILS_RELATIVE_URL_ROOT'].nil?
  puts "Rails Relative URL Root = " + ENV['RAILS_RELATIVE_URL_ROOT']
end