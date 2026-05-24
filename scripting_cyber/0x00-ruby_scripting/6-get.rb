require 'net/http'
require 'uri'
require 'json'

def get_request(url)
  # Parse the URL string into a URI object
  uri = URI.parse(url)

  # Perform the HTTP GET request
  response = Net::HTTP.get_response(uri)

  # Print the status code and status message (e.g., "200 OK")
  puts "Response status: #{response.code} #{response.message}"
  puts "Response body:"

  # Parse the response body and pretty-print it to format it cleanly
  parsed_body = JSON.parse(response.body)
  puts JSON.pretty_generate(parsed_body)

rescue SocketError
  puts "Error: Failed to connect to the server (network issue)."
rescue JSON::ParserError
  # Fallback if the returned body isn't structured JSON data
  puts response.body
end
