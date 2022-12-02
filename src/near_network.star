EXPLORER_WAMP_BACKEND_FRONTEND_SHARED_NETWORK_NAME = "localnet"

contract_helper_postgresql = import_module("github.com/kurtosis-tech/near-package/src/services/contract_helper_postgresql.star")
contract_helper_dynamodb = import_module("github.com/kurtosis-tech/near-package/src/services/contract_helper_dynamodb.star")
indexer = import_module("github.com/kurtosis-tech/near-package/src/services/indexer.star")
contract_helper = import_module("github.com/kurtosis-tech/near-package/src/services/contract_helper.star")
explorer_backend = import_module("github.com/kurtosis-tech/near-package/src/services/explorer_backend.star")
explorer_frontend = import_module("github.com/kurtosis-tech/near-package/src/services/explorer_frontend.star")

def launch_near_network(backend_ip_address):
	print("Launching contract helper postgresql")
	contract_helper_db_info = contract_helper_postgresql.add_contract_helper_db()
	print("Contract helper postgresql db info " + str(contract_helper_db_info))

	print("Launching contract helper dynamo db")
	contract_helper_dynamodb_info = contract_helper_dynamodb.add_contract_helper_dynamo_db()
	print("Contract helper dynamodb info " + str(contract_helper_dynamodb_info))

	print("Launching indexer")
	indexer_info = indexer.add_indexer(
		contract_helper_db_info.private_url,
		contract_helper_db_info.db_username,
		contract_helper_db_info.db_user_password,
		contract_helper_db_info.indexer_db
	)
	print("Indexer launched with " + str(indexer_info))

	print("Launching contract helper")
	contract_helper_service_info = contract_helper.add_contract_helper_service(
		contract_helper_db_info.private_url,
		contract_helper_db_info.db_username,
		contract_helper_db_info.db_user_password,
		contract_helper_db_info.indexer_db,
		contract_helper_dynamodb_info.private_url,
		indexer_info.private_rpc_url,
		indexer_info.validator_key,
	)
	print("Contract helper launchded with " + str(contract_helper_service_info))

	print("Launching explorer backend")
	explorer_backend_info = explorer_backend.add_explorer_backend_service(
		indexer_info.private_rpc_url,
		contract_helper_db_info.private_url,
		contract_helper_db_info.db_username,
		contract_helper_db_info.db_user_password,
		contract_helper_db_info.indexer_db,
		contract_helper_db_info.analytics_db,
		contract_helper_db_info.telemetry_db,
	)
	print("Explorer backend launchded with " + str(explorer_backend_info))

	print("Launching explorer frontend")
	explorer_frontend_info = explorer_frontend.add_explorer_frontend_service(
		backend_ip_address,
		explorer_backend_info.private_url,
		explorer_backend_info.public_url,
	)
	print("Explorer frontend launchded with " + str(explorer_frontend_info))
