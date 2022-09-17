const hasherContract = require('../build/Hasher.json');
require('dotenv').config();

const NUMBER_OF_LEVEL = process.env.NUMBER_OF_LEVEL;
const NUMBER_OF_HISTORICAL_ROOTS = process.env.NUMBER_OF_HISTORICAL_ROOTS;

async function main() {
    Hasher = await ethers.getContractFactory(hasherContract.abi, hasherContract.bytecode);
    hasher = await Hasher.deploy();

    console.log(`Hasher address: ${hasher.address}`);

    IncrementalMerkleTree = await ethers.getContractFactory('IncrementalMerkleTree');
    incrementalMerkleTree = await IncrementalMerkleTree.deploy(
      NUMBER_OF_LEVEL,
      NUMBER_OF_HISTORICAL_ROOTS,
      hasher.address
    );

    console.log(`Incremental merkle tree address: ${incrementalMerkleTree.address}`);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.log(error);
        process.exit(1);
    })