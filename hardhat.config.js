/** @type import('hardhat/config').HardhatUserConfig */

require('@nomiclabs/hardhat-waffle');
require('dotenv').config();

const INFURA_API_KEY = process.env.INFURA_API_KEY;
const PRIVATE_KEY =
  process.env.PRIVATE_KEY || 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';

module.exports = {
  solidity: '0.8.0',
  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
  },
};
