module Helpers
  include Rack::Utils
  class KenSearch
    include HTTParty
    base_uri 'http://www.freebase.com/api/service'
    format :json
  
    def self.search(string)
      self.get('/search', :query => {:query => string})
    end
  end
  
  alias_method :h, :escape_html
  
  def blue(string)
    puts "\e[0;34m #{string.inspect} \e[m\n\n"
  end
  
  def partial(name, options={})
    haml "_#{name}".to_sym, options.merge(:layout => false)
  end
  
  def oclc_search(opts)
    default_opts = {:format=>'rss', :start => '1', :count => '20', :cformat => 'all'}
    OCLC.OpenSearch default_opts.merge(opts)
  end
  
  def oclc_book_by_isbn(isbn)
    # Using OpenSearch instead of find_by_isbn because because I am too lazy to parse MARC records.
    oclc_search(:q => isbn, :count => '1').records.first
  end
  
  def related_books(isbn)
    all_editions = LibraryThing.all_editions(params["isbn"])["rsp"]["isbn"]
    blue all_editions
    Pewbot.bulk_related_books all_editions
  end
  
  def related_books_alt(isbn)
    r = Ramazon::Product.item_lookup isbn, :id_type => "ISBN", :search_index => "Books", :response_group => "Small,Similarities"
    r[0].get("SimilarProducts SimilarProduct").map do |product|
      {"title" => product.at("Title").text, "asin" => product.at("ASIN").text}
    end
  end
  
  def topic(query)
    id = KenSearch.search query
    return nil,nil if id["result"].empty?
    topic = ::Ken::Topic.get id["result"].first["id"]
    if topic.properties.find { |p| p.id == "/book/author/works_written" }
      type = :author
    else
      type = :generic
    end
    return topic, type
  end

end