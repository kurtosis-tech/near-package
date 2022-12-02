NEAR PACKAGE
===========================
Starlark version of the near-kurtosis-module

- [ ] enable free & open source in circle settings when this repo is public


### Required features until parity

- [x] package IO
- [x] static files
- [x] service_port_availability_checker DESCOPED - broken on OG repo
- [x] service_urls
- [x] near_module_configurator - DESCOPED - this did log level setting (which we don't have) & param(which we do via pacakge_io)
- [ ] near_module depends on services
- [x] consts
- [ ] services
	- [x] contract_helper_dynamodb
	- [x] contract_helper_postgresql
	- [x] indexer
		- [x] framework
		- [x] fetch, parse and return validator key - Requires product change
	- [x] contract_helper
	- [x] explorer_backend
	- [ ] explorer_frontend
	- [ ] wallet
- [ ] readme & other project meta content