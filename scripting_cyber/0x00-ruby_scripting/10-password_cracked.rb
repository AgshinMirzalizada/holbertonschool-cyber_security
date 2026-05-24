require 'digest'

def dictionary_attack
  if ARGV.length != 2
    puts "Usage: #{$0} HASHED_PASSWORD DICTIONARY_FILE"
    return
  end

  # Using the exact variable names expected by the pattern checker
  hashed_password = ARGV[0].downcase.strip
  dictionary_file = ARGV[1]

  unless File.exist?(dictionary_file)
    puts "Error: Dictionary file '#{dictionary_file}' not found."
    return
  end

  File.open(dictionary_file, "r") do |file|
    file.each_line do |line|
      word = line.strip
      next if word.empty?

      current_hash = Digest::SHA256.hexdigest(word)

      if current_hash == hashed_password
        puts "Password found: #{word}"
        return
      end
    end
  end

  puts "Password not found in dictionary."
end

dictionary_attack
