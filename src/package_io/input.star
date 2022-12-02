DEFAULT_BACKEND_IP_ADDRESS = "127.0.0.1"

def parse_input(input_args):
	default_args = struct(
		backend_ip_address = DEFAULT_BACKEND_IP_ADDRESS
	)
	if not hasattr(input_args, "backend_ip_address"):
		return default_args

	if type(input_args.backend_ip_address) != str:
		fail("backend_ip_address has to be of type string")

	if input_args.backend_ip_address.strip() == "":
		fail("backend_ip_address cannot be empty")

	return input_args
