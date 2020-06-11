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
