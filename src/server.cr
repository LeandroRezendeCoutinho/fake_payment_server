require "kemal"
require "http/client"

before_post "/charge" do |env|
  env.response.content_type = "application/json"
end

get "/" do
  "Hello World!"
end

get "/charges" do
  {
    amount:   100,
    currency: "brl",
  }.to_json
end

post "/charges" do |env|
  env.response.content_type = "application/json"
  # sleep rand # simulate slow request
  # puts "Params: #{env.params}"
  {
    amount:       env.params.json["amount"].as(Int64),
    capture:      env.params.json["capture"].as(Bool),
    status:       env.params.json["status"].as(String),
    order_id:     env.params.json["order_id"].as(String),
    payment_type: env.params.json["payment_type"].as(String),
    source_type:  env.params.json["source_type"].as(String),
  }.to_json
end

post "/webhooks" do |env|
  env.response.content_type = "application/json"
  env.response.status_code = 200
  puts "Webhook: #{env.params.json}"
  {
    success: true
  }.to_json
end

get "/bench" do
  time = Time.local
  url = "http://127.0.0.1:3000/charges"  
  
  1.times do |n|
    json_payload = %({
      "amount": #{rand(1_000)},
      "status": "authorized",
      "capture": true,
      "order_id": #{n},
      "payment_type": "credit",
      "source_type": "card"
    })

    puts "Request #{n}"
    
    begin
      response = HTTP::Client.post(url, body: json_payload, headers: HTTP::Headers{"Content-Type" => "application/json"})    
      # puts "Response body: #{response.body}"
    rescue exception
      puts "Error: #{exception}"      
    end    
  end
  puts "Elapsed: #{Time.local - time}"
end

Kemal.run
