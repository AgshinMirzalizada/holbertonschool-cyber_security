require 'open-uri'
require 'uri'
require 'fileutils'

def download_file
  # Check if exactly two arguments are provided
  if ARGV.length != 2
    # $0 automatically grabs the current script's file name dynamically
    puts "Usage: #{$0} URL LOCAL_FILE_PATH"
    return
  end

  url = ARGV[0]
  local_path = ARGV[1]

  puts "Downloading file from #{url}..."

  begin
    # Ensure the parent directory structure exists before writing the file
    dir = File.dirname(local_path)
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

    # Stream and write the remote file content locally
    URI.open(url) do |remote_file|
      File.open(local_path, 'wb') do |local_file|
        local_file.write(remote_file.read)
      end
    end

    puts "File downloaded and saved to #{local_path}."

  rescue SocketError, OpenURI::HTTPError => e
    puts "Network Error: Unable to fetch the file. #{e.message}"
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
  end
end

# Execute the method automatically when running the script
download_file
