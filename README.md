# Poseidon-incremental-merkle-tree

This repository contains a smart contract which implements an incremental merkle tree based on poseidon hash.

## Test

Run all tests:
```shell
npm run test
```

Run unit tests:
```shell
npm run test:unit
```

Run integration tests:
```shell
npm run test:integration
```

## Areas of improvement

The solidity function `isKnownRoot` can do up to 2^32 iteration while looking for the root, which isn't great.