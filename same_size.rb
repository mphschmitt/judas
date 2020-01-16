require_relative 'Letter'

def explore_directory(d, path)
  directory_file = []
  sub_directories = []

  d.each do |file|
    if File.directory?(path + '/' + file)
      sub_directories.push file
    else
      directory_file.push file
    end
  end

  max = 0
  directory_file.each_with_index do |df, i|
  	puts "#{i}: df: #{df}"
	puts "sub_directory[#{i}]: #{sub_directories[i]}"
	lines = []

	f = File.readlines(path + '/' + df).each do |l|
	  puts "l: #{l.size}"
	  lines << l
	  max = l.size if l.size > max
	end

	file = File.open(path + '/' + df, 'a')
	lines.each do |l|
		l = l.chop
		puts "line: #{l}"
		while l.size < 10
			l << " "
		end
		l << "\n"
		file.puts l
	end
  end
  puts "max: #{max}"
end

path = ARGV[0]
curr_path = path

dir = Dir.new ARGV[0]

explore_directory(dir, path)
