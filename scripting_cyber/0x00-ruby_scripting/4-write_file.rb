require 'json'

def merge_json_files(file1_path, file2_path)
  # Read and parse file1 (source of new data)
  file1_content = File.read(file1_path)
  data1 = JSON.parse(file1_content)

  # Read and parse file2 (destination file)
  file2_content = File.read(file2_path)
  data2 = JSON.parse(file2_content)

  # Ensure both objects are parsed as arrays before combining
  # This merges the objects from file1 into the array of file2
  merged_data = data2 + data1

  # Write the combined data back into file2_path with pretty formatting
  File.open(file2_path, 'w') do |f|
    f.write(JSON.pretty_generate(merged_data))
  end
rescue Errno::ENOENT => e
  puts "Error: File missing - #{e.message}"
rescue JSON::ParserError => e
  puts "Error: Invalid JSON format encountered - #{e.message}"
end
