NEAR PACKAGE
===========================

This repository contains a [Kurtosis package](https://docs.kurtosis.com/reference/packages) for setting up a NEAR network locally on your machine using Kurtosis.

The validator key of the node that it starts is:

```json
{
  "account_id": "test.near",
  "public_key": "ed25519:3Kuyi2DUXdoHgoaNEvCxa1m6G8xqc6Xs7WGajaqLhNmW",
  "secret_key": "ed25519:2ykcMLiM7vCmsSECcgfmUzihBtNdBv7v2CxNi94sNt4R8ar4xsrMMYvtsSNGQDfSRhNWXEnZvgx2wzS9ViBiS9jW"
}
```

The URLs of the services started inside Kurtosis are as follows:

```
Near node RPC URL: http://127.0.0.1:8332,
Contract helper service URL: http://127.0.0.1:8330,
Explorer URL: http://127.0.0.1:8331
Wallet URL: http://127.0.0.1:8334
```

Quickstart
----------
Follow the instructions on [the NEAR docs](https://docs.near.org/develop/testing/kurtosis-localnet).

For Kurtosis Devs: Upgrading Dependencies
-----------------------------------------
### Rebuild the indexer-for-explorer NEAR node

1. Clone [the NEAR indexer-for-explorer repository](https://github.com/near/near-indexer-for-explorer)
1. Pull the latest `master` branch
1. In the root of the repo, build a Docker image (will take ~45 minutes!):
   ```
   docker build -f Dockerfile -t "kurtosistech/near-indexer-for-explorer:$(git rev-parse --short HEAD)" .
   ```
1. Slot the produced image-and-tag into the `IMAGE` constant in the `indexer.star` file

### Rebuild the contract helper service
1. Clone [the NEAR contract-helper-service repository](https://github.com/near/near-contract-helper)
1. Pull the latest `master` branch
1. In the root of the repo, build a Docker image:
   ```
   docker build -f Dockerfile.app -t "kurtosistech/near-contract-helper:$(git rev-parse --short HEAD)" .
   ```
1. Slot the produced image-and-tag into the `IMAGE` constant in the `contract_helper.star` file

### Rebuild the explorer backend & frontend
1. Clone the [NEAR explorer repository](https://github.com/near/near-explorer)
1. Pull the latest `master` branch
1. In the root of the repo, build an explorer backend Docker image:
   ```
   docker build -f backend/Dockerfile -t "kurtosistech/near-explorer_backend:$(git rev-parse --short HEAD)" .
   ```
1. Slot the produced image-and-tag into the `IMAGE` constant in the `explorer_backend.star` file
1. In the root of the repo, build an explorer backend Docker image:
   ```
   docker build -f frontend/Dockerfile -t "kurtosistech/near-explorer_frontend:$(git rev-parse --short HEAD)" .
   ```
1. Slot the produced image-and-tag into the `IMAGE` constant in the `explorer_frontend.star` file

### Rebuild the wallet
1. Clone the [NEAR wallet](https://github.com/near/near-wallet)
1. Pull the latest `master` branch
1. In the root of the repo, build a Docker image:
   ```
   docker build -f Dockerfile -t "kurtosistech/near-wallet:$(git rev-parse --short HEAD)" .
   ```
1. Slot the produced image-and-tag into the `IMAGE` constant in the `wallet.star` file

### Test the package
1. Re run the package
  ```
  kurtosis run .
  ```
1. Debug & fix any errors, opening issues on the various NEAR repositories as necessary (this is the fastest way to interact with the NEAR devs)
    * NOTE: the NEAR wallet doesn't have a productized way to be configured at runtime (only at buildtime!) because it uses Parcel to precompile & minify all the Javascript into a single file; this means that to point the Wallet at the local services inside of Kurtosis we do janky `sed`'ing to replace variable values inside the minified Wallet Javascript file 
1. Repeat the dev loop as necessary

### Release the package
1. Push the images that your package version is now using (easy way to find them: go through the `IMAGE` constants in each file)
1. Cut a PR
1. Once it's approved, merge & release


