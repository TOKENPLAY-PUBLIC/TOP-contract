const TOPPrivateSale = artifacts.require("TOPPrivateSale");

module.exports = function(deployer) {
  deployer.deploy(TOPPrivateSale,"0x2E064270620E7a63F732DBEde3DD796b5c35e236", "0x06cA9C345E80908659E84f9Bb77666A35EfE1C92", 5, 10);
};
