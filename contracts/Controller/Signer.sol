// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import "./License.sol";

/**
 * @title Signer
 * @dev This contract manages signing and signature verification for data feeds.
 * It inherits from the License contract.
 */
contract Signer is License {
    uint16 private seed;

    mapping(uint32 => uint16) private feedSignerList;
    mapping(uint16 => address) private signersPubKeyList;

    /**
     * @dev Constructor function to initialize the Signer contract.
     * @param _owner The address of the contract owner.
     * @param _seed A seed value used for cryptographic purposes.
     * @param _apiSignerPubKey The address of the API signer's public key.
     */
    constructor(address _owner, uint16 _seed, address _apiSignerPubKey) License(_owner) { 
        seed = _seed;
        signersPubKeyList[0] = _apiSignerPubKey;
    }

    /**
     * @dev Adds a signer's public key.
     * @param _signerId The ID of the signer.
     * @param _address The address of the signer's public key.
     */
    function addSignerPubKey(uint16 _signerId, address _address) public onlyOwner {
        signersPubKeyList[_signerId] = _address;
    }

    /**
     * @dev Grants permission for a signer to sign a specific feed.
     * @param _feedId The ID of the data feed.
     * @param _signerId The ID of the signer.
     */
    function grantFeedSigner(uint32 _feedId, uint16 _signerId) public onlyOwner {
        feedSignerList[_feedId] = _signerId;
    }

    /**
     * @dev Revokes permission for a signer to sign a specific feed.
     * @param _feedId The ID of the data feed.
     */
    function revokeFeedSigner(uint32 _feedId) public onlyOwner {
        delete feedSignerList[_feedId];
    }

    /**
     * @dev Retrieves the address of a signer based on the feed ID.
     * @param _feedId The ID of the data feed.
     * @return The address of the signer.
     */
    function getSignerAddress(uint32 _feedId) private view returns (address) {
        uint16 signerId = feedSignerList[_feedId];
        return signersPubKeyList[signerId];
    }

    /**
     * @dev Verifies the integrity of the data feed with an integer value.
     * @param _dataFeed The data feed containing the integer value.
     * @return A boolean indicating whether the data feed is valid.
     */
    function verifySignInt(IntDataItem calldata _dataFeed) public view returns (bool) {
        require((isOracle(msg.sender) || isManager(msg.sender)), 'Contract not allowed');
        bytes32 orgMsg = keccak256(abi.encodePacked(_dataFeed.feedId, _dataFeed.value, _dataFeed.lastUpdate, seed));
        return checkSignature(signersPubKeyList[0], orgMsg, _dataFeed.msgHash);
    }

    /**
     * @dev Verifies the integrity of the data feed with a packed value.
     * @param _dataFeed The data feed containing the packed value.
     * @return A boolean indicating whether the data feed is valid.
     */
    function verifySignPack(PackDataItem calldata _dataFeed) public view returns (bool) {
        require((isOracle(msg.sender) || isManager(msg.sender)), 'Contract not allowed');
        bytes32 orgMsg = keccak256(abi.encodePacked(_dataFeed.feedId, _dataFeed.value, _dataFeed.lastUpdate, seed));
        return checkSignature(signersPubKeyList[0], orgMsg, _dataFeed.msgHash);
    }

    /**
     * @dev Verifies the integrity of a data feed hash.
     * @param _feedId The ID of the data feed.
     * @param _orgMsg The original message hash.
     * @param _msgHash The signed message hash.
     * @return A boolean indicating whether the data feed hash is valid.
     */
    function verifyHash(uint32 _feedId, bytes32 _orgMsg, bytes calldata _msgHash) public view returns (bool) {
        require((isOracle(msg.sender) || isManager(msg.sender)), 'Contract not allowed');
        address signerAddress = getSignerAddress(_feedId);
        if (signerAddress == address(0)) return true;
        return checkSignature(signerAddress, _orgMsg, _msgHash);
    }

    /**
     * @dev Checks the signature validity.
     * @param _address The address of the signer.
     * @param _orgMsg The original message hash.
     * @param _msgHash The signed message hash.
     * @return A boolean indicating whether the signature is valid.
     */
    function checkSignature(address _address, bytes32 _orgMsg, bytes calldata _msgHash) private pure returns (bool) {        
        bytes32 signature = MessageHashUtils.toEthSignedMessageHash(_orgMsg);
        address recovered = ECDSA.recover(signature, _msgHash);
        return recovered == _address;
    }      
}
