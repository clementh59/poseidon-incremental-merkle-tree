// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// todo: remove
import "hardhat/console.sol";

interface IHasher {
    function poseidon(uint256[2] memory) external pure returns (uint256);
}

contract IncrementalMerkleTree {
    uint256 public constant SNARK_SCALAR_FIELD =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 public constant ZERO_VALUE =
        21663839004416932945382355908790599225266501822907911457504978515578255421292; // = keccak256("tornado") % FIELD_SIZE

    // The tree depth
    uint32 public immutable levels;

    // The Merkle root
    uint256 public root;

    // The number of historical roots we want to keep
    uint32 public immutable rootHistorySize;

    // hasher contract instance that computes poseidon hashes
    IHasher public immutable hasher;

    // filledSubtrees and roots could be bytes32[size], but using mappings makes it cheaper because
    // it removes index range check on every interaction
    // filledSubtrees allows you to compute the new merkle root each time a leaf is added
    mapping(uint256 => uint256) public filledSubtrees;
    // contains the latest historical roots (capped to rootHistorySize)
    mapping(uint256 => uint256) public roots;

    // The number of inserted leaves
    uint32 private nextLeafIndex = 0;

    // The index of the current root in the roots mapping
    uint32 private currentRootIndex;

    // The event emitted when a leaf is successfully added to the tree
    event LeafAdded(uint256 indexed leaf);

    constructor(
        uint32 _levels,
        uint32 _rootHistorySize,
        address _hasherAddress
    ) {
        require(_levels > 0, "_levels should be greater than zero");
        require(_levels < 32, "_levels should be less than 32");
        require(
            _rootHistorySize > 0,
            "_rootHistorySize should be greater than zero"
        );
        require(
            _rootHistorySize < 4294967296,
            "_rootHistorySize should be less than 2^32"
        );
        levels = _levels;
        rootHistorySize = _rootHistorySize;
        hasher = IHasher(_hasherAddress);

        // todo: init with zeros
        for (uint32 i = 0; i < _levels; i++) {
        filledSubtrees[i] = zeros(i);
        }

        roots[0] = zeros(_levels - 1);
    }

    /**
        @dev Hash 2 tree leaves, returns poseidon(_left, _right)
    */
    function hashLeftRight(uint256 _left, uint256 _right)
        internal
        view
        returns (uint256)
    {
        require(
            _left < SNARK_SCALAR_FIELD,
            "_left should be inside the SNARK field"
        );
        require(
            _right < SNARK_SCALAR_FIELD,
            "_right should be inside the SNARK field"
        );
        uint256[2] memory inputs;
        inputs[0] = _left;
        inputs[1] = _right;

        //console.log("Hashing %s and %s", _left, _right);
        return hasher.poseidon(inputs);
    }

    /**
     * Inserts a leaf in the incremental merkle tree
     * @param _leaf - The value to insert. It must be less than the snark scalar
     *                field or this function will throw.
     * @return The leaf index
     */
    function addLeaf(uint256 _leaf) public returns (uint256) {
        uint32 currentIndex = nextLeafIndex;

        require(
            currentIndex < uint32(2)**levels,
            "Merkle tree is full. No more leaves can be added"
        );

        uint256 currentLevelHash = _leaf;
        uint256 left;
        uint256 right;

        // compute the new merkle root
        for (uint32 i = 0; i < levels; i++) {
            if (currentIndex % 2 == 0) {
                left = currentLevelHash;
                right = zeros(i);
                filledSubtrees[i] = currentLevelHash;
            } else {
                left = filledSubtrees[i];
                right = currentLevelHash;
            }
            currentLevelHash = hashLeftRight(left, right);
            //console.log("Gave %s", currentLevelHash);
            currentIndex /= 2;
        }

        currentRootIndex = (currentRootIndex + 1) % rootHistorySize;
        roots[currentRootIndex] = currentLevelHash;

        emit LeafAdded(nextLeafIndex);

        nextLeafIndex += 1;

        return currentIndex;
    }

    /**
     * Checks if a given root is in the recent history
     * @param _root - The root we are looking for
     * @return true if the _root is present in the root history, false otherwise
     */
    function isKnownRoot(uint256 _root) public view returns (bool) {
        if (_root == 0) {
            return false;
        }

        uint32 _currentRootIndex = currentRootIndex;
        uint32 i = _currentRootIndex;

        do {
            if (_root == roots[i]) {
                return true;
            }
            if (i == 0) {
                i = rootHistorySize;
            }
            i--;
        } while (i != _currentRootIndex);

        return false;
    }

    /**
     * @return the last root
     */
    function getLastRoot() public view returns (uint256) {
        return roots[currentRootIndex];
    }

    function zeros(uint256 i) public pure returns (uint256) {
    if (i == 0) return uint256(0x2fe54c60d3acabf3343a35b6eba15db4821b340f76e741e2249685ed4899af6c);
    else if (i == 1) return uint256(0x256a6135777eee2fd26f54b8b7037a25439d5235caee224154186d2b8a52e31d);
    else if (i == 2) return uint256(0x1151949895e82ab19924de92c40a3d6f7bcb60d92b00504b8199613683f0c200);
    else if (i == 3) return uint256(0x20121ee811489ff8d61f09fb89e313f14959a0f28bb428a20dba6b0b068b3bdb);
    else if (i == 4) return uint256(0x0a89ca6ffa14cc462cfedb842c30ed221a50a3d6bf022a6a57dc82ab24c157c9);
    else if (i == 5) return uint256(0x24ca05c2b5cd42e890d6be94c68d0689f4f21c9cec9c0f13fe41d566dfb54959);
    else if (i == 6) return uint256(0x1ccb97c932565a92c60156bdba2d08f3bf1377464e025cee765679e604a7315c);
    else if (i == 7) return uint256(0x19156fbd7d1a8bf5cba8909367de1b624534ebab4f0f79e003bccdd1b182bdb4);
    else if (i == 8) return uint256(0x261af8c1f0912e465744641409f622d466c3920ac6e5ff37e36604cb11dfff80);
    else if (i == 9) return uint256(0x0058459724ff6ca5a1652fcbc3e82b93895cf08e975b19beab3f54c217d1c007);
    else if (i == 10) return uint256(0x1f04ef20dee48d39984d8eabe768a70eafa6310ad20849d4573c3c40c2ad1e30);
    else if (i == 11) return uint256(0x1bea3dec5dab51567ce7e200a30f7ba6d4276aeaa53e2686f962a46c66d511e5);
    else if (i == 12) return uint256(0x0ee0f941e2da4b9e31c3ca97a40d8fa9ce68d97c084177071b3cb46cd3372f0f);
    else if (i == 13) return uint256(0x1ca9503e8935884501bbaf20be14eb4c46b89772c97b96e3b2ebf3a36a948bbd);
    else if (i == 14) return uint256(0x133a80e30697cd55d8f7d4b0965b7be24057ba5dc3da898ee2187232446cb108);
    else if (i == 15) return uint256(0x13e6d8fc88839ed76e182c2a779af5b2c0da9dd18c90427a644f7e148a6253b6);
    else if (i == 16) return uint256(0x1eb16b057a477f4bc8f572ea6bee39561098f78f15bfb3699dcbb7bd8db61854);
    else if (i == 17) return uint256(0x0da2cb16a1ceaabf1c16b838f7a9e3f2a3a3088d9e0a6debaa748114620696ea);
    else if (i == 18) return uint256(0x24a3b3d822420b14b5d8cb6c28a574f01e98ea9e940551d2ebd75cee12649f9d);
    else if (i == 19) return uint256(0x198622acbd783d1b0d9064105b1fc8e4d8889de95c4c519b3f635809fe6afc05);
    else if (i == 20) return uint256(0x29d7ed391256ccc3ea596c86e933b89ff339d25ea8ddced975ae2fe30b5296d4);
    else if (i == 21) return uint256(0x19be59f2f0413ce78c0c3703a3a5451b1d7f39629fa33abd11548a76065b2967);
    else if (i == 22) return uint256(0x1ff3f61797e538b70e619310d33f2a063e7eb59104e112e95738da1254dc3453);
    else if (i == 23) return uint256(0x10c16ae9959cf8358980d9dd9616e48228737310a10e2b6b731c1a548f036c48);
    else if (i == 24) return uint256(0x0ba433a63174a90ac20992e75e3095496812b652685b5e1a2eae0b1bf4e8fcd1);
    else if (i == 25) return uint256(0x019ddb9df2bc98d987d0dfeca9d2b643deafab8f7036562e627c3667266a044c);
    else if (i == 26) return uint256(0x2d3c88b23175c5a5565db928414c66d1912b11acf974b2e644caaac04739ce99);
    else if (i == 27) return uint256(0x2eab55f6ae4e66e32c5189eed5c470840863445760f5ed7e7b69b2a62600f354);
    else if (i == 28) return uint256(0x002df37a2642621802383cf952bf4dd1f32e05433beeb1fd41031fb7eace979d);
    else if (i == 29) return uint256(0x104aeb41435db66c3e62feccc1d6f5d98d0a0ed75d1374db457cf462e3a1f427);
    else if (i == 30) return uint256(0x1f3c6fd858e9a7d4b0d1f38e256a09d81d5a5e3c963987e2d4b814cfab7c6ebb);
    else if (i == 31) return uint256(0x2c7a07d20dff79d01fecedc1134284a8d08436606c93693b67e333f671bf69cc);
    else revert("Index out of bounds");
  }
}
