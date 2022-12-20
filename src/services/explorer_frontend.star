shared_utils = import_module("github.com/kurtosis-tech/near-package/src/shared_utils.star")
constants = import_module("github.com/kurtosis-tech/near-package/src/constants.star")
service_url = import_module("github.com/kurtosis-tech/near-package/src/service_url.star")
wallet = import_module("github.com/kurtosis-tech/near-package/src/services/wallet.star")


SERVICE_ID = "explorer-frontend"
PORT_ID = "http"
PORT_PROTOCOL = "http"
IMAGE= "kurtosistech/near-explorer_frontend:836d8d7"
PRIVATE_PORT_NUM = 3000
PUBLIC_PORT_NUM = 8331
PRIVATE_PORT_SPEC = shared_utils.new_port_spec(PRIVATE_PORT_NUM, shared_utils.TCP_PROTOCOL, shared_utils.HTTP_APPLICATION_PROTOCOL)
PUBLIC_PORT_SPEC = shared_utils.new_port_spec(PUBLIC_PORT_NUM, shared_utils.TCP_PROTOCOL)
ROOT_PATH = ""


def add_explorer_frontend_service(
	plan,
	user_requested_backend_ip_address,
	# The IP address to use for connecting to the backend services
	explorer_backend_private_url,
	explorer_backend_public_url):

	plan.print("Adding explorer frontend service running on port '{0}'".format(PRIVATE_PORT_NUM))

	used_ports = {
		PORT_ID : PRIVATE_PORT_SPEC
	}

	public_ports = {
		PORT_ID: PUBLIC_PORT_SPEC
	}

	backend_private_ip = explorer_backend_private_url.ip_address

	# There's a circular dependency between the Explorer Frontend and the Wallet, where
	# the Wallet wants to display a link to the Explorer and the Wallet wants to display a link to the Explorer
	# Frontend. To break this cycle, we have the Wallet start on a static public port and the Explorer show
	# a link to the Wallet using that static public port before the Wallet has started (and the Wallet will be
	# started afterwards). This code here is for creating the link to the Wallet before the Wallet has started.
	wallet_public_url = "http://{0}:{1}".format(user_requested_backend_ip_address, wallet.PUBLIC_PORT_NUM)
	# instead of using a dictionary & then json.encode it, this is done this way as its done the same way
	# in the near-kurtosis-module, it looks like the UI picks the first item on list as the main one instead of localnet
	# if i json.encode a dict then guildnet goes on top and this looks different from mainnet
	# TODO convert this to json.encode if the ordering isn't a problem
	networks_config_json = '''{
		"mainnet": {
			"explorerLink": "https://explorer.near.org/",
			"aliases": ["explorer.near.org", "explorer.mainnet.near.org", "explorer.nearprotocol.com", "explorer.mainnet.nearprotocol.com"],
			"nearWalletProfilePrefix": "https://wallet.near.org/profile"
		},
		"testnet": {
			"explorerLink": "https://explorer.testnet.near.org/",
			"aliases": ["explorer.testnet.near.org", "explorer.testnet.nearprotocol.com"],
			"nearWalletProfilePrefix": "https://wallet.testnet.near.org/profile"
		},
		"guildnet": {
			"explorerLink": "https://explorer.guildnet.near.org/",
			"aliases": ["explorer.guildnet.near.org"],
			"nearWalletProfilePrefix": "https://wallet.openshards.io/profile"
		},
		"localnet": {
			"explorerLink": "''' + service_url.service_url_to_string_with_override(explorer_backend_public_url,user_requested_backend_ip_address)+ '''",
			"aliases": [],
			"nearWalletProfilePrefix": "''' + wallet_public_url + '''/profile"
		}
	}'''

	env_vars = {
		# TODO MAKE THIS MATCH BACKEND???

		# from https://github.com/near/near-explorer/blob/b29f5830e431f3198ed409643d8930580806d1e4/frontend.env#L1
		"NEAR_EXPLORER_CONFIG__SEGMENT_WRITE_KEY": "7s4Na9mAfC7092R6pxrwpfBIAEek9Dne",
		"NEAR_EXPLORER_CONFIG__NETWORK_NAME": "localnet",
		"NEAR_EXPLORER_CONFIG__NETWORKS": networks_config_json,

		"PORT": str(PRIVATE_PORT_NUM),

		"NEAR_EXPLORER_CONFIG__BACKEND_SSR__HOSTS__MAINNET": backend_private_ip,
		"NEAR_EXPLORER_CONFIG__BACKEND_SSR__HOSTS__TESTNET": backend_private_ip,
		"NEAR_EXPLORER_CONFIG__BACKEND_SSR__HOSTS__GUILDNET": backend_private_ip,
		"NEAR_EXPLORER_CONFIG__BACKEND_SSR__PORT": str(explorer_backend_private_url.port_number),
		"NEAR_EXPLORER_CONFIG__BACKEND_SSR__SECURE": "false",

		"NEAR_EXPLORER_CONFIG__BACKEND__HOSTS__MAINNET": user_requested_backend_ip_address,
		"NEAR_EXPLORER_CONFIG__BACKEND__HOSTS__TESTNET": user_requested_backend_ip_address,
		"NEAR_EXPLORER_CONFIG__BACKEND__HOSTS__GUILDNET": user_requested_backend_ip_address,
		"NEAR_EXPLORER_CONFIG__BACKEND__PORT": str(explorer_backend_public_url.port_number),
		"NEAR_EXPLORER_CONFIG__BACKEND__SECURE": "false",
	}

	config = struct(
		image = IMAGE,
		ports = used_ports,
		public_ports  = public_ports,
		env_vars = env_vars
	)

	
	add_service_result = plan.add_service(SERVICE_ID, config)

	# TODO add a productized way to wait for port availability
	# Note this is broken on the old module as well

	private_url, public_url = service_url.get_private_and_public_url_for_port_id(
		SERVICE_ID,
		add_service_result,
		config,
		PORT_ID,
		PORT_PROTOCOL,
		ROOT_PATH
	)

	return new_explorer_frontend_info(public_url)


def new_explorer_frontend_info(public_url):
	return struct(public_url = public_url)
