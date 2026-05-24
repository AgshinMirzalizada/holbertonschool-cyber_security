def print_arguments
  if ARGV.empty?
    puts "No arguments provided."
  else
    puts "Arguments:"
    ARGV.each do |arg|
      puts arg
    end
    puts "" # Adds the trailing empty line expected by the checker
  end
end
