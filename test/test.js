const BUSD = artifacts.require("./BUSD.sol")
const TOP = artifacts.require("./TokenplayToken.sol")
const TOPPrivateSale = artifacts.require("./TOPPrivateSale.sol")
const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))
// const truffleAssert = require('truffle-assertions');
const BigNumber = require('bignumber.js');

contract('TOP private sale', function (accounts) {
    let ownerPrivateSale = accounts[0]
    let ownerTop = accounts[1]
    let whilelist = accounts[2]
    let account1 = accounts[3]
    let account2 = accounts[4]
    let account3 = accounts[5]
    let account4 = accounts[6]
    let account5 = accounts[7]
    let PrivateSale, PrivateSaleAddress
    let Top, TopAddress
    let BUSDContract, BUSDContractAddress

    before("setup", async function () {
        //deploy Top
        Top = await TOP.new({ from: ownerTop })
        TopAddress = Top.address
        // console.log('\t' + TopAddress)

        BUSDContract = await BUSD.new({ from: ownerTop })
        BUSDContractAddress = BUSDContract.address
        // console.log('\t' + BUSDContractAddress)

        PrivateSale = await TOPPrivateSale.new(TopAddress, BUSDContractAddress, 100, 0, { from: ownerPrivateSale })
        PrivateSaleAddress = PrivateSale.address
        await PrivateSale.updateWhiteList([whilelist], [true], { from: ownerPrivateSale })
        // console.log('\t' + PrivateSaleAddress)

        // await Top.mint(BigNumber(Math.pow(10, 20)), { from: account1 })
        await Top.mintTo(BigNumber(Math.pow(10, 20)), PrivateSaleAddress, { from: whilelist })
        await BUSDContract.mint(BigNumber(Math.pow(10, 20)), { from: account1 })
        await BUSDContract.mint(BigNumber(Math.pow(10, 20)), { from: whilelist })
    });

    beforeEach(async function () {
    });

    it("Buy private sale", async () => {
        await BUSDContract.approve(PrivateSaleAddress, BigNumber(Math.pow(10, 20)), { from: whilelist })
        await PrivateSale.buy(10, { from: whilelist })
        let privateSaleBusd = await BUSDContract.balanceOf(PrivateSaleAddress, { from: whilelist })
        console.log(privateSaleBusd.toString())
        let whilelistTop = await Top.balanceOf(whilelist, { from: whilelist })
        console.log(whilelistTop.toString())

        assert.equal(1, 2, "token 1 owner invalid")
    }).timeout(400000000);
});