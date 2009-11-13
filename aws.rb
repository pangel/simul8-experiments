require 'rubygems'
require 'ramazon_advertising'

Ramazon::Configuration.access_key = "1HFKYP32ER3DECPXYZ82"
Ramazon::Configuration.secret_key = "6rnsZrJ2GphGUZn1yV4w85gxKhY454UzP6GExquE"


@z=Ramazon::Product.item_lookup("037540404X", :id_type => "ISBN",:search_index => "Books",:response_group => ["Small","Similarities"])