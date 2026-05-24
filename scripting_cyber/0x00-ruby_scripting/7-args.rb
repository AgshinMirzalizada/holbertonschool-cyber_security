def print_arguments
  if ARGV.empty?
    puts "No arguments provided."
  else
    # Construct the exact layout: "Arguments:\n1\n2\n3\n\n"
    output = "Arguments:\n" + ARGV.join("\n") + "\n\n"
    print output
  end
end
