# Changelog

## [0.3.0](https://github.com/kurtosis-tech/near-package/compare/0.2.0...0.3.0) (2023-10-02)


### ⚠ BREAKING CHANGES

* Uses the `plan` object. Users will have to update their Kurtosis CLI >= 0.63.0 and do a restart.

### Bug Fixes

* Fix `--enclave-id` -&gt; `--enclave` bug ([#44](https://github.com/kurtosis-tech/near-package/issues/44)) ([135e923](https://github.com/kurtosis-tech/near-package/commit/135e923f7995b9dec2c4c54753407b52cfaabc65))
* move to plan.verify from plan.assert ([#45](https://github.com/kurtosis-tech/near-package/issues/45)) ([b323320](https://github.com/kurtosis-tech/near-package/commit/b323320ec8116428cc17e955fa7b88ce9ed00cbb))
* name the uploaded artifact ([#34](https://github.com/kurtosis-tech/near-package/issues/34)) ([aa3b41e](https://github.com/kurtosis-tech/near-package/commit/aa3b41e1fb59ae233dffc972f45838751537a07b))
* remove garbage from NEAR_HELPER_ACCOUNT export suggestion ([#33](https://github.com/kurtosis-tech/near-package/issues/33)) ([c168941](https://github.com/kurtosis-tech/near-package/commit/c16894179653307310c94464df3eb629ba363bef)), closes [#32](https://github.com/kurtosis-tech/near-package/issues/32)
* service_id renamed to service_name & exec recipe over struct ([#36](https://github.com/kurtosis-tech/near-package/issues/36)) ([1a667a1](https://github.com/kurtosis-tech/near-package/commit/1a667a153011874ba1848cceadb166224b942970))
* Use the `plan` object ([#27](https://github.com/kurtosis-tech/near-package/issues/27)) ([40eb864](https://github.com/kurtosis-tech/near-package/commit/40eb864a0c44bbbcd3d3e48ab43c41e3cfd49c1b))

## 0.2.0

### Breaking Change
- Introduced optional application protocol and renamed protocol to transport_protocol

## 0.1.0

### Breaking Change
- Updated struct to PortSpec to define ports

### Features
- Use `wait` command to wait for availability of PG

### Changes
- Change `exec` syntax

## 0.0.1

### Fixes
- Did some intial work to cleanup
- Made the readme better
- Fix pre-release-script

### Features
- Added static files
- Added package_io
- Added contract_helper_postgresql
- Added contract_helper_dynamodb
- Added indexer
- Added wallet, frontend explorer, backend explorer
- Added historical notes
- Added launch-local-near-cluster.sh script

## 0.0.0
- Initial commit
