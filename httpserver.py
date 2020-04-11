#!/usr/bin/env python

import sys
import urllib.parse
# if sys.version_info >= (3, 0):
from http.server import BaseHTTPRequestHandler, HTTPServer
# else:
#     from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServe


class RequestHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain; charset=UTF-8")
        self.end_headers()
        parsed_path = urllib.parse.urlparse(self.path)
        #parsed_path = self.path
        path = parsed_path.path
        message = path
        # message = '\r\n'.join(self.path)
        self.wfile.write(message.encode())
        return



if __name__ == '__main__':
    port = 8080
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    server = HTTPServer(('', port), RequestHandler)
    server.serve_forever()
