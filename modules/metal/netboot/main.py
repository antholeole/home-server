# implements a PXE api to spec.
# https://github.com/danderson/netboot/blob/main/pixiecore/README.api.md

from http.server import BaseHTTPRequestHandler, HTTPServer
import json

# Define the server port
PORT = 8000


class BootServerHandler(BaseHTTPRequestHandler):
    """
    This handler will process incoming GET requests.
    """

    def do_GET(self):
        parts = self.path.split("/")

        # Check if the path matches the required endpoint structure
        if len(parts) == 4 and parts[1] == "v1" and parts[2] == "boot" and parts[3]:
            mac_address = parts[3]
            self._send_boot_response(mac_address)
        else:
            self._send_404()

    def _send_404(self):
        """
        Sends a 404 Not Found response.
        """
        self.send_response(404)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        
        response_data = {"error": "Not Found", "path": self.path}
        _ = self.wfile.write(json.dumps(response_data).encode('utf-8'))
    

    def _send_boot_response(self, mac_address: str):
        """
        Sends a 200 OK response with mock boot data.
        """
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()

        response_data = {
            "status": "success",
            "mac_address": mac_address,
            "boot_config": {
                "kernel": "vmlinuz-default",
                "initrd": "initramfs-default.img",
                "cmdline": "root=/dev/sda1 console=ttyS0",
            },
        }

        # Write the JSON data to the response
        _ = self.wfile.write(json.dumps(response_data).encode("utf-8"))


def run_server(port: int = PORT):
    """
    Starts and runs the HTTP server.
    """
    server_address = ("", port)  
    httpd = HTTPServer(server_address, BootServerHandler)

    print(f"Starting simple boot server on http://localhost:{port}...")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping server...")
        httpd.server_close()


if __name__ == "__main__":
    run_server()
