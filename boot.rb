#$LOAD_PATH << $APP_LOAD_PATH  #set the load path from the APP_LOAD_PATH binding

if $RACK_ENV == 'production'
  ENV['GEM_PATH'] = File.join($SERVER_HOME, 'vendor/jruby/1.8')
  ENV['GEM_HOME'] = File.join($SERVER_HOME, 'vendor/jruby/1.8')
else
  puts 'Using global GEM_HOME directory.'
end

require 'rubygems'
require 'java'