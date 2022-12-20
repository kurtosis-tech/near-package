shared_utils = import_module("github.com/kurtosis-tech/near-package/src/shared_utils.star")
constants = import_module("github.com/kurtosis-tech/near-package/src/constants.star")
service_url = import_module("github.com/kurtosis-tech/near-package/src/service_url.star")


SERVICE_ID = "wallet"
IMAGE = "kurtosistech/near-wallet:169ccfb61"
PORT_ID = "http"
PORT_PROTOCOL = "http"
PRIVATE_PORT_NUM = 3004
# TODO This is a hack! There's a circular dependency between the Explorer Frontend and the Wallet, where
# the Wallet wants to display a link to the Explorer and the Wallet wants to display a link to the Explorer
# Frontend. To break this cycle, we have the Wallet start on a static public port and the Explorer show
# a link to the Wallet using that static public port before the Wallet has started (and the Wallet will be
# started afterwards). This is why we expose this constant.
PUBLIC_PORT_NUM = 8334
PRIVATE_PORT_SPEC = shared_utils.new_port_spec(PRIVATE_PORT_NUM, shared_utils.TCP_PROTOCOL, shared_utils.HTTP_APPLICATION_PROTOCOL)
PUBLIC_PORT_SPEC = shared_utils.new_port_spec(PUBLIC_PORT_NUM, shared_utils.TCP_PROTOCOL)
ROOT_PATH = ""

# These variable names come from https://github.com/near/near-wallet/blob/master/packages/frontend/src/config.js
CONTRACT_HELPER_JS_VAR = "ACCOUNT_HELPER_URL"
EXPLORER_URL_JS_VAR = "EXPLORER_URL"
NODE_URL_JS_VAR = "NODE_URL"
STATIC_JS_VARS = {
    "NETWORK_ID": "localnet",
    # TODO make this dynamic, from the validator key that comes back from indexer node startup
    "ACCOUNT_ID_SUFFIX": "test.near",
    "ACCESS_KEY_FUNDING_AMOUNT": "3000000000000000000000000", # TODO(old) is this right???
}


# The glob that identifies the Parcel-bundled JS file containing the Wallet code, which we'll
#  modify to insert the environment variables we want
WALLET_JS_FILE_GLOB = "/var/www/html/wallet/src*js"

# From the Wallet Dockerfile
# We override this so that we can insert our desired envvars into the Wallet's source Javascript file
ORIGINAL_WALLET_ENTRYPOINT_COMMAND = "/sbin/my_init --"

# sed delimiter that we'll use when sed-ing the Wallet JS file, and which the JS variables cannot contain
JS_REPLACEMENT_SED_DELIMITER = "$"


def add_wallet(
	plan,
    user_requested_backend_ip_address,
    near_node_public_rpc_url,
    contract_helper_public_url,
    explorer_public_url):
	
	plan.print("Adding wallet service running on port '{0}".format(PRIVATE_PORT_NUM))

	used_ports = {
		PORT_ID: PRIVATE_PORT_SPEC
	}

	public_ports = {
		PORT_ID: PUBLIC_PORT_SPEC
	}

	js_vars = {
		NODE_URL_JS_VAR: service_url.service_url_to_string_with_override(near_node_public_rpc_url, user_requested_backend_ip_address),
		CONTRACT_HELPER_JS_VAR: service_url.service_url_to_string_with_override(contract_helper_public_url, user_requested_backend_ip_address),
		EXPLORER_URL_JS_VAR: service_url.service_url_to_string_with_override(explorer_public_url, user_requested_backend_ip_address),
	}

	for key, value in STATIC_JS_VARS.items():
		js_vars[key] = value

	commands_to_run = generate_js_src_updating_commands(plan, js_vars)
	commands_to_run.append(ORIGINAL_WALLET_ENTRYPOINT_COMMAND)

	single_command_to_run = " && ".join(commands_to_run)

	config = struct(
		image = IMAGE,
		ports = used_ports,
		public_ports = public_ports,
		entrypoint = ["sh", "-c"],
		cmd = [single_command_to_run],
	)

	add_service_result = plan.add_service(SERVICE_ID, config)

	# TODO add a productized wait for availability for PORT_ID
	# Note, doesn't work in old repo either

	_, public_url = service_url.get_private_and_public_url_for_port_id(
		SERVICE_ID,
		add_service_result,
		config,
		PORT_ID,
		PORT_PROTOCOL,
		ROOT_PATH
	)

	return new_wallet_info(public_url)


def generate_js_src_updating_commands(plan, js_vars):
	verify_envvar_exitence_func_name = "verify_envvar_existence"
	declare_envvar_existence_func_str = verify_envvar_exitence_func_name+' () { if ! grep "${1}" ' + WALLET_JS_FILE_GLOB + '; then echo "Wallet source JS file is missing expected environment variable \'${1}\'"; return 1; fi; }'
	command_fragments = [declare_envvar_existence_func_str]
	for key, value in js_vars.items():
		if JS_REPLACEMENT_SED_DELIMITER in key:
			fail("the key {0} contains {1}, this isn't valid", key, JS_REPLACEMENT_SED_DELIMITER)
		if JS_REPLACEMENT_SED_DELIMITER in value:
			fail("the value {0} contains {1}, this isn't valid", value, JS_REPLACEMENT_SED_DELIMITER)

		verify_envvar_existence_command = '{0} "{1}"'.format(verify_envvar_exitence_func_name, key)
		command_fragments.append(verify_envvar_existence_command)

		src_regex = "([,{])"+key+":[^,]*([,}])"
		replacement_regexp = '\\1{0}:"{1}"\\2'.format(key, value)

		plan.print("Replacing variable '{0}' to '{1}' using regexp: '{2}'".format(key, value, src_regex))
		update_js_file_command = "sed -i -E 's{0}{1}{2}{3}{4}g' {5}".format(
			JS_REPLACEMENT_SED_DELIMITER,
			src_regex,
			JS_REPLACEMENT_SED_DELIMITER,
			replacement_regexp,
			JS_REPLACEMENT_SED_DELIMITER,
			WALLET_JS_FILE_GLOB	
		)
		command_fragments.append(update_js_file_command)
	return command_fragments



def new_wallet_info(public_url):
	return struct(public_url = public_url)
