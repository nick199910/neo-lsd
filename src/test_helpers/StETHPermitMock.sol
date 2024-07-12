// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.23;

import "../StNEOPermit.sol";
import "./StNEOMock.sol";

/**
 * @dev Only for testing purposes!
 * StNEOPermit mock version of mintable/burnable/stoppable token.
 */
contract StNEOPermitMock is StNEOPermit, StNEOMock {
    constructor() payable StNEOMock() {
  
    }
    
    function initializeEIP712StETH(address _eip712StNEO) external {
        _initializeEIP712StETH(_eip712StNEO);
    }

    function getBlockTime() external view returns (uint256) {
        return block.timestamp;
    }
}
