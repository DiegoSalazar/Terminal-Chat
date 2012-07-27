require 'spec_helper'
require_relative '../chat'

describe 'InternalClient' do
  it "joins a user, asks his name and says it back" do
    socket = mock :socket, :gets => 'socket1', :peeraddr => [1,2,3], :write => stub
    server = mock :server, :accept => socket
    server.should_receive(:accept).and_return socket
    socket.should_receive(:write).with "Welcome Sir, what is your name?\n"
    socket.should_receive(:gets).and_return 'socket1'
    socket.should_receive(:write).with "socket1, what a marvelous name.\n"
    
    client = InternalClient.new server
    client.to_s.should == '(2):socket1>'
  end
end