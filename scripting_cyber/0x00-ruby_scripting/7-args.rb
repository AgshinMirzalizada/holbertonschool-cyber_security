def print_arguments
  # Check if the ARGV array is empty
  if ARGV.empty?
    puts "No arguments provided."
  else
    # Iterate through each argument with its 0-indexed position
    ARGV.each_with_index do |arg, index|
      puts "#{index + 1}. #{arg}"
    end
  end
end
