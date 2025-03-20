import socket

def get_ip_address():
    '''
    gets the ip address of the node; this is most likely the private ip
    address of the device.
    '''
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80)) # this doesn't matter
    return s.getsockname()[0]


if __name__ == "__main__":
    print(get_ip_address())
