const NFTs = artifacts.require("NftEjm");

module.exports = function (deployer) {
  deployer.deploy(NFTs,'EDUTOKEN','EDTK');
};
