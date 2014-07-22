# An alternative to threadbased appraoch from the concurrent connection problem.
# Same problem - gets waits so only one user at a time

require 'socket'

$server = TCPServer.new(3000)
$readers = [$server]
$work = {}

$accept_socket = Proc.new do |server|
  socket = server.accept
  socket.puts("ITS A CALCULATOR. ADD THINGS")
  async_read(socket) do
    input1 = socket.gets
    num1 = Integer(input1)
    
    async_read(socket) do
      input2 = socket.gets
      num2 = Integer(input2)
      socket.puts(num1+num2)
      socket.close
    end
    #This could be nested as far as you want. CALLBACK HELL
  end
  
end

#When The socket is ready to read it'll call the first read proc.

#ASYNC READ took over for this other stuff
# $first_read = Proc.new do |socket|
#   input = socket.gets
#   socket.puts("1. #{input}")
#
#   $work[socket] = $second_read
# end
#
# $second_read = Proc.new do |socket|
#   input = socket.gets
#   socket.puts("2. #{input}")
#
#   socket.close
#   $readers.delete(socket)
#   $work.delete(socket)
# end


#This proc is a callback.
def async_read(socket, &prc)
  $readers << socket
  $work[socket] = Proc.new do
    $work.delete(socket)
    $readers.delete(socket)
    prc.call
  end
end

##You can't be a ready reader unless you're returned by IO select.
def process_ready_readers(ready_readers)
  ready_readers.each do |rr|
    if rr.class == TCPServer
      puts "connecting"
      socket = rr.accept
      puts socket
      $readers << socket
    else
      # if it's not a TCP server it's a TCPsocket.
      puts "reading: #{rr}"
      input = rr.gets
      rr.puts(input)
      rr.close
      
      $readers.delete(rr)
    end
  end
end


#YO THIS IS HOW NODE WORKS. There are hardly ever synchronous methods, you always pass callbacks which pick up where you left off.
$work[$server] = $accept_socket
while true
  #Readers are things that are ready to be read
  # IO::select is fucking black magic
  # IO select is the only time we're waiting. It processes FIFO style and doesn't wait on any particular reader. NON BLOCKING IO
  ready_readers = IO.select($readers)[0]
  ready_readers.each do |rr|
    $work[rr].call(rr)
  end
end

## Add Callbacks
# When we're ready to read from this socket do the following. The first time we'll give one callback. Then the next time we'll do something different.