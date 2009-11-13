require 'rubygems'
require 'ramazon_advertising'
require 'httparty'

module BookGraph
class << self;
  
  Ramazon::Configuration.access_key = "1HFKYP32ER3DECPXYZ82"
  Ramazon::Configuration.secret_key = "6rnsZrJ2GphGUZn1yV4w85gxKhY454UzP6GExquE"
  OCLC_API = 'omquRXhy1nxKQQWeoTjFxEwuHJQmioU0M0kit62O8t41QAL0wNNwYlWrxO8sDA3qTCU21q2siMclOD4r'
  GOOGLE_BOOKS_URL = "http://books.google.com/books/feeds/volumes"
  
  def find_books(query)
    r = HTTParty.get 'http://www.worldcat.org/webservices/catalog/search/opensearch', 
                :format => :xml, :query => { :q => query, :format => 'atom', 
                                             :wskey => OCLC_API }
    r["feed"]["entry"].map { |book|
      isbn = book["dc:identifier"].nil? ? nil : book["dc:identifier"].first.tr("urn:ISBN:", "") 
      {:isbn => isbn}
    }
  end
  
  def reviews_of_book
  end
  
  # Graph methods
  def books_of_author(authors)
    debug "Finding books by #{authors.join(' and ')}"
    authors.inject([]) do |acc,author|
      query = %Q(inauthor:"#{author}")
      acc.concat feed_to_hash(google_request(query,(6/authors.size).ceil))
    end
  end
  
  def similar_to_book(isbn)
    debug "Finding books similar to #{isbn}"
    r = Ramazon::Product.find :item_id => isbn, :operation => "SimilarityLookup",
                              :id_type => "ISBN", :search_index => "Books", 
                              :response_group => "Small,ItemAttributes,EditorialReview"
    r.map do |product|
      product = product.xml_doc
      title = product.at("Title") ? product.at("Title").text : nil
      author = product.at("Author") ? product.at("Author").text : nil
      isbn = product.at("ISBN") ? product.at("ISBN").text : nil
      {:title => title, :isbn => isbn, :author => author }
    end
  end
  
  def books_about_book(title,authors)
    debug "Finding books about #{title} by #{authors.join(' and ')}"
    # Is it enough to filter out books by the original author(s)?
    queryminus = authors.map { |author| %Q(-inauthor:"#{author}")}.join(" ")
    query = %Q("#{title}" #{queryminus})
    feed_to_hash google_request(query,6)
  end
  
  def books_on_subjects(subjects)
    debug "Finding books about #{subjects[0,3].join(', ')} and maybe more."
    # Searching 3 subjects at a time to make sure we get some results.
    # Ideas for improvements: try all combinations? group by category?
    r = subjects.enum_slice(2).inject([]) do |acc,slice|
      query = slice.map { |subject| %Q(subject:"#{subject}") }.join(" ")
      acc << google_request(query,2)
    end

    feed_to_hash(r)
  end
  
  def book_info(isbn)
    debug "Finding info about #{isbn}"
    r = Ramazon::Product.item_lookup isbn, :id_type => "ISBN", :search_index => "Books", 
                                           :response_group => "Small,EditorialReview"
    {
      :title => r[0].title, 
      :author => author_of_book(isbn), 
      :description => r[0].get("EditorialReview Content").text.split.join(" ")
    }
  end
    
  def author_of_book(isbn)
    # Amazon's author field cannot be trusted.
    debug "Finding author of #{isbn}"
    r = google_request("isbn:#{isbn}",1)
    author = r["feed"]["entry"]["dc:creator"]
    return [author].flatten
  end
    
  def editions(isbn)
    debug "Finding all editions of #{isbn}"
    r = HTTParty.get "http://xisbn.worldcat.org/webservices/xid/isbn/#{isbn}",
                 :format => :xml, :query => { :method => 'getEditions', 
                                              :format => 'xml', :fl => '*' }
    if r["rsp"]["stat"] == "invalidId" or r["rsp"]["isbn"].is_a? String
      []
    else
      r["rsp"]["isbn"][1..-1].map do |isbn| #First element is original ISBN
        {
          :isbn      => isbn.to_s,
          :publisher => isbn.attributes["publisher"],
          :city      => isbn.attributes["city"],
          :year      => isbn.attributes["year"],
          :form      => isbn.attributes["form"],
          :edition   => isbn.attributes["ed"]
        }
      end
    end
  end
    
  def subjects_of_book(isbn)
    # From Amazon
    # From Freebase
    # From Google Books
    debug "Finding subjects of #{isbn} on Google Books"
    search_result = google_request("isbn:#{isbn}",1)
    book_info = HTTParty.get search_result["feed"]["entry"]["id"], :format => :xml
    
    book_info["entry"]["dc:subject"].to_a
  end
  
  def feed_to_hash(feeds)
    feeds = [feeds] unless feeds.is_a? Array
    feeds.inject([]) { |acc,feed|
      pp feed.code.class if feed["feed"].nil?
      entries = feed["feed"]["entry"]
      next(acc) unless entries
      entries = [entries] unless entries.is_a? Array
      entries.map { |entry|
        isbn = entry["dc:identifier"].find { |id| id =~ /ISBN/ }
        isbn = isbn.tr("ISBN:","") if isbn
        {:title => entry["dc:title"].to_a.join(" "), :isbn => isbn}
      }
    }.compact.uniq
  end
  
  def blue(string)
    puts "\e[0;34m #{string.inspect} \e[m\n\n"
  end
  
  def debug(msg)
    puts msg
  end
  
  def google_request(query,max_results)
    params = {:format => :xml, :query => { :q => query, 'max-results' => max_results}}
    begin
      r = HTTParty.get(GOOGLE_BOOKS_URL, params)
    end while r.code == 403
    return r      
  end
  
  def disp(query)
    m = []
    
    firstbook = find_books(query).first
    m << ["Found ISBN #{firstbook[:isbn]}", 0]
    
    info = book_info firstbook[:isbn]
    m << ["We know the following:", 0]
    m << ["Title: #{info[:title]}", 2] << ["Author(s): #{info[:author].join(', ')}", 2] << ["Description: #{info[:description]}", 2]
    
    subjects = subjects_of_book firstbook[:isbn]
    m << ["It belongs to ", 0] << [subjects, 2]
    
    same_subjects = books_on_subjects subjects
    m << ["Books on similar subjects:", 0]
    same_subjects.each { |b| m << ["#{b[:title]}, ISBN #{b[:isbn]}", 2] }
    
    same_author = books_of_author info[:author]
    m << ["Books by #{info[:author].join(' and/or ')}:", 0]
    same_author.each { |b| m << ["#{b[:title]}, ISBN #{b[:isbn]}", 2] }
    
    about_x = books_about_book info[:title], info[:author]
    m << ["Books about #{info[:title]}:", 0]
    about_x.each { |b| m << ["#{b[:title]}, ISBN #{b[:isbn]}", 2] }
    
    similar = similar_to_book firstbook[:isbn]
    m << ["Books similar #{info[:title]} (from Amazon):", 0]
    similar.each { |b| m << ["#{b[:title]}, ISBN #{b[:isbn]}", 2] }
    
    m.each do |mes|
      puts " "*mes[1] + mes[0].to_s
    end
    nil
  end
end # end class << self
end