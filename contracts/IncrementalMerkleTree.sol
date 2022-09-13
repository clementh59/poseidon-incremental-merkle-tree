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
    mapping(uint256 => uint256) public filledSubtrees;
    // contains the latest historical roots (capped to rootHistorySize)
    mapping(uint256 => uint256) public roots;

    // The number of inserted leaves
    uint32 private nextLeafIndex = 0;

    // The index of the current root in the roots mapping
    uint32 private currentRootIndex;

    // The event emitted when a leaf is added to the tree
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
        levels = _levels;
        rootHistorySize = _rootHistorySize;
        hasher = IHasher(_hasherAddress);
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

        roots[currentRootIndex] = uint256(123); // todo: actual hash
        currentRootIndex = (currentRootIndex + 1) % rootHistorySize;
        nextLeafIndex = currentIndex + 1;

        emit LeafAdded(currentIndex);

        return currentIndex;
    }

    /**
     * Checks if a given root is in the recent history
     * @param _root - The root that we look for
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
}
