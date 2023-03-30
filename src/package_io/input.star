DEFAULT_BACKEND_IP_ADDRESS = "127.0.0.1"

def parse_input(input_args):
	default_args = struct(
		backend_ip_address = DEFAULT_BACKEND_IP_ADDRESS
	)
	if not "backend_ip_address" in input_args:
		return default_args

	if type(input_args["backend_ip_address"]) != "string":
		fail("backend_ip_address has to be of type string got {0}".format(type(input_args.backend_ip_address)))

	if input_args["backend_ip_address"].strip() == "":
		fail("backend_ip_address cannot be empty")

	return struct(backend_ip_address = input_args["backend_ip_address"])
