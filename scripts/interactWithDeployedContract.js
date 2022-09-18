const ethers = require('ethers');
require('dotenv').config();

const INFURA_API_KEY = process.env.INFURA_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = '0xAaFEcf7b95C26dfB717E94a8Fb0DfCF9792c6516';
const abi =
  require('../artifacts/contracts/IncrementalMerkleTree.sol/IncrementalMerkleTree.json').abi;

const interactWithMerkleTree = async () => {
  const provider = new ethers.providers.InfuraProvider('rinkeby', INFURA_API_KEY);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  const signer = wallet.connect(provider);
  contract = new ethers.Contract(CONTRACT_ADDRESS, abi, signer);

  let status = await addLeaf(
    contract,
    '0x1399C190AEEDDC5D8B2242AB17F97B42631BB0B7877E92B92C3BE2EC5685A6A1'
  );

  console.log(`The leaf was added correctly? ${status}`);

  const root = await getLastRoot(contract);
  console.log(`root is ${ethers.utils.hexlify(root)}`);
};

/**
 * Add a leaf to the merkle tree, and check that it was added correctly
 * @param {ethers.Contract} contract
 * @param {ethers.BigNumber} leaf - the leaf to add
 */
const addLeaf = async (contract, leaf) => {
  console.log(`Adding ${leaf}`);
  const tx = await contract.addLeaf(leaf);
  const receipt = await tx.wait();
  return receipt.events[0]?.event === 'LeafAdded';
};

/**
 *
 * @param {ethers.Contract} contract
 * @returns {ethers.BigNumber} - the current root of the incremental merkle tree
 */
const getLastRoot = async (contract) => {
  return await contract.getLastRoot();
};

interactWithMerkleTree();
