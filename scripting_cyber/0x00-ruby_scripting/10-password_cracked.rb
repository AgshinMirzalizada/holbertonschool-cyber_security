require 'digest'

def dictionary_attack
  # Check if exactly two arguments are provided
  if ARGV.length != 2
    puts "Usage: #{$0} HASHED_PASSWORD DICTIONARY_FILE"
    return
  end

  target_hash = ARGV[0].downcase.strip
  dictionary_file = ARGV[1]

  # Check if the dictionary file exists before opening it
  unless File.exist?(dictionary_file)
    puts "Error: Dictionary file '#{dictionary_file}' not found."
    return
  end

  # Iterate through each word in the dictionary file
  File.open(dictionary_file, "r") do |file|
    file.each_line do |line|
      # Remove whitespace and trailing newlines (\n) from the dictionary word
      word = line.strip
      next if word.empty?

      # Generate SHA-256 hash of the plain word
      current_hash = Digest::SHA256.hexdigest(word)

      # Check if it matches the target hash
      if current_hash == target_hash
        puts "Password found: #{word}"
        return # Exit early once found
      end
    end
  end

  # If the loop finishes without returning, the password wasn't in the file
  puts "Password not found in dictionary."
end

# Execute the attack
dictionary_attack
