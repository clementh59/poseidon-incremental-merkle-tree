pragma solidity ^0.8.0;

contract IncrementalMerkleTree {

    uint256 public constant ZERO_VALUE = 21663839004416932945382355908790599225266501822907911457504978515578255421292; // = keccak256("tornado") % FIELD_SIZE
    uint32 public levels;

    constructor(uint32 _levels) {
    require(_levels > 0, "_levels should be greater than zero");
    require(_levels < 32, "_levels should be less than 32");
    levels = _levels;
  }

}