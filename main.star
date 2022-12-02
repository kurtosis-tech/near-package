PACKAGE_NAME = "near-package"

input_parser = import_module("github.com/kurtosis-tech/near-package/src/package_io/input.star")
output_creator = import_module("github.com/kurtosis-tech/near-package/src/package_io/output.star")
near_network = import_module("github.com/kurtosis-tech/near-package/src/near_network.star")


def run(args):
	input_args_with_defaults = input_parser.parse_input(args)
	print("Starting the " + PACKAGE_NAME + " with input " + str(input_args_with_defaults))
	near_network.launch_near_network(input_args_with_defaults.backend_ip_address)

	# TODO replace with actual values
	return output_creator.create_output(
		"test-network-name",
		"0x4242424242424242424242",
		"127.0.0.0:54321",
		"127.0.0.0:12345",
		"127.0.0.0:21543",
		"127.0.0.0:15432"
	)
