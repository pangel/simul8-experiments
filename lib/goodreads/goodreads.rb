# From git://github.com/ideaoforder/goodreads.git
require 'httparty'

module Goodreads
  include HTTParty
  
  base_uri 'http://www.goodreads.com'
  format :xml
  default_params :key => GOODREADS_API[:api_key]
  default_params :format => "xml"

  @@user_id = GOODREADS_API[:user_id]

  def self.book_by_isbn(isbn, page=1)
    begin
      r = self.get "/book/isbn", :query => {:isbn => isbn, :page => page}
      return nil, nil unless r
      
      r = r["GoodreadsResponse"]["book"]

      rating = r["average_rating"]
      
      if r["reviews"]["total"] == "0"
        reviews = nil 
      else
        reviews = r["reviews"]["review"].reject { |review| 
          review["body"].nil? 
        }
      end

      return rating, reviews
    rescue REXML::ParseException
      nil
    end
  end
  
  # page:  1
  # per_page: 1-200
  # shelf:  read, currently-reading, to-read, etc
  # key: Needed for private profiles. Different from developer key, and is unique to each member. Obtained from the member's rss link on the "my books page" or the lookup via email method.
  # order: a, d
  # sort: position, votes, rating, shelves, avg_rating, isbn, comments, author, title, notes, cover, review, random, date_read, year_pub, date_added, num_ratings, date_updated
  def self.reviews(opts={})
    defaults = {:page => 1, :per_page => 10, :shelf => 'read', :sort => 'date_read', :order => 'd'}
    opts = defaults.merge(opts)
    user_id = opts[:user_id] || @@user_id
    opts.delete(:user_id)
    result = self.get("/review/list_rss/#{user_id}", :query => opts)
    result["rss"]["channel"]["item"].map { |data| Goodreads::Review.new(data) }
    # now...what to do with these...
  end
  
  class Review
    attr_accessor :book_small_image_url, 
                  :user_date_created, 
                  :user_shelves, 
                  :average_rating, 
                  :book_image_url, 
                  :book_medium_image_url, 
                  :user_read_at, 
                  :guid, 
                  :pubDate, 
                  :title, 
                  :author_name, 
                  :isbn, 
                  :book_published,
                  :user_review,
                  :user_name,
                  :user_date_added,
                  :link,
                  :book_id,
                  :book_description,
                  :description,
                  :book,
                  :book_large_image_url,
                  :user_rating
    def initialize(data)
      data.each do |k, v|
        if v and v.is_a? String
          val = v.gsub(/\n/, '').gsub(/\t/, '').strip 
        else
          val = v
        end
        send(:"#{k}=", val)
      end
    end
  end
end
