// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    // State Variables
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    // Events
    event Claim(address indexed account, uint256 amount);
    // Errors
    error MerkleAirdrop_InvalidProof();

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        // 1. Calculate the leaf node hash
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        // 2. Verify the Merkle Proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop_InvalidProof();
        }
        // (We'll add a check here later to prevent double claims)
        // 3. Emit event
        emit Claim(account, amount);
        // 4. Transfer tokens
        i_airdropToken.safeTransfer(account, amount);
    }
}
