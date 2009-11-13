require 'httparty'

module LibraryThing
  include HTTParty
  # key = 
  #   base_uri 'http://covers.librarything.com/devkey/#{key}/medium/isbn/0545010225'
  format :xml
  #   default_params :key => GOODREADS_API[:api_key]
  #   default_params :format => "xml"
  @@api_key = LIBRARYTHING_API[:api_key]
  
  def self.cover_by_isbn(isbn,size="medium")
    "http://covers.librarything.com/devkey/#{@@api_key}/#{size}/isbn/#{isbn}"
  end
  
  def self.all_editions(isbn)
    self.get("http://xisbn.worldcat.org/webservices/xid/isbn/#{isbn}",:query => {:method => 'getEditions', :format => 'xml'})
  end
end