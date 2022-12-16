shared_utils = import_module("github.com/kurtosis-tech/near-package/src/shared_utils.star")
constants = import_module("github.com/kurtosis-tech/near-package/src/constants.star")
service_url = import_module("github.com/kurtosis-tech/near-package/src/service_url.star")

# Explorer Backend
SERVICE_ID = "explorer-backend"
IMAGE = "kurtosistech/near-explorer_backend:836d8d7"
PORT_ID = "http"
PORT_APP_PROTOCOL = "http"
PRIVATE_PORT_NUM = 8080
PUBLIC_PORT_NUM = 18080
PRIVATE_PORT_SPEC = shared_utils.new_port_spec(PRIVATE_PORT_NUM, shared_utils.TCP_PROTOCOL, shared_utils.HTTP_APPLICATION_PROTOCOL)
PUBLIC_PORT_SPEC = shared_utils.new_port_spec(PUBLIC_PORT_NUM, shared_utils.TCP_PROTOCOL)
URL_PATH = ""

NEAR_NODE_RPC_URL_ENVVAR = "NEAR_RPC_URL"
PORT_ENVVAR = "NEAR_EXPLORER_CONFIG__PORT"

# These environment variables come from https://github.com/near/near-explorer/blob/master/backend/src/config.ts
NEAR_READ_ONLY_INDEXER_DATABASE_USERNAME_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_INDEXER__USER"
NEAR_READ_ONLY_INDEXER_DATABASE_PASSWORD_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_INDEXER__PASSWORD"
NEAR_READ_ONLY_INDEXER_DATABASE_HOST_ENVVAR =     "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_INDEXER__HOST"
NEAR_READ_ONLY_INDEXER_DATABASE_NAME_ENVVAR =     "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_INDEXER__DATABASE"

# These environment variables come from https://github.com/near/near-explorer/blob/master/backend/src/config.ts
NEAR_READ_ONLY_ANALYTICS_DATABASE_USERNAME_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_ANALYTICS__USER"
NEAR_READ_ONLY_ANALYTICS_DATABASE_PASSWORD_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_ANALYTICS__PASSWORD"
NEAR_READ_ONLY_ANALYTICS_DATABASE_HOST_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_ANALYTICS__HOST"
NEAR_READ_ONLY_ANALYTICS_DATABASE_NAME_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_ANALYTICS__DATABASE"

# These environment variables come from https://github.com/near/near-explorer/blob/master/backend/src/config.ts
NEAR_READ_ONLY_TELEMETRY_DATABASE_USERNAME_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_TELEMETRY__USER"
NEAR_READ_ONLY_TELEMETRY_DATABASE_PASSWORD_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_TELEMETRY__PASSWORD"
NEAR_READ_ONLY_TELEMETRY_DATABASE_HOST_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_TELEMETRY__HOST"
NEAR_READ_ONLY_TELEMETRY_DATABASE_NAME_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__READ_ONLY_TELEMETRY__DATABASE"
NEAR_WRITE_ONLY_TELEMETRY_DATABASE_USERNAME_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__WRITE_ONLY_TELEMETRY__USER"
NEAR_WRITE_ONLY_TELEMETRY_DATABASE_PASSWORD_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__WRITE_ONLY_TELEMETRY__PASSWORD"
NEAR_WRITE_ONLY_TELEMETRY_DATABASE_HOST_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__WRITE_ONLY_TELEMETRY__HOST"
NEAR_WRITE_ONLY_TELEMETRY_DATABASE_NAME_ENVVAR = "NEAR_EXPLORER_CONFIG__DB__WRITE_ONLY_TELEMETRY__DATABASE"


STATIC_ENVVARS = {
    "NEAR_IS_LEGACY_SYNC_BACKEND_ENABLED": "false",
    "NEAR_IS_INDEXER_BACKEND_ENABLED": "true",
}


def add_explorer_backend_service(
    near_node_private_rpc_url,
    indexer_db_private_url,
    indexer_db_username,
    indexer_db_user_password,
    indexer_db_name,
    analytics_db_name,
    telemetry_db_name):

    print("Adding explorer backend service")

    ports = {
        PORT_ID: PRIVATE_PORT_SPEC
    }

    public_ports = {
        PORT_ID: PUBLIC_PORT_SPEC
    }

    env_vars = {
        # TODO MAKE THIS MATCH BACKEND
        # [NETWORK_NAME_ENVVAR, networkName],
        PORT_ENVVAR: str(PRIVATE_PORT_NUM),

        # Indexer DB envvars
        NEAR_READ_ONLY_INDEXER_DATABASE_USERNAME_ENVVAR: indexer_db_username,
        NEAR_READ_ONLY_INDEXER_DATABASE_PASSWORD_ENVVAR: indexer_db_user_password,
        NEAR_READ_ONLY_INDEXER_DATABASE_HOST_ENVVAR: indexer_db_private_url.ip_address,
        NEAR_READ_ONLY_INDEXER_DATABASE_NAME_ENVVAR: indexer_db_name,

        # Analytics DB envvars
        NEAR_READ_ONLY_ANALYTICS_DATABASE_USERNAME_ENVVAR: indexer_db_username,
        NEAR_READ_ONLY_ANALYTICS_DATABASE_PASSWORD_ENVVAR: indexer_db_user_password,
        NEAR_READ_ONLY_ANALYTICS_DATABASE_HOST_ENVVAR: indexer_db_private_url.ip_address,
        NEAR_READ_ONLY_ANALYTICS_DATABASE_NAME_ENVVAR: analytics_db_name,

        # Telemetry DB envvars
        NEAR_READ_ONLY_TELEMETRY_DATABASE_USERNAME_ENVVAR: indexer_db_username,
        NEAR_READ_ONLY_TELEMETRY_DATABASE_PASSWORD_ENVVAR: indexer_db_user_password,
        NEAR_READ_ONLY_TELEMETRY_DATABASE_HOST_ENVVAR: indexer_db_private_url.ip_address,
        NEAR_READ_ONLY_TELEMETRY_DATABASE_NAME_ENVVAR: telemetry_db_name,
        NEAR_WRITE_ONLY_TELEMETRY_DATABASE_USERNAME_ENVVAR: indexer_db_username,
        NEAR_WRITE_ONLY_TELEMETRY_DATABASE_PASSWORD_ENVVAR: indexer_db_user_password,
        NEAR_WRITE_ONLY_TELEMETRY_DATABASE_HOST_ENVVAR: indexer_db_private_url.ip_address,
        NEAR_WRITE_ONLY_TELEMETRY_DATABASE_NAME_ENVVAR: telemetry_db_name,

        "NEAR_EXPLORER_CONFIG__ARCHIVAL_RPC_URL": service_url.service_url_to_string(near_node_private_rpc_url)
    }

    config = struct(
        image = IMAGE,
        ports = ports,
        env_vars = env_vars,
        # TODO remove this when we have a producized way of doing this
        # This has been added as this gets used downstream in explorer_frontend and Starlark has
        # no way to get the public port of a service, hence we predict the value by setting it
        public_ports = public_ports,
    )

    add_service_result = add_service(SERVICE_ID, config)

    private_url, public_url = service_url.get_private_and_public_url_for_port_id(
        SERVICE_ID,
        add_service_result,
        config,
        PORT_ID,
        PORT_APP_PROTOCOL,
        URL_PATH
    )

    return new_explorer_backend_info(private_url, public_url)



def new_explorer_backend_info(private_url, public_url):
    return struct(
        private_url = private_url,
        public_url = public_url
    )

