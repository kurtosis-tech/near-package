shared_utils = import_module("github.com/kurtosis-tech/near-package/src/shared_utils.star")
constants = import_module("github.com/kurtosis-tech/near-package/src/constants.star")
service_url = import_module("github.com/kurtosis-tech/near-package/src/service_url.star")


SERVICE_ID = "contract-helper-service"
PORT_ID = "rest";
PRIVATE_PORT_NUM = 3000;
PUBLIC_PORT_NUM = 8330;
PRIVATE_PORT_SPEC = shared_utils.new_port_spec(PRIVATE_PORT_NUM, shared_utils.TCP_PROTOCOL);
PUBLIC_PORT_SPEC = shared_utils.new_port_spec(PUBLIC_PORT_NUM, shared_utils.TCP_PROTOCOL);
PORT_PROTOCOL = "http";
IMAGE = "kurtosistech/near-contract-helper:88585e9";

ACCOUNT_CREATOR_KEY_ENVVAR = "ACCOUNT_CREATOR_KEY";
INDEXER_DB_CONNECTION_ENVVAR = "INDEXER_DB_CONNECTION";
NODE_RPC_URL_ENVVAR  = "NODE_URL";
DYNAMO_DB_URL_ENVVAR = "LOCAL_DYNAMODB_HOST";
DYNAMO_DB_PORT_ENVVAR = "LOCAL_DYNAMODB_PORT";

# See https://github.com/near/near-contract-helper/blob/master/.env.sample for where these are drawn from
STATIC_ENVVARS = {
    // ACCOUNT_CREATOR_KEY will be set dynamically 

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

VALIDATOR_KEY_PRETTY_PRINT_NUM_SPACES = 2;

def new_contract_helper_service_info(private_url, public_url):
    return struct(
        private_url = private_url,
        public_url = public_url
    )


export async function addContractHelperService(
    enclaveCtx: EnclaveContext,
    dbPrivateUrl: ServiceUrl,
    dbUsername: string,
    dbUserPassword: string,
    dbName: string,
    dynamoDbPrivateUrl: ServiceUrl,
    nearNodePrivateRpcUrl: ServiceUrl,
    validatorKey: Object,
): Promise<Result<ContractHelperServiceInfo, Error>> {
    log.info(`Adding contract helper service running on port '${PRIVATE_PORT_NUM}'`);
    const usedPorts: Map<string, PortSpec> = new Map();
    usedPorts.set(PORT_ID, PRIVATE_PORT_SPEC);

    const publicPorts: Map<string, PortSpec> = new Map();
    publicPorts.set(PORT_ID, PUBLIC_PORT_SPEC);

    let validatorKeyStr: string;
    try {
        validatorKeyStr = JSON.stringify(validatorKey, null, VALIDATOR_KEY_PRETTY_PRINT_NUM_SPACES);
    } catch (e: any) {
        # Sadly, we have to do this because there's no great way to enforce the caught thing being an error
        // See: https://stackoverflow.com/questions/30469261/checking-for-typeof-error-in-js
        if (e && e.stack && e.message) {
            return err(e as Error);
        }
        return err(new Error("Serializing the validator key threw an exception, but " +
            "it's not an Error so we can't report any more information than this"));
    }

    const envvars: Map<string, string> = new Map();
    envvars.set(
        ACCOUNT_CREATOR_KEY_ENVVAR,
        validatorKeyStr,
    )
    envvars.set(
        INDEXER_DB_CONNECTION_ENVVAR,
        `postgres://${dbUsername}:${dbUserPassword}@${dbPrivateUrl.ipAddress}:${dbPrivateUrl.portNumber}/${dbName}`
    )
    envvars.set(
        NODE_RPC_URL_ENVVAR,
        nearNodePrivateRpcUrl.toString(),
    )
    envvars.set(
        DYNAMO_DB_URL_ENVVAR,
        dynamoDbPrivateUrl.ipAddress,
    )
    envvars.set(
        DYNAMO_DB_PORT_ENVVAR,
        dynamoDbPrivateUrl.portNumber.toString(),
    )

    for (let [key, value] of STATIC_ENVVARS.entries()) {
        envvars.set(key, value);
    }

    const containerConfig: ContainerConfig = new ContainerConfigBuilder(
        IMAGE,
    ).withUsedPorts(
        usedPorts
    ).withPublicPorts(
        publicPorts,
    ).withCmdOverride([
        "sh",
        "-c",
        // We need to override the CMD because the Dockerfile (https://github.com/near/near-contract-helper/blob/master/Dockerfile.app)
        // loads hardcoded environment variables that we don't want
        "sleep 10 && node scripts/create-dynamodb-tables.js && yarn start-no-env",
    ]).withEnvironmentVariableOverrides(
        envvars
    ).build();
    
    const addServiceResult: Result<ServiceContext, Error> = await enclaveCtx.addService(SERVICE_ID, containerConfig);
    if (addServiceResult.isErr()) {
        return err(addServiceResult.error);
    }
    const serviceCtx: ServiceContext = addServiceResult.value;

    const waitForPortAvailabilityResult = await waitForPortAvailability(
        PRIVATE_PORT_NUM,
        serviceCtx.getPrivateIPAddress(),
        MILLIS_BETWEEN_PORT_AVAILABILITY_RETRIES,
        PORT_AVAILABILITY_TIMEOUT_MILLIS,
    )
    if (waitForPortAvailabilityResult.isErr()) {
        return err(waitForPortAvailabilityResult.error);
    }

    const getUrlsResult = getPrivateAndPublicUrlsForPortId(
        serviceCtx,
        PORT_ID,
        PORT_PROTOCOL,
        "",
    );
    if (getUrlsResult.isErr()) {
        return err(getUrlsResult.error);
    }
    const [privateUrl, publicUrl] = getUrlsResult.value;

    const result: ContractHelperServiceInfo = new ContractHelperServiceInfo(
        privateUrl,
        publicUrl,
    );

    return ok(result);
}
