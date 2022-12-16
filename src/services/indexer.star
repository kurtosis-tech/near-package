shared_utils = import_module("github.com/kurtosis-tech/near-package/src/shared_utils.star")
constants = import_module("github.com/kurtosis-tech/near-package/src/constants.star")
service_url = import_module("github.com/kurtosis-tech/near-package/src/service_url.star")

SERVICE_ID = "indexer-node"
IMAGE = "kurtosistech/near-indexer-for-explorer:2d66461"
RPC_PRIVATE_PORT_NUM = 3030
RPC_PUBLIC_PORT_NUM = 8332
RPC_PORT_ID = "rpc"
RPC_PRIVATE_PORT_SPEC = shared_utils.new_port_spec(RPC_PRIVATE_PORT_NUM, shared_utils.TCP_PROTOCOL, shared_utils.HTTP_APPLICATION_PROTOCOL)
RPC_PUBLIC_PORT_SPEC = shared_utils.new_port_spec(RPC_PUBLIC_PORT_NUM, shared_utils.TCP_PROTOCOL)
RPC_PORT_PROTOCOL = "http"
GOSSIP_PRIVATE_PORT_NUM = 24567
GOSSIP_PUBLIC_PORT_NUM = 8333
GOSSIP_PORT_ID = "gossip"
GOSSIP_PRIVATE_PORT_SPEC = shared_utils.new_port_spec(GOSSIP_PRIVATE_PORT_NUM, shared_utils.TCP_PROTOCOL)
GOSSIP_PUBLIC_PORT_SPEC = shared_utils.new_port_spec(GOSSIP_PUBLIC_PORT_NUM, shared_utils.TCP_PROTOCOL)
ROOT_PATH = ""

LOCALNET_CONFIG_DIRPATH_ON_PACKAGE = "github.com/kurtosis-tech/near-package/static_files/near-configs/localnet"
NEAR_CONFIGS_DIRPATH_ON_INDEXER_CONTAINER = "/root/.near"

DATABASE_URL_ENVVAR = "DATABASE_URL"

VALIDATOR_KEY_FILEPATH = "/root/.near/validator_key.json"
GET_VALIDATOR_KEY_CMD = [
    "cat",
    VALIDATOR_KEY_FILEPATH
]

TIME_TO_SLEEP_FOR_VALIDATOR_KEYS = ["sleep", "10"]


def add_indexer(db_private_url, db_username, db_password, db_name):
	print("Adding indexer service...")
	
	upload_artifact_uuid = upload_files(LOCALNET_CONFIG_DIRPATH_ON_PACKAGE)
	private_ports = {
		RPC_PORT_ID: RPC_PRIVATE_PORT_SPEC,
		GOSSIP_PORT_ID: GOSSIP_PRIVATE_PORT_SPEC
	}

	public_ports = {
		RPC_PORT_ID: RPC_PUBLIC_PORT_SPEC,
		GOSSIP_PORT_ID: GOSSIP_PUBLIC_PORT_SPEC		
	}

	env_vars = {
		DATABASE_URL_ENVVAR: "postgres://{0}:{1}@{2}:{3}/{4}".format(
				db_username,
				db_password,
				db_private_url.ip_address,
				db_private_url.port_number,
				db_name
			)
	}

	command_to_run = './diesel migration run && ./indexer-explorer --home-dir "{0}" run --store-genesis sync-from-latest'.format(NEAR_CONFIGS_DIRPATH_ON_INDEXER_CONTAINER)

	files = {
		NEAR_CONFIGS_DIRPATH_ON_INDEXER_CONTAINER: upload_artifact_uuid
	}

	config = struct(
		image = IMAGE,
		env_vars = env_vars,
		entrypoint = ["sh", "-c"],
		cmd = [command_to_run],
		ports = private_ports,
		public_ports = public_ports,
		files = files
	)

	add_service_result = add_service(SERVICE_ID, config)

	# TODO Replace this with an exec that takes waits
	exec(SERVICE_ID, TIME_TO_SLEEP_FOR_VALIDATOR_KEYS)
	# TODO add code to get output from the command below
	exec(SERVICE_ID, GET_VALIDATOR_KEY_CMD)

	# TODO Replace this with solution that reads this from exec instead
	validator_key_json = read_file(LOCALNET_CONFIG_DIRPATH_ON_PACKAGE + "/validator_key.json")
	validator_key = json.decode(validator_key_json)

	private_rpc_url, public_rpc_url = service_url.get_private_and_public_url_for_port_id(
		SERVICE_ID,
		add_service_result,
		config,
		RPC_PORT_ID,
		RPC_PORT_PROTOCOL,
		ROOT_PATH
	)

	result = new_indexer_info(private_rpc_url, public_rpc_url, validator_key)


	# TODO add a wait for availability for the RPC_PRIVATE_PORT_NUM
	# Note - its broken on old repo as well

	return result


def new_indexer_info(private_rpc_url, public_rpc_url, validator_key):
	return struct(
		private_rpc_url = private_rpc_url,
		public_rpc_url = public_rpc_url,
		validator_key = validator_key
	)
