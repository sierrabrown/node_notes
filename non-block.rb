# An alternative to threadbased appraoch from the concurrent connection problem.
# Same problem - gets waits so only one user at a time

require 'socket'

$server = TCPServer.new(3000)
$readers = [$server]


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

while true
  #Readers are things that are ready to be read
  # IO::select is fucking black magic
  # IO select is the only time we're waiting. It processes FIFO style and doesn't wait on any particular reader. NON BLOCKING IO
  ready_readers = IO.select($readers)[0]
  process_ready_readers(ready_readers)
end