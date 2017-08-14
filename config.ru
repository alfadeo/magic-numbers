require_relative 'mn.rb'
#use Rack::Reloader
use Rack::Static, :urls => ["/images"] 
run Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, [html]] }
