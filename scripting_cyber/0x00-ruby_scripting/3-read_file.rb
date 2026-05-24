require 'json'

def count_user_ids(path)
  # Read and parse the JSON file
  file_contents = File.read(path)
  data = JSON.parse(file_contents)

  # Initialize a hash with a default value of 0 to hold the counts
  counts = Hash.new(0)

  # Iterate through the data array and count each userId
  data.each do |item|
    if item['userId']
      counts[item['userId']] += 1
    end
  end

  # Print the counts in the required format
  counts.each do |user_id, count|
    puts "#{user_id}: #{count}"
  end
rescue Errno::ENOENT
  puts "Error: File not found at #{path}"
rescue JSON::ParserError
  puts "Error: Invalid JSON format in #{path}"
end
