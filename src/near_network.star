EXPLORER_WAMP_BACKEND_FRONTEND_SHARED_NETWORK_NAME = "localnet"

contract_helper_postgresql = import_module("github.com/kurtosis-tech/near-package/src/services/contract_helper_postgresql.star")

def launch_near_network(backend_ip_address):
	print("Launching contract helper db (postgresql)")
	contract_helper_db_info = contract_helper_postgresql.add_contract_helper_db()
	print("Contract helper db info " + str(contract_helper_db_info))