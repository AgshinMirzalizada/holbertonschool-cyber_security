require 'net/http'
require 'uri'
require 'json'

def post_request(url, body_params = {})
  # Parse the URL string into a URI object
  uri = URI.parse(url)

  # Create the HTTP POST request object
  request = Net::HTTP::Post.new(uri)
  
  # Set Content-Type header to application/json
  request['Content-Type'] = 'application/json'
  
  # Convert the body parameters hash into a JSON string
  request.body = body_params.to_json

  # Send the request over the network
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.request(request)
  end

  # Print the status code and status message (e.g., "201 Created")
  puts "Response status: #{response.code} #{response.message}"
  puts "Response body:"

  # Parse the response body and pretty-print it to match the expected formatting
  parsed_body = JSON.parse(response.body)
  puts JSON.pretty_generate(parsed_body)

rescue SocketError
  puts "Error: Failed to connect to the server."
rescue JSON::ParserError
  # Fallback display if the server response is not valid JSON
  puts response.body
end
