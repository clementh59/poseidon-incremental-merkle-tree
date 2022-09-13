const { expect } = require('chai');
const hasherContract = require("../../build/Hasher.json");

const NUMBER_OF_LEVEL = 4;
const NUMBER_OF_HISTORICAL_ROOTS = 3;

describe('IncrementalMerkleTree contract', () => {
    let IncrementalMerkleTree, incrementalMerkleTree;
    let Hasher, hasher;

    beforeEach(async () => {
        Hasher = await ethers.getContractFactory(hasherContract.abi, hasherContract.bytecode);
        hasher = await Hasher.deploy();
        IncrementalMerkleTree = await ethers.getContractFactory('IncrementalMerkleTree');
        incrementalMerkleTree = await IncrementalMerkleTree.deploy(NUMBER_OF_LEVEL, NUMBER_OF_HISTORICAL_ROOTS, hasher.address);
        [addr1, addr2] = await ethers.getSigners();
    });

    describe('Deployment', () => {

        it('should successfully deploy contracts', async () => {
            // todo
        });

        it('should set the number of levels passed in the constructor', async () => {
            const nbLevels = await incrementalMerkleTree.levels();
            expect(nbLevels).to.equal(NUMBER_OF_LEVEL);
        });

        it('should set the number of historical roots passed in the constructor', async () => {
            const rootHistorySize = await incrementalMerkleTree.rootHistorySize();
            expect(rootHistorySize).to.equal(NUMBER_OF_HISTORICAL_ROOTS);
        });

        // todo: should initialize the tree correctly
    });

    // todo: rename
    // in the unit test, I'll test if the event are emitted -> OK
    // I'll test the max number of leaves I can add based on the level -> OK
    // I'll test the max number of root history
    describe('Basic scenario', () => {
        it('should add leaves and emit events', async () => {
            const tx = await incrementalMerkleTree.addLeaf(123);
            await expect(tx)
                .to.emit(incrementalMerkleTree, 'LeafAdded')
                .withArgs(
                    0
                );
            const tx2 = await incrementalMerkleTree.addLeaf(456);
            await expect(tx2)
                .to.emit(incrementalMerkleTree, 'LeafAdded')
                .withArgs(
                    1
                );
        });

        it('should revert when adding more leaves than authorized', async () => {
            for (let i = 0; i < 2**NUMBER_OF_LEVEL; i++) {
                await incrementalMerkleTree.addLeaf(123);
            }
            await expect(incrementalMerkleTree.addLeaf(123)).to.be.revertedWith('Merkle tree is full. No more leaves can be added');
        });

        it("should not find a root that isn't in the history", async () => {
            const isKnownRoot = await incrementalMerkleTree.isKnownRoot("0x123");
            expect(isKnownRoot).to.be.false;
        });

        it('should keep in the history exactly NUMBER_OF_HISTORICAL_ROOTS roots', async () => {
            const dummyLeafValue = 0x123;
            const roots = [];
            let i;
            for (i = 0; i < NUMBER_OF_HISTORICAL_ROOTS; i++) {
                await incrementalMerkleTree.addLeaf(dummyLeafValue);
                roots.push(await incrementalMerkleTree.getLastRoot());
            }
            
            for (i = 0; i < roots.length; i++) {
                const isKnownRoot = await incrementalMerkleTree.isKnownRoot(roots[i]);
                expect(isKnownRoot).to.be.true;
            }

            await incrementalMerkleTree.addLeaf(dummyLeafValue);
            roots.push(await incrementalMerkleTree.getLastRoot());

            isKnownRoot = await incrementalMerkleTree.isKnownRoot(roots[0]);
            expect(isKnownRoot).to.be.false;

            for (i = 1; i < roots.length; i++) {
                const isKnownRoot = await incrementalMerkleTree.isKnownRoot(roots[i]);
                expect(isKnownRoot).to.be.true;
            }
        });


    });
})