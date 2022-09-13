const { expect } = require('chai');
const hasherContract = require("../../build/Hasher.json");

describe('IncrementalMerkleTree contract', () => {
    let Hasher, hasher;

    beforeEach(async () => {
        Hasher = await ethers.getContractFactory(hasherContract.abi, hasherContract.bytecode);
        hasher = await Hasher.deploy();
    });

    describe('Poseidon hash', () => {
        it('should hash correctly', async () => {
            const res = await hasher["poseidon(uint256[2])"]([1,2]);
            // todo
        });
    });
})