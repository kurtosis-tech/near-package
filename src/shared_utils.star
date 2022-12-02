TCP_PROTOCOL = "TCP"


def new_port_spec(number, protocol):
	return struct(number = number, protocol = protocol)
