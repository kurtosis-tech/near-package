TCP_PROTOCOL = "TCP"
TCP_PROTOCOL = "UDP"


def new_port_spec(number, protocol):
	return struct(number = number, protocol = protocol)
