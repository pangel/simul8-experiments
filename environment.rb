require 'rubygems'
require 'haml'
require 'sinatra' unless defined?(Sinatra)

configure do
  # Constants
  PROJECT_NAME = "simul8-experiments"

  require 'apicodes'

  # Load extensions
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

  require 'ken'
  require 'ramazon_advertising'
  require 'wcapi/wcapi'
  require 'goodreads/goodreads'
  require 'librarything'
  require 'pewbot'
  require 'bookgraph'
  
  puts "...ready"
end

configure :development do end