PACKAGE_NAME = "near-package"

input_parser = import_module("./src/package_io/input.star")
near_network = import_module("./src/near_network.star")


def run(plan, args):
	input_args_with_defaults = input_parser.parse_input(args)
	plan.print("Starting the " + PACKAGE_NAME + " with input " + str(input_args_with_defaults))
	output = near_network.launch_near_network(plan, input_args_with_defaults.backend_ip_address)
	return output
