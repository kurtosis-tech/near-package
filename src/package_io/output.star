def create_output(
	network_name,
	root_validator_key, 
	near_node_rpc_url,
	contract_helper_service_url,
	wallet_url,
	explorer_url):
	return struct(
		network_name = network_name,
		root_validator_key = root_validator_key,
		near_node_rpc_url = near_node_rpc_url,
		contract_helper_service_url = contract_helper_service_url,
		wallet_url = wallet_url,
		explorer_url = explorer_url,		
	)
