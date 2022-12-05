PACKAGE_NAME = "near-package"

input_parser = import_module("github.com/kurtosis-tech/near-package/src/package_io/input.star")
near_network = import_module("github.com/kurtosis-tech/near-package/src/near_network.star")


def run(args):
	input_args_with_defaults = input_parser.parse_input(args)
	print("Starting the " + PACKAGE_NAME + " with input " + str(input_args_with_defaults))
	output = near_network.launch_near_network(input_args_with_defaults.backend_ip_address)
	return output
