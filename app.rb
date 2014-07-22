# Watch a synchronous server in ruby.
# Get some input from the client and then echo it back out.
# It is lower level TCP instead of def HTTP
# Allows bidirectional communication.
# HTTP is more limited because the user can send data in the request phase
# and then the server can respond. HTTP hides bidirectionality.

#Built in ruby library
# Somethign like this underlies every web server written in ruby
require 'socket'
require 'thread'

server = TCPServer.new(3000)


#Multithreaded server.
#New thread for every connection which can be kind of slow and also difficult because they can interact with each other.
hi = false
while (hi == true)
  # This call will wait for a connection to come in.
  #server.accept will return a server object, better known as a socket (TCP connection)
  socket = server.accept

Thread.new do # A simple solution to our problem that will allow us to run simultaneous lines of code. Main thread can loop around to accept the second connection.
  socket.puts("connected")
  input = socket.gets #stuck here.
  sleep(2)
  socket.puts(input)
  sleep(2)
  #At the end we'll close the socket, telling the client our session is done.
  socket.puts("closing now")
  socket.close
end
  # Net cat won't close without socket.close
end

# As it is now we can't accept a second connection.
# When it tried to get data it immediately grabbed the data. concurrency problem.
$counter = 0
$threads = []
$mutex = Mutex.new
100.times do |i|
  $threads << Thread.new do
    1000.times do
      $mutex.synchronize do
      #Multiple threads have tried to increment counter but they both set it to 1. Uncoordinated setting of counter.
        new_val = $counter + 1
        sleep(0.00001)
        $counter = new_val
      end
    end
  end
end

#Thread.join won't make us do it in order but the each loop won't iterate through until the one before it is done.
$threads.each do |thread|
  thread.join
end

puts($counter)

#TO fix this ruby gives us an object called a mutex.
#Mutex prevents 2 threads from entering its block simultaneously. It doesn't guarentee order because whoever is there first will take over. But at least it won't change the coutner between the time when you reset the counter and changes happen to it.

# If there is any global state then we have to be careful about coordinating access to the state. Classes can be thread safe or thread unsafe.

# Thread-safe : Clall methods from different threads and not worry about race conditions
# Thread-unsafe: Calling methods from different threads may corrupt other