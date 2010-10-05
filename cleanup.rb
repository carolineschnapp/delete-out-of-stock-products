require 'rubygems'
require 'shopify_api'

APIKEY = 'APIKEY'
PASSWORD = 'PASSWORD'
SHOPNAME = 'shopname'

CYCLE = 10 * 60

# Telling your shop who's boss.
ShopifyAPI::Base.site = "http://#{APIKEY}:#{PASSWORD}@#{SHOPNAME}.myshopify.com/admin"

# Initializing.
start_time = Time.now

# How many.
product_count = ShopifyAPI::Product.count
nb_pages      = (product_count / 250.0).ceil

# Do we actually have any work to do?
puts "Yo man. You don't have any product in your shop. duh!" if product_count.zero?

# While we still have products.
1.upto(nb_pages) do |page|
  unless page == 1
    stop_time = Time.now
    puts "Current batch processing started at #{start_time.strftime('%I:%M%p')}"
    puts "The time is now #{stop_time.strftime('%I:%M%p')}"
    processing_duration = stop_time - start_time
    puts "The processing lasted #{processing_duration.to_i} seconds."
    wait_time = CYCLE - processing_duration
    puts "We have to wait #{wait_time.to_i} seconds then we will resume."
    sleep wait_time
    start_time = Time.now
  end
  puts "Doing page #{page}/#{nb_pages}..."
  products = ShopifyAPI::Product.find( :all, :params => { :limit => 250, :page => page } )
  products.each do |product|
    puts product.title
    any_in_stock = product.variants.any? do |variant|
      variant.inventory_management == '' || variant.inventory_policy == 'continue' || variant.inventory_quantity > 0
    end
    if not any_in_stock
      puts "--- Deleting #{product.title}..."
      product.destroy
    end
  end
end

puts "Over and out."