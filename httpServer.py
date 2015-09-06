from http.server import SimpleHTTPRequestHandler, HTTPServer,BaseHTTPRequestHandler
import urllib
import socketserver


def main():
	PORT = 9020
	try:
		server = ThreadingUDPServer(("", PORT), Handler)
		print('starting server')
		server.serve_forever()
	except KeyboardInterrupt:
		server.socket.close()
		
class ThreadingUDPServer(socketserver.ThreadingMixIn, socketserver.TCPServer): 
	pass
		
chatlines = []		
class Handler(SimpleHTTPRequestHandler):
	def do_GET(self):
		
		print(self.path)
		if self.path == '/HISTORY':
			self.send_list()
			return None
			
			
		if self.path.startswith('/CHAT'):
			addr = urllib.parse.urlparse(self.path)
			print(addr)
			#line = urllib.parse.query('time')
			splited = addr.query.split('&')
			nacomp = splited[0].split('=')
			licomp = splited[1].split('=')
			if len(nacomp) < 2 or len(licomp) < 2:
				return
			
			name = nacomp[1]
			line = licomp[1]
			print(name)
			print(line)
			chatlines.append(name+' '+line)
			strlines = ''
			
			self.send_list()
			return None
			
		
			
		
		return super().do_GET()
	
	def send_list(self):
		strlines = ''
		
		for ln in chatlines:
			print(ln+'\n')
			strlines += '<div>'+ln +'\n</div>'
		self.wfile.write(strlines.encode("UTF-8"))
		return None
	
main()