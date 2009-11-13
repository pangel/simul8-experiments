require 'httparty'

module Pewbot
  include HTTParty
  base_uri "http://webcat.hud.ac.uk:4128/pewbot"
  format :xml
  
  def self.bulk_related_books(isbns)
    isbns.inject([]) do |list,isbn|
      list + related_books(isbn)
    end
  end
  
  def self.related_books(isbn)
    self.get("/#{isbn}/extended")["isbnlist"]["isbn"] or []
  end
end