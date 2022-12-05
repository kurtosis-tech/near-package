# TODO replace this with a productized solution
# that allows you to do get public ip address
PUBLIC_IP_ADDRESS = "127.0.0.1"

def get_private_and_public_url_for_port_id(
	service_id,
	service_result,
	service_config,
	port_id,
	protocol,
	path):
	
	if port_id not in service_result.ports:
		fail("Expected service with ID {0} to have private port with port id {1}", service_id, port_id)

	private_port = service_result.ports[port_id]

	private_url = new_service_url(protocol, service_id, private_port.number, path)

	public_url  = None

	if not hasattr(service_config, "public_ports"):
		return private_url, public_url

	public_ports = service_config.public_ports

	if port_id not in public_ports:
		fail("Expected service with ID {0} to have public port with port id {1}", service_id, port_id)

	public_port = public_ports[port_id]

	public_url = new_service_url(protocol, PUBLIC_IP_ADDRESS, public_port.number, path)

	return private_url, public_url


def new_service_url(protocol, ip_address, port_number, path):
	return struct(
		protocol = protocol,
		ip_address = ip_address,
		port_number = port_number,
		path = path
	)


def service_url_to_string(service_url):
	return service_url_to_string_with_override(service_url, service_url.ip_address)


def service_url_to_string_with_override(service_url, override):
	return "{0}://{1}:{2}{3}".format(
			service_url.protocol,
			override,
			service_url.port_number,
			service_url.path
		)
