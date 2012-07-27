require 'socket'

HOST = ARGV[0] || "127.0.0.1"
PORT = ARGV[1] || 3002
MAX_CLIENTS = ARGV[2] || 3

class Server < TCPServer
  def initialize(host, port)
    super host, port
    setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1
    @chatroom = Chatroom.new
    log "Server started on #{host}:#{port}"
  end
  
  def run
    begin
      loop do
        readable = IO.select(sockets).first
        
        readable.each do |socket|
          if socket == self
            @chatroom.accept self
          else
            if socket.eof? # logoff
              @chatroom.kick socket
            else
              @chatroom.receive socket
            end
          end
        end
      end
    rescue Interrupt
      log 'shutdown'
    end
  end
  
  def log(action)
    $stdout.puts "[#{self}|#{@chatroom}: #{Time.now.to_s}] #{action}"
  end
  
  protected
  
  def sockets
    [self] | @chatroom.clients.map { |client| client.socket }
  end
end

class Chatroom
  attr_reader :clients
  
  def initialize
    @clients = []
  end
  
  def accept(socket)
    return if @clients.size >= MAX_CLIENTS
    
    client = InternalClient.new socket
    @clients << client
    
    shout! "Client joined #{client}\n", client
    log 'connect', client
  end
  
  def receive(connection)
    client = client_of connection
    message = client.sends # waiting for user to type and hit enter
    shout! "#{client} #{message}", client
    log 'dispatch', client, message
  end
  
  def kick(connection)
    client = client_of connection
    message = "Client left #{client}"
    @clients.delete client.logoff
    shout! message
    log 'kick', client
  end
  
  def shout!(message, *except)
    (@clients - except).each { |client| client.receives message }
  end
  
  protected
  
  def client_of(connection)
    @clients.detect { |client| client.socket == connection }
  end
  
  private
  
  def log(action, client = nil, message = nil)
    puts "[#{self}|#{@chatroom}: #{Time.now.to_s}] #{action}:#{client} #{message}"
  end
end

class InternalClient
  attr_reader :socket
  
  def initialize(server)
    @server = server
    @socket = @server.accept
    receives "Welcome Sir, what is your name?\n"
    @name = @socket.gets.chomp
    receives "#{@name}, what a marvelous name.\n"
  end
  
  def to_s
    "(#{@socket.peeraddr[1]}):#{@name}>"
  end
  
  def logoff
    @socket.close
    self
  end
  
  def sends
    @socket.gets
  end
  
  def receives(data)
    @socket.write data
  end
end

Server.new(HOST, PORT).run if $0 == __FILE__ # executing from terminal
