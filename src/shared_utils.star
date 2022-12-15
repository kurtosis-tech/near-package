TCP_PROTOCOL = "TCP"
OPTIONAL_APPLICATION_PROTOCOL=""
HTTP_APPLICATION_PROTOCOL = "http"
def new_port_spec(number, transport_protocol, application_protocol=OPTIONAL_APPLICATION_PROTOCOL):
	return PortSpec(number= number, transport_protocol= transport_protocol, application_protocol= application_protocol)
