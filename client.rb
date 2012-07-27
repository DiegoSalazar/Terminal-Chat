require 'socket'

@host = ARGV[0] || '127.0.0.1'
@port = ARGV[1] || 3002

$prompt = ':> '
puts "Name?"
print $prompt; $stdout.flush
$name = gets

socket = TCPSocket.new @host, @port
socket.puts $name

loop do
  puts socket.gets
  socket.puts gets
end

socket.close