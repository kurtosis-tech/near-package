shared_utils = import_module("../shared_utils.star")
service_url = import_module("../service_url.star")

SERVICE_NAME = "contract-helper-dynamo-db"
IMAGE = "amazon/dynamodb-local:1.20.0"

PORT_ID = "default"
DEFAULT_PORT_NUM = 8000
DEFAULT_PORT_PROTOCOL = "TCP"
DEFAULT_PORT_SPEC = shared_utils.new_port_spec(DEFAULT_PORT_NUM, shared_utils.TCP_PROTOCOL)
ROOT_PATH = ""


def add_contract_helper_dynamo_db(plan):
	plan.print("Adding contract helper DynamoDB running on default port '" + str(DEFAULT_PORT_NUM) + "'")
	config = ServiceConfig(
		image = IMAGE,
		ports = {
			PORT_ID: DEFAULT_PORT_SPEC
		}
	)

	add_service_result = plan.add_service(SERVICE_NAME, config)

	private_url, _ = service_url.get_private_and_public_url_for_port_id(
			SERVICE_NAME,
			add_service_result,
			config,
			PORT_ID,
			DEFAULT_PORT_PROTOCOL,
			ROOT_PATH
	)

	# TODO Add productized wait for port availability

	return new_contract_helper_dynamodb_info(private_url)


def new_contract_helper_dynamodb_info(private_url):
	return struct(
		private_url = private_url
	)
