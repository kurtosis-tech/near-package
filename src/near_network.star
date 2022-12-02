EXPLORER_WAMP_BACKEND_FRONTEND_SHARED_NETWORK_NAME = "localnet"

contract_helper_postgresql = import_module("github.com/kurtosis-tech/near-package/src/services/contract_helper_postgresql.star")
contract_helper_dynamodb = import_module("github.com/kurtosis-tech/near-package/src/services/contract_helper_dynamodb.star")
indexer = import_module("github.com/kurtosis-tech/near-package/src/services/indexer.star")

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
		contract_helper_db_info.db_password,
		contract_helper_db_info.indexer_db
	)
	print("Indexer launched with " + str(indexer_info))
