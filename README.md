# Poseidon-incremental-merkle-tree

This repository contains a smart contract which implements an incremental merkle tree based on poseidon hash.

## Algorithm

TODO

## Usage

### Installation

```shell
npm i
```

### Compile contracts

This command compiles IncrementalMerkleTree.sol as well as the contract that implements the poseidon hash function which is
built using [circomlibjs](https://www.npmjs.com/package/circomlibjs).

```shell
npm run compile
```

### Test

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

### Deploy

TODO

## Areas of improvement

The solidity function `isKnownRoot` can do up to 2^32 iterations while looking for the root, which isn't great.
