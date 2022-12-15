shared_utils = import_module("github.com/kurtosis-tech/near-package/src/shared_utils.star")
constants = import_module("github.com/kurtosis-tech/near-package/src/constants.star")
service_url = import_module("github.com/kurtosis-tech/near-package/src/service_url.star")


SERVICE_ID = "contract-helper-service"
PORT_ID = "rest"
PRIVATE_PORT_NUM = 3000
PUBLIC_PORT_NUM = 8330
PRIVATE_PORT_SPEC = shared_utils.new_port_spec(PRIVATE_PORT_NUM, shared_utils.TCP_PROTOCOL, shared_utils.HTTP_APPLICATION_PROTOCOL)
PUBLIC_PORT_SPEC = shared_utils.new_port_spec(PUBLIC_PORT_NUM, shared_utils.TCP_PROTOCOL)
PORT_PROTOCOL = "http"
IMAGE = "kurtosistech/near-contract-helper:88585e9"

ACCOUNT_CREATOR_KEY_ENVVAR = "ACCOUNT_CREATOR_KEY"
INDEXER_DB_CONNECTION_ENVVAR = "INDEXER_DB_CONNECTION"
NODE_RPC_URL_ENVVAR  = "NODE_URL"
DYNAMO_DB_URL_ENVVAR = "LOCAL_DYNAMODB_HOST"
DYNAMO_DB_PORT_ENVVAR = "LOCAL_DYNAMODB_PORT"
ROOT_PATH = ""

# See https://github.com/near/near-contract-helper/blob/master/.env.sample for where these are drawn from
STATIC_ENVVARS = {
	#ACCOUNT_CREATOR_KEY will be set dynamically 
	"MAIL_HOST": "smtp.ethereal.email",
	"MAIL_PASSWORD": "",
	"MAIL_PORT": "587",
	"MAIL_USER": "",
	"NEW_ACCOUNT_AMOUNT": "10000000000000000000000000",

	"NODE_ENV": "development", # Node.js environment; either `development` or `production`
	# I changed this value because now valid values are "testnet and mainnet"
	"NEAR_WALLET_ENV": "testnet", # Matches the value set when the Wallet image was built

	"PORT": str(PRIVATE_PORT_NUM), # Used internally by the contract helper; does not have to correspond to the external IP or DNS name and can link to a host machine running the Docker container

	"USE_MOCK_TWILIO": "true",
	"TWILIO_ACCOUNT_SID": "", # account SID from Twilio (used to send security code)
	"TWILIO_AUTH_TOKEN": "", # auth token from Twilio (used to send security code)
	"TWILIO_FROM_PHONE": "+14086179592", # phone number from which to send SMS with security code (international format, starting with `+`)

	# NOTE: We can't set this because there's a circular dependency between Wallet and Contract Helper app, where
	#  they both need to point to each others' _publicly-facing ports_ (which are only available after starting the container)
	# Following the lead of https://github.com/near/local/blob/master/docker-compose.yml, we're choosing to break Contract Helper app
	"WALLET_URL": "",

	# INDEXER_DB_CONNECTION will get set dynamically

	# See https://github.com/near/near-contract-helper/issues/533 for an explanation of why this is empty
	# "FUNDED_ACCOUNT_CREATOR_KEY": "{}",
	"FUNDED_ACCOUNT_CREATOR_KEY": "",
	# "ACCOUNT_CREATOR_KEYS":'{"private_keys":[]}',
	"ACCOUNT_CREATOR_KEYS":"",

	"NEARPAY_SECRET_KEY":"your_secret_key",

	# Needed for local DynamoDB, dummy values are fine as local DynamoDB accepts everything
	"AWS_REGION": "us-west-2",
	"AWS_ACCESS_KEY_ID": "NOT_USED_BUT_NEEDED",
	"AWS_SECRET_ACCESS_KEY": "NOT_USED_BUT_NEEDED",
}

VALIDATOR_KEY_PRETTY_PRINT_NUM_SPACES = 2


def add_contract_helper_service(
	db_private_url,
	db_username,
	db_user_password,
	db_name,
	dynamo_db_private_url,
	near_node_private_rpc_url,
	validator_key):

	print("Adding contract helper service running on port '{0}'".format(PRIVATE_PORT_NUM))

	used_ports = {
		PORT_ID: PRIVATE_PORT_SPEC
	}

	public_ports = {
		PORT_ID: PUBLIC_PORT_SPEC
	}


	validator_key_str = json.encode(validator_key)

	env_vars = {
		ACCOUNT_CREATOR_KEY_ENVVAR: validator_key_str,
		INDEXER_DB_CONNECTION_ENVVAR: 'postgres://${0}:${1}@${2}:${3}/${4}'.format(
			db_username,
			db_user_password,
			db_private_url.ip_address,
			db_private_url.port_number,
			db_name
		),
		NODE_RPC_URL_ENVVAR: service_url.service_url_to_string(near_node_private_rpc_url),
		DYNAMO_DB_URL_ENVVAR: dynamo_db_private_url.ip_address,
		DYNAMO_DB_PORT_ENVVAR: str(dynamo_db_private_url.port_number),
	}

	for key, value in STATIC_ENVVARS.items():
		env_vars[key] = value

	config = struct(
		image = IMAGE,
		ports = used_ports,
		public_ports = public_ports,
		cmd = [
			"sh",
			"-c",
			# We need to override the CMD because the Dockerfile (https://github.com/near/near-contract-helper/blob/master/Dockerfile.app)
			# loads hardcoded environment variables that we don't want
			"sleep 10 && node scripts/create-dynamodb-tables.js && yarn start-no-env",
		],
		env_vars = env_vars
	)

	add_service_result = add_service(SERVICE_ID, config)

	# TODO add productized wait for port vailability
	# also missing on old repo

	private_url, public_url = service_url.get_private_and_public_url_for_port_id(
		SERVICE_ID,
		add_service_result,
		config,
		PORT_ID,
		PORT_PROTOCOL,
		ROOT_PATH
	)

	return new_contract_helper_service_info(private_url, public_url)


def new_contract_helper_service_info(private_url, public_url):
	return struct(
		private_url = private_url,
		public_url = public_url
	)


