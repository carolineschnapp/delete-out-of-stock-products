APIKEY = 'APIKEY'
PASSWORD = 'PASSWORD'
SHOPNAME = 'shopname'

CYCLE = 10 * 60       # 10 minutes times 60 seconds per minute. Total in seconds.

require 'rubygems'    # Need this to use the shopify_api gem.
require 'shopify_api' # shopify_api gem is tellement utile to speak to your shop.

# Telling your shop who's boss.
ShopifyAPI::Base.site = "http://#{APIKEY}:#{PASSWORD}@#{SHOPNAME}.myshopify.com/admin"

# Initializing.
page = 1
start_watch = Time.now

# How many.
count = ShopifyAPI::Product.count
nb_pages = (count/250.0).ceil

# Do we actually have any work to do?
if nb_pages.zero?
  puts "Yo man. You don't have any product in your shop."
end

# While we still have products.
while (page <= nb_pages) do
  unless page == 1
    stop_watch = Time.now
    puts "Our last batch processing started at #{start_watch.strftime('%I:%M%p')}"
    puts "The time is now #{stop_watch.strftime('%I:%M%p')}"
    duration = stop_watch - start_watch
    puts "The processing lasted #{duration} seconds."
    wait_time = CYCLE - duration
    puts "We have to wait #{wait_time} seconds then we will resume."
    sleep wait_time
    start_watch = Time.now
  end
  puts "Doing page #{page} of #{nb_pages}..."
  products = ShopifyAPI::Product.find( :all, :params => { :limit => 250, :page => page } )
  products.each do |product|
    puts product.title
    variants = product.variants.select do |variant|
      variant.inventory_management == '' || variant.inventory_policy == 'continue' || variant.inventory_quantity > 0
    end
    if variants.empty?
      puts "--- Deleting #{product.title}..."
      product.destroy
    end
  end
  page += 1
end

puts "Over and out."