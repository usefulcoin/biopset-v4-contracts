var ITCO = artifacts.require("ITCO");
var FakeERC20 = artifacts.require("FakeERC20");

var BN = web3.utils.BN;
const toWei = (value) => web3.utils.toWei(value.toString(), "ether");
var basePrice = 753520000000;
var oneHour = 3600;
const send = (method, params = []) =>
  new Promise((resolve, reject) =>
    web3.currentProvider.send(
      { id: 0, jsonrpc: "2.0", method, params },
      (err, x) => {
        if (err) reject(err);
        else resolve(x);
      }
    )
  );
const timeTravel = async (seconds) => {
  return new Promise(async (resolve, reject) => {
    await send("evm_increaseTime", [seconds]);
    await send("evm_min");
    await send("evm_min");
    await send("evm_min");
    await send("evm_min");
    resolve();
  });
};

contract("ITCO", (accounts) => {
  it("exists", () => {
    return ITCO.deployed().then(async function (instance) {
      assert.equal(
        typeof instance,
        "object",
        "Contract instance does not exist"
      );
    });
  });
  it("open ITCO", () => {
    return ITCO.deployed().then(async function (instance) {
      return FakeERC20.deployed().then(async function (token) {
        var b = await token.balanceOf(accounts[0]);
        console.log(`opening ITCO with balance ${b}`);
        await token.approve(instance.address, b, {from: accounts[0]});
        await instance.open(b, 120, {from: accounts[0]});
        
        var b2 = await token.balanceOf(instance.address);
       
        assert.equal(
          b.toString(),
          b2.toString(),
          "ITCO amount is wrong "
        );
      });
    });
  });
  it("2 purchases in ITCO", () => {
    return ITCO.deployed().then(async function (instance) {
      return FakeERC20.deployed().then(async function (token) {
        instance.sendTransaction({
            from: accounts[4],
            value: web3.utils.toWei("1", "ether")
        });
        var b = await token.balanceOf(accounts[4]);
        instance.sendTransaction({
            from: accounts[5],
            value: web3.utils.toWei("1", "ether")
        });
        var b2 = await token.balanceOf(accounts[5]);
       
        assert.equal(
          b.toString(),
          b2.toString(),
          "ITCO amount is wrong "
        );
    });
  });
  });
  it("after 2 eth deposits, ITCO balance should be 2 eth", () => {
    return ITCO.deployed().then(async function (instance) {
        var b = await web3.eth.getBalance(instance.address);
       
        assert.equal(
          b.toString(),
          web3.utils.toWei("2", "ether"),
          "ITCO amount is wrong "
        );
    });
  });

  it("collect ETH from ITCO", () => {
    return ITCO.deployed().then(async function (instance) {
        await timeTravel(300);
        await instance.collect( {from: accounts[0]});
        var b = await web3.eth.getBalance(instance.address);
       
        assert.equal(
          b.toString(),
          "0",
          "ITCO balance is wrong"
        );
    });
  });
  it("should collect leftover tokens from ITCO", () => {
    return ITCO.deployed().then(async function (instance) {
      return FakeERC20.deployed().then(async function (token) {
        var leftovers = await token.balanceOf(instance.address);
       
        assert.equal(
          leftovers.toString(),
          "0",
          "ITCO leftover balance balance is not 0"
        );
    });
  });
});
});
