# Sonic Pi init file
# Code in here will be evaluated on launch.


require 'FileUtils'
curDir = Dir.home
puts "Files Included from Init"
pluginDir = curDir.to_s + "/.sonic-pi/plugins"
Dir.foreach(pluginDir) do |inclFiles|
	if inclFiles.include? ".rb"
		fileToIncl = pluginDir + "/" + inclFiles.to_s
		puts fileToIncl.to_s
		require_relative fileToIncl
	end
end
