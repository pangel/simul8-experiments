require 'vendor/gems/environment'
Bundler.require_env

require 'environment_local'

configure do
  require 'helpers'
  set :views, "#{File.dirname(__FILE__)}/views"
    
  B = BookGraph
  
  OCLC = WCAPI::Client.new :wskey => OCLC_API[:api_key]
  
  Ramazon::Configuration.access_key = AMAZON_API[:acces_key]
  Ramazon::Configuration.secret_key = AMAZON_API[:secret_key]
end

helpers do
  include Helpers
end

get '/' do  haml :index; end

get '/worldcat' do
  session["query"] = @query = params["query"]
  if @query 
    @results = oclc_search :q => @query 
    @topic, @type = topic(@query)
  end
  haml :worldcat_index
end

get '/worldcat/:isbn' do
  isbn       = params["isbn"]
  @query     = session["query"]
  @book      = oclc_book_by_isbn(isbn)
  @cover_url = LibraryThing.cover_by_isbn(isbn)
  @related   = related_books_alt(isbn)
  
  @rating, @reviews = Goodreads.book_by_isbn(isbn)
  
  haml :worldcat_details
end

get '/discovery/:isbn' do
  @isbn           = params["isbn"]
  book_info       = B.book_info(@isbn)
  
  @author         = book_info[:author].join(', ')
  @title          = book_info[:title]
  @description    = book_info[:description]
  
  @similar        = B.similar_to_book @isbn
  @same_author    = B.books_of_author book_info[:author]
  @same_subjects  = B.books_on_subjects B.subjects_of_book(@isbn)
  @about_it       = B.books_about_book @title, book_info[:author]
  @other_editions = B.editions @isbn
  haml :discovery
end