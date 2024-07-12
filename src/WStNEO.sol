// SPDX-License-Identifier: MIT AND GPL-3.0
pragma solidity 0.8.23;

import "openzeppelin-contracts/contracts/utils/Context.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

interface IStNEO is IERC20 {
    function getPooledEthByShares(uint256 _sharesAmount) external view returns (uint256);

    function getSharesByPooledEth(uint256 _pooledEthAmount) external view returns (uint256);

    function submit(address _referral) external payable returns (uint256);
}

contract WstNEO is ERC20Permit {
    IStNEO public stNEO;

    /**
     * @param _stNEO address of the stNEO token to wrap
     */
    constructor(IStNEO _stNEO)
        ERC20Permit("Wrapped liquid staked Ether 2.0")
        ERC20("Wrapped liquid staked Ether 2.0", "wstNEO")
    {
        stNEO = _stNEO;
    }

    /**
     * @notice Exchanges stNEO to wstNEO
     * @param _stNEOAmount amount of stNEO to wrap in exchange for wstNEO
     * @dev Requirements:
     *  - `_stNEOAmount` must be non-zero
     *  - msg.sender must approve at least `_stNEOAmount` stNEO to this
     *    contract.
     *  - msg.sender must have at least `_stNEOAmount` of stNEO.
     * User should first approve _stNEOAmount to the WstNEO contract
     * @return Amount of wstNEO user receives after wrap
     */
    function wrap(uint256 _stNEOAmount) external returns (uint256) {
        require(_stNEOAmount > 0, "wstNEO: can't wrap zero stNEO");
        uint256 wstNEOAmount = stNEO.getSharesByPooledEth(_stNEOAmount);
        _mint(msg.sender, wstNEOAmount);
        stNEO.transferFrom(msg.sender, address(this), _stNEOAmount);
        return wstNEOAmount;
    }

    /**
     * @notice Exchanges wstNEO to stNEO
     * @param _wstNEOAmount amount of wstNEO to uwrap in exchange for stNEO
     * @dev Requirements:
     *  - `_wstNEOAmount` must be non-zero
     *  - msg.sender must have at least `_wstNEOAmount` wstNEO.
     * @return Amount of stNEO user receives after unwrap
     */
    function unwrap(uint256 _wstNEOAmount) external returns (uint256) {
        require(_wstNEOAmount > 0, "wstNEO: zero amount unwrap not allowed");
        uint256 stNEOAmount = stNEO.getPooledEthByShares(_wstNEOAmount);
        _burn(msg.sender, _wstNEOAmount);
        stNEO.transfer(msg.sender, stNEOAmount);
        return stNEOAmount;
    }

    /**
    * @notice Shortcut to stake ETH and auto-wrap returned stNEO
    */
    receive() external payable {
        uint256 shares = stNEO.submit{value: msg.value}(address(0));
        _mint(msg.sender, shares);
    }

    /**
     * @notice Get amount of wstNEO for a given amount of stNEO
     * @param _stNEOAmount amount of stNEO
     * @return Amount of wstNEO for a given stNEO amount
     */
    function getWstNEOBystNEO(uint256 _stNEOAmount) external view returns (uint256) {
        return stNEO.getSharesByPooledEth(_stNEOAmount);
    }

    /**
     * @notice Get amount of stNEO for a given amount of wstNEO
     * @param _wstNEOAmount amount of wstNEO
     * @return Amount of stNEO for a given wstNEO amount
     */
    function getstNEOByWstNEO(uint256 _wstNEOAmount) external view returns (uint256) {
        return stNEO.getPooledEthByShares(_wstNEOAmount);
    }

    /**
     * @notice Get amount of stNEO for a one wstNEO
     * @return Amount of stNEO for 1 wstNEO
     */
    function stNEOPerToken() external view returns (uint256) {
        return stNEO.getPooledEthByShares(1 ether);
    }

    /**
     * @notice Get amount of wstNEO for a one stNEO
     * @return Amount of wstNEO for a 1 stNEO
     */
    function tokensPerstNEO() external view returns (uint256) {
        return stNEO.getSharesByPooledEth(1 ether);
    }
}

