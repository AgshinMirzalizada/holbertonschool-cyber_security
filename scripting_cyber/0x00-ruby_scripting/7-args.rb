def print_arguments
  if ARGV.empty?
    puts "No arguments provided."
  else
    puts "Arguments:"
    ARGV.each do |arg|
      puts arg
    end
  end
end
