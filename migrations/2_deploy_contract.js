const TokenplayToken = artifacts.require("TokenplayToken");

module.exports = function(deployer) {
  deployer.deploy(TokenplayToken);
};
