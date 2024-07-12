// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.23;

import "../StNEO.sol";

/**
 * @dev Only for testing purposes!
 * StNEO mock version of mintable/burnable/stoppable token.
 */
contract StNEOMock is StNEO {
    uint256 private totalPooledEther;

    constructor() payable {
        _resume();
        // _bootstrapInitialHolder
        uint256 balance = address(this).balance;
        assert(balance != 0);

        // address(0xdead) is a holder for initial shares
        setTotalPooledEther(balance);
        _mintInitialShares(balance);
    }

    function _getTotalPooledEther() override internal view returns (uint256) {
        return totalPooledEther;
    }

    function stop() external {
        _stop();
    }

    function resume() external {
        _resume();
    }

    function setTotalPooledEther(uint256 _totalPooledEther) public {
        totalPooledEther = _totalPooledEther;
    }

    function mintShares(address _to, uint256 _sharesAmount) public returns (uint256 newTotalShares) {
        newTotalShares = _mintShares(_to, _sharesAmount);
        _emitTransferAfterMintingShares(_to, _sharesAmount);
    }

    function mintStNEO(address _to) public payable  {
        uint256 sharesAmount = getSharesByPooledEth(msg.value);
        mintShares(_to, sharesAmount);
        setTotalPooledEther(_getTotalPooledEther() + msg.value);
    }

    function burnShares(address _account, uint256 _sharesAmount) public returns (uint256 newTotalShares) {
        return _burnShares(_account, _sharesAmount);
    }
}
