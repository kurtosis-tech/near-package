contract_helper_postgresql = import_module("./services/contract_helper_postgresql.star")
contract_helper_dynamodb = import_module("./services/contract_helper_dynamodb.star")
indexer = import_module("./services/indexer.star")
contract_helper = import_module("./services/contract_helper.star")
explorer_backend = import_module("./services/explorer_backend.star")
explorer_frontend = import_module("./services/explorer_frontend.star")
wallet = import_module("./services/wallet.star")
output_creator = import_module("./package_io/output.star")
service_url = import_module("./service_url.star")


EXPLORER_WAMP_BACKEND_FRONTEND_SHARED_NETWORK_NAME = "localnet"


def launch_near_network(plan, backend_ip_address):
	plan.print("Launching contract helper postgresql")
	contract_helper_db_info = contract_helper_postgresql.add_contract_helper_db(plan)
	plan.print("Contract helper postgresql db info {0}".format(contract_helper_db_info))

	plan.print("Launching contract helper dynamo db")
	contract_helper_dynamodb_info = contract_helper_dynamodb.add_contract_helper_dynamo_db(plan)
	plan.print("Contract helper dynamodb info {0}".format(contract_helper_dynamodb_info))

	plan.print("Launching indexer")
	indexer_info = indexer.add_indexer(
		plan,
		contract_helper_db_info.private_url,
		contract_helper_db_info.db_username,
		contract_helper_db_info.db_user_password,
		contract_helper_db_info.indexer_db
	)
	plan.print("Indexer launched with " + str(indexer_info))

	plan.print("Launching contract helper")
	contract_helper_service_info = contract_helper.add_contract_helper_service(
		plan,
		contract_helper_db_info.private_url,
		contract_helper_db_info.db_username,
		contract_helper_db_info.db_user_password,
		contract_helper_db_info.indexer_db,
		contract_helper_dynamodb_info.private_url,
		indexer_info.private_rpc_url,
		indexer_info.validator_key,
	)
	plan.print("Contract helper launchded with {0}".format(contract_helper_service_info))

	plan.print("Launching explorer backend")
	explorer_backend_info = explorer_backend.add_explorer_backend_service(
		plan,
		indexer_info.private_rpc_url,
		contract_helper_db_info.private_url,
		contract_helper_db_info.db_username,
		contract_helper_db_info.db_user_password,
		contract_helper_db_info.indexer_db,
		contract_helper_db_info.analytics_db,
		contract_helper_db_info.telemetry_db,
	)
	plan.print("Explorer backend launchded with {0}".format(explorer_backend_info))

	plan.print("Launching explorer frontend")
	explorer_frontend_info = explorer_frontend.add_explorer_frontend_service(
		plan,
		backend_ip_address,
		explorer_backend_info.private_url,
		explorer_backend_info.public_url,
	)
	plan.print("Explorer frontend launchded with {0}".format(explorer_frontend_info))

	plan.print("Launching wallet")
	wallet_info = wallet.add_wallet(
		plan,
		backend_ip_address,
		indexer_info.public_rpc_url,
		contract_helper_service_info.public_url,
		explorer_frontend_info.public_url,
	)
	plan.print("Explorer wallet {0}".format(wallet_info))

	return output_creator.create_output(
		EXPLORER_WAMP_BACKEND_FRONTEND_SHARED_NETWORK_NAME,
		indexer_info.validator_key,
		service_url.service_url_to_string(indexer_info.public_rpc_url),
		service_url.service_url_to_string(contract_helper_service_info.public_url),
		service_url.service_url_to_string(wallet_info.public_url),
		service_url.service_url_to_string(explorer_frontend_info.public_url),
	)
