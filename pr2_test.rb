require 'socket' # Provides TCPServer and TCPSocket classes

if ARGV.length == 0
  puts "USAGE"
  puts "to start a simple single threaded http server"
  puts "ruby prj2_test.rb server"
  puts "to start a simple threaded http server"
  puts "ruby prj2_test.rb threaded"
  puts "to start a simple two simultaneous client test"
  puts "ruby prj2_test.rb IP_OR_HOSTNAME"
  exit
end


def handleRequest( socket, i )
	# Read the first line of the request (the Request-Line)
	request = socket.gets

	# Log the request to the console for debugging
	STDERR.puts request

	puts "About to read"
	#Simulate a read of the rest of the http request
	socket.read

	response = "Hello World!\n" + i.to_s

	# We need to include the Content-Type and Content-Length headers
	# to let the client know the size and type of data
	# contained in the response. Note that HTTP is whitespace
	# sensitive, and expects each header line to end with CRLF (i.e. "\r\n")
	socket.print "HTTP/1.1 200 OK\r\n" +
		"Content-Type: text/plain\r\n" +
		"Content-Length: #{response.bytesize}\r\n" +
	"Connection: close\r\n"

	# Print a blank line to separate the header from the response body,
	# as required by the protocol.
	socket.print "\r\n"

	# Print the actual response body, which is just "Hello World!\n"
	socket.print response

	# Close the socket, terminating the connection
	socket.close
	puts "closed the " + request + " socket"
end


if ARGV.length > 0
	if ARGV[0] == "server"
		# Initialize a TCPServer object that will listen
		# on localhost:2345 for incoming connections.
		server = TCPServer.new('localhost', 9020)
		i = 0
		# loop infinitely, processing one incoming
		# connection at a time.
		loop do
			# Wait until a client connects, then return a TCPSocket
			# that can be used in a similar fashion to other Ruby
			# I/O objects. (In fact, TCPSocket is a subclass of IO.)
			socket = server.accept

			handleRequest( socket, i )
			i += 1
		end
	end
	if ARGV[0] == "threaded"
		# Initialize a TCPServer object that will listen
		# on localhost:2345 for incoming connections.
		server = TCPServer.new('localhost', 9020)
		i = 0
		# loop infinitely, processing one incoming
		# connection at a time.
		loop do
			# Wait until a client connects, then return a TCPSocket
			# that can be used in a similar fashion to other Ruby
			# I/O objects. (In fact, TCPSocket is a subclass of IO.)
			socket = server.accept
			i += 1

			Thread.start( socket, i - 1 ) do |socket, ii|
					handleRequest( socket,  ii )
				begin
				rescue Exception => e
					socket.close
					Thread.main.raise e
				end
			end
		end
	end
	host = ARGV[0]
	#start client 1 request
	s = TCPSocket::new(host, 9020) 
	s.write("GET /index1.html HTTP/1.0\r\n")

	#start and complete client 2 reuqest
	s2 = TCPSocket::new(host, 9020) 
	s2.write("GET /index2.html HTTP/1.0\r\n")
	s2.write("\r\n")
	s2.flush
	s2.close_write
	puts "Reponse from socket 2"
	puts s2.read

	#finish client 1 request
	s.write("\r\n")
	s2.flush
	s.close_write
	puts "Reponse from socket 1"
	puts s.read
else
end
