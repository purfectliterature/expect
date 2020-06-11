#
#    Copyright 2020 Phillmont Muktar
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

import os
import sys
import ssl
import http.server
import socketserver

ARGS = sys.argv

HOST = ARGS[1]
PORT = int(ARGS[2])
VERSION = "0.1.19"
CERT_FILE = "cert.pem"
KEY_FILE = "key_unencrypted.pem"

def main():
    print(f"Experse version {VERSION}")
    print()
    
    Handler = http.server.SimpleHTTPRequestHandler
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        httpd.socket = ssl.wrap_socket(httpd.socket, certfile=CERT_FILE, keyfile=KEY_FILE, server_side=True)
        print(f"Serving local Expo deploy server at https://{HOST}:{str(PORT)} from {os.getcwd()}")
        httpd.serve_forever()
    
if (__name__ == "__main__"):
    try:
        main()
    except Exception as ex:
        print(ex)
    finally:
        input()
