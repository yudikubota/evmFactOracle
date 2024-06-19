import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { NumberToFactor } from "./utils";
import { Contract } from "ethers";

describe("Pay Per Use Oracle", function () {
  const _privateAddress = "0x0123456789012345678901234567890123456789012345678901234567890123";
  const walletSigner = new ethers.Wallet(_privateAddress);
  const _apiPubKeySigner = walletSigner.address;

  const _nodeId = 123;
  const _seed = 1568;
  let _license = 3; // pay per use

  const _feedId = 123;
  const _decimal = 8;
  const _price = 10864251000000000n; // Wei for U$30
  const _lastupdate = Math.floor(Date.now() / 1000);
  const _value = NumberToFactor(98, _decimal);
  const _msg = ethers.getBytes(ethers.solidityPackedKeccak256(["uint32", "int256", "uint256", "uint16"], [_feedId, _value, _lastupdate, _seed]));

  const abi = ethers.AbiCoder.defaultAbiCoder();
  
  const _packvalue = abi.encode(["int256"], [_value]);
  const _packmsg = ethers.getBytes(ethers.solidityPackedKeccak256(["uint32", "bytes", "uint256", "uint16"], [_feedId, _packvalue, _lastupdate, _seed]));

  const _signerId = 100;

  const _datafeed = {
    feedId: _feedId,
    signerId: _signerId,
    lastUpdate: _lastupdate,
    value: _value,
    decimal: _decimal,
    msgHash: new Uint8Array(0),
  };

  const _packdatafeed = {
    feedId: _feedId,
    signerId: _signerId,
    lastUpdate: _lastupdate,
    value: _packvalue,
    decimal: _decimal,
    msgHash: new Uint8Array(0),
  };

  async function deployController() {
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("FOController", { signer: owner });
    const controllerContract = await factor.deploy(owner.address, _seed, _apiPubKeySigner);
    const controllerAddress = await controllerContract.getAddress();
    return { controllerContract, controllerAddress };
  }

  async function deployDataNode() {
    const { controllerContract, controllerAddress } = await loadFixture(deployController);
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("FODataNode", { signer: owner });
    const dataNodeContract = await factor.deploy(controllerAddress);
    return { controllerContract, controllerAddress, dataNodeContract, owner };
  }

  async function deployOracle() {
    const { controllerContract, controllerAddress, dataNodeContract } = await loadFixture(deployDataNode);
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("PayPerUseOracle", { signer: owner });
    const oracleContract = await factor.deploy(controllerAddress, _license);
    return { controllerContract, controllerAddress, dataNodeContract, oracleContract, owner };
  }

  async function deployConsumer() {    
    const { controllerContract, controllerAddress, dataNodeContract, oracleContract, owner} = await loadFixture(deployOracle);    
    const factor = await ethers.getContractFactory("ConsumerPPU", { signer: owner });
    const consumerContract = await factor.deploy(await oracleContract.getAddress());    
    return { controllerContract, controllerAddress, dataNodeContract, oracleContract, owner , consumerContract};
  }


  async function WarmupDataService(ctrlsc: any, dataNodeContract: any, oracleContract: any) {
    const dnaddress = await dataNodeContract.getAddress();
    await ctrlsc.addNode(_nodeId, dnaddress);
    await ctrlsc.assignFeedNode(_feedId, _nodeId);
    await ctrlsc.addLicense(_feedId, _license, _price);
    await dataNodeContract.store(_datafeed);
    await dataNodeContract.storePack(_packdatafeed);
    await ctrlsc.addOracle(await oracleContract.getAddress());
  }

  it("Create data note, controller, license and onboard feed  ", async function () {
    const { controllerContract: ctrlsc, controllerAddress, dataNodeContract, oracleContract, owner } = await loadFixture(deployOracle);
    await WarmupDataService(ctrlsc, dataNodeContract, oracleContract);
  });

  it("Check Price and get feed value in int and binary.", async function () {
    const { controllerContract: ctrlsc, controllerAddress, dataNodeContract, oracleContract, owner } = await loadFixture(deployOracle);
    await WarmupDataService(ctrlsc, dataNodeContract, oracleContract);

    expect(await oracleContract.checkPrice(_feedId)).to.be.equal(_price);

    try {
      await oracleContract.getValue(_feedId, { value: _price });
    } catch (e) {
      expect(e).to.be.revertedWith("Function call to a non-contract account");
    }

    try {
      await oracleContract.getPackValue(_feedId, { value: _price });
    } catch (e) {
      expect(e).to.be.revertedWith("Function call to a non-contract account");
    }

    try {
      await oracleContract.request(_feedId, { value: _price });
    } catch (e) {
      expect(e).to.be.revertedWith("Function call to a non-contract account");
    }
    
    const _hash = await walletSigner.signMessage(_msg);

    const _datafeed = {
      feedId: _feedId,
      signerId: _signerId,
      lastUpdate: _lastupdate,
      value: _value,
      decimal: _decimal,
      msgHash: _hash,
    };

    const _packdatafeed = {
      feedId: _feedId,
      signerId: _signerId,
      lastUpdate: _lastupdate,
      value: _packvalue,
      decimal: _decimal,
      msgHash: _hash,
    };

    try {
      await oracleContract.verify(_datafeed, { value: _price });
    } catch (e) {
      expect(e).to.be.revertedWith("Function call to a non-contract account");
    }

    try {
      await oracleContract.verifyPack(_packdatafeed, { value: _price });
    } catch (e) {
      expect(e).to.be.revertedWith("Function call to a non-contract account");
    }

  });


  it("Consumer - get value, pack, signature. Request/response. Check if callback worked", async function () {
    const { controllerContract: ctrlsc,  dataNodeContract, oracleContract, consumerContract } = await loadFixture(deployConsumer);
    await WarmupDataService(ctrlsc, dataNodeContract, oracleContract);

    expect(await oracleContract.checkPrice(_feedId)).to.be.equal(_price);    
    expect(await consumerContract.value()).to.be.equal(0);
    await consumerContract.get(_feedId,  { value: _price });
    expect(await consumerContract.value()).to.be.equal(_value);

    await consumerContract.getPack(_feedId,  { value: _price });
    expect(await consumerContract.valuePack()).to.be.equal(_packvalue);
    
    await consumerContract.reset();
    expect(await consumerContract.value()).to.be.equal(0);


    const _hash = await walletSigner.signMessage(_msg);

    const _datafeed = {
      feedId: _feedId,
      signerId: _signerId,
      lastUpdate: _lastupdate,
      value: _value,
      decimal: _decimal,
      msgHash: _hash,
    };

    const _packdatafeed = {
      feedId: _feedId,
      signerId: _signerId,
      lastUpdate: _lastupdate,
      value: _packvalue,
      decimal: _decimal,
      msgHash: _hash,
    };

    await consumerContract.verify(_datafeed, { value: _price });
    expect(await consumerContract.value()).to.be.equal(_value);
    await consumerContract.verifyPack(_packdatafeed, { value: _price });
    expect(await consumerContract.valuePack()).to.be.equal(_packvalue);

    await consumerContract.reset();
    await consumerContract.request(_feedId,  { value: _price });

    await oracleContract.response(_feedId, await consumerContract.getAddress(),_value);
    expect(await consumerContract.value()).to.be.equal(_value);


  });

});
