shared_utils = import_module("github.com/kurtosis-tech/near-package/src/shared_utils.star")
constants = import_module("github.com/kurtosis-tech/near-package/src/constants.star")
service_url = import_module("github.com/kurtosis-tech/near-package/src/service_url.star")


SERVICE_ID = "contract-helper-db";
PORT_ID = "postgres";
PORT_PROTOCOL = "postgres"
IMAGE = "postgres:13.4-alpine3.14";
PORT_NUM  = 5432;
PORT_SPEC = shared_utils.new_port_spec(PORT_NUM, shared_utils.TCP_PROTOCOL);

POSTGRES_USER = "near";
POSTGRES_PASSWORD = "near";
STATIC_ENVVARS = {
    "POSTGRES_USER": POSTGRES_USER,
    "POSTGRES_PASSWORD": POSTGRES_PASSWORD,
}


INDEXER_DB = "indexer";
ANALYTICS_DB  = "analytics";
TELEMETRY_DB = "telemetry";

DBS_TO_INITIALIZE = [
    INDEXER_DB,
    ANALYTICS_DB,
    TELEMETRY_DB,
]

TIME_TO_SLEEP_FOR_AVAILABILITY = ["sleep", "10"]
AVAILABILITY_CMD  = [
    "psql",
    "-U",
    POSTGRES_USER,
    "-c",
    "\\l"
]


def add_contract_helper_db():
    print("Adding contract helper Posgresql DB running on port '" + str(PORT_NUM) + "'")
    ports = {
        PORT_ID: PORT_SPEC
    }

    config = struct(
        image = IMAGE,
        env_vars = STATIC_ENVVARS,
        ports = ports
    )

    add_service_result = add_service(SERVICE_ID, config)

    # TODO Replace with productized wait
    exec(SERVICE_ID, TIME_TO_SLEEP_FOR_AVAILABILITY)
    exec(SERVICE_ID, AVAILABILITY_CMD, constants.EXEC_COMMAND_SUCCESS_EXIT_CODE)

    for database_to_create in DBS_TO_INITIALIZE:
        create_db_command  = [
            "psql",
            "-U",
            POSTGRES_USER,
            "-c",
            "create database " + database_to_create + " with owner=" + POSTGRES_USER
        ]
        exec(SERVICE_ID, create_db_command, constants.EXEC_COMMAND_SUCCESS_EXIT_CODE)

    private_url, _ = service_url.get_private_and_public_url_for_port_id(
            SERVICE_ID,
            add_service_result,
            config,
            PORT_ID,
            PORT_PROTOCOL,
            ""
        )

    return new_contract_helper_db_info(
        private_url,
        POSTGRES_USER,
        POSTGRES_PASSWORD,
        INDEXER_DB,
        ANALYTICS_DB, 
        TELEMETRY_DB
    )



def new_contract_helper_db_info(
        private_url,
        db_user_name,
        db_password,
        indexer_db,
        analytics_db,
        telemtry_db,
    ):
    return struct (
        private_url = private_url,
        db_user_name = db_user_name,
        db_password = db_password,
        indexer_db = indexer_db,
        analytics_db = analytics_db,
        telemtry_db = telemtry_db
    )

