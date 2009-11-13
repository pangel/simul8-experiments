
require 'rubygems'
GOODREADS_API = {}
GOODREADS_API[:api_key] = "mmqNVq1O4Pw1XD4eLLUTA"   

require 'goodreads/goodreads'

a = Goodreads.book_by_isbn("038523712X")
require 'pp'
# b = a["GoodreadsResponse"]["book"]["reviews"]["review"].sort_by { |e| e["votes"].to_i }.reverse
pp a.to_hash
require 'wcapi/wcapi'
require 'pewbot'
require 'pp'
# c = WCAPI::Client.new :wskey =>  'omquRXhy1nxKQQWeoTjFxEwuHJQmioU0M0kit62O8t41QAL0wNNwYlWrxO8sDA3qTCU21q2siMclOD4r', :debug => true
# pp c.OpenSearch(:q => 'nothomb', :format => "rss").records.first


# b = c.GetRecord(:type => "isbn", :id => "9780375404047")

# pp b.record.title
# 
# pp Pewbot.related_books "0441172717"
# 
pp Pewbot.related_books("0761950710")["isbnlist"]["isbn"][1].attributes["title"]
# 
# class Delicious
#   include HTTParty
#   base_uri 'https://api.del.icio.us/v1'
#   def initialize
#     
#   @auth = {:username => 'pangel', :password => 'n6q6cefn'}
#   end
#   # query params that filter the posts are:
#   # tag (optional). Filter by this tag.
#   # dt (optional). Filter by this date (CCYY-MM-DDThh:mm:ssZ).
#   # url (optional). Filter by this url.
#   # ie: posts(:query => {:tag => 'ruby'})
#   def posts(options={})
#     options.merge!({:basic_auth => @auth})
#     self.class.get('/posts/get', options)
#   end
#   
#   # query params that filter the posts are:
#   # tag (optional). Filter by this tag.
#   # count (optional). Number of items to retrieve (Default:15, Maximum:100).
#   def recent(options={})
#     options.merge!({:basic_auth => @auth})
#     self.class.get('/posts/recent', options)
#   end
# end
# 
# delicious = Delicious.new
# 
# pp delicious.recent