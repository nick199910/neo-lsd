// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/test_helpers/StNEOMock.sol"; 

contract StNEOTest is Test {
    StNEOMock private stNEO;
    address private user1 = address(0x123);
    address private user2 = address(0x456);
    address private user3 = address(0x789);
    address private nobody = address(0x101);
    address private initialHolder = address(0xdead);
    address private constant ZERO_ADDRESS = address(0);
    uint256 private constant MAX_UINT256 = type(uint256).max;

    function setUp() public {
        stNEO = new StNEOMock{value: 1 ether}();
        vm.deal(address(this), 100 ether);
    }

    // ERC20 Information Checks
    function testTokenInfo() public view {
        assertEq(stNEO.name(), "Liquid staked NEO 1.0");
        assertEq(stNEO.symbol(), "stNEO");
        assertEq(stNEO.decimals(), 18);
    }

    // Initial Balances and Allowances
    function testInitialBalancesAndAllowances() public view {
        assertEq(stNEO.totalSupply(), 1 ether);
        assertEq(stNEO.balanceOf(user1), 0);
        assertEq(stNEO.allowance(user1, user2), 0);
    }

    // Testing approve functionality
    function testApproveAndAllowances() public {
        vm.prank(user1);
        stNEO.approve(user2, 1 ether);
        assertEq(stNEO.allowance(user1, user2), 1 ether);
    }

    // Fail transfer to zero address
    function testFailTransferToZeroAddress() public {
        vm.prank(user1);
        stNEO.transfer(ZERO_ADDRESS, 1 ether);
        vm.expectRevert("TRANSFER_TO_ZERO_ADDR");
    }

    // Revert on insufficient balance
    function testRevertTransferInsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert("BALANCE_EXCEEDED");
        stNEO.transfer(user2, 2 ether); // only 1 ether is set initially

    }

    // Increase and decrease allowance
    function testIncreaseAndDecreaseAllowance() public {
        vm.startPrank(user1);
        stNEO.approve(user2, 50 ether);
        stNEO.increaseAllowance(user2, 50 ether);
        assertEq(stNEO.allowance(user1, user2), 100 ether);

        stNEO.decreaseAllowance(user2, 20 ether);
        assertEq(stNEO.allowance(user1, user2), 80 ether);
        vm.stopPrank();
    }

    // Transfers with zero tokens
    function testTransferZeroTokens() public {
        vm.prank(user1);
        stNEO.transfer(user2, 0);
        assertEq(stNEO.balanceOf(user2), 0);
    }

    // Stop and resume contract functionality
    function testStopAndResumeContract() public {
        stNEO.setTotalPooledEther(100 ether);
        stNEO.mintShares(user1, 99 ether);
        vm.prank(user1);
        stNEO.stop();
        vm.expectRevert("CONTRACT_IS_STOPPED");
        stNEO.transfer(user2, 1 ether);
      
        vm.prank(user1);
        stNEO.resume();
        vm.prank(user1);
        stNEO.transfer(user2, 1 ether);
        assertEq(stNEO.balanceOf(user2), 1 ether);
    }

    // Behavior after slashing
    function testBehaviorAfterSlashing() public {
        vm.prank(user1);
        stNEO.approve(user2, 1 ether);
        stNEO.setTotalPooledEther(0.5 ether);
        vm.prank(user2);
        vm.expectRevert("BALANCE_EXCEEDED");
        stNEO.transferFrom(user1, user3, 1 ether);

    }

    // Minting new shares
    function testMintingShares() public {
        stNEO.setTotalPooledEther(100 ether);
        stNEO.mintShares(user1, 99 ether);

        stNEO.mintShares(user1, 12 ether);
        stNEO.setTotalPooledEther(112 ether);

        assertEq(stNEO.totalSupply(), 112 ether);
        assertEq(stNEO.balanceOf(user1), 111 ether);
        assertEq(stNEO.balanceOf(user2), 0 ether);
        assertEq(stNEO.getTotalShares(), 112 ether);
        assertEq(stNEO.sharesOf(user1), 111 ether);
        assertEq(stNEO.sharesOf(user2), 0 ether);

        stNEO.mintShares(user2, 4 ether);
        stNEO.setTotalPooledEther(116 ether);

        assertEq(stNEO.totalSupply(), 116 ether);
        assertEq(stNEO.balanceOf(user1), 111 ether);
        assertEq(stNEO.balanceOf(user2), 4 ether);
        assertEq(stNEO.getTotalShares(), 116 ether);
        assertEq(stNEO.sharesOf(user1), 111 ether);
        assertEq(stNEO.sharesOf(user2), 4 ether);
    }

    // // Burning shares
    function testBurningRedistributesTokens() public {
        // user1 already had 99 tokens
        // 1 + 99 + 100 + 100 = 300
        stNEO.setTotalPooledEther(100 ether);
        stNEO.mintShares(user1, 99 ether);

        stNEO.setTotalPooledEther(300 ether);
        stNEO.mintShares(user2, 100 ether);
        stNEO.mintShares(user3, 100 ether);

        uint256 totalShares = stNEO.getTotalShares();
        uint256 totalSupply = stNEO.totalSupply();
        uint256 user2Balance = stNEO.balanceOf(user2);
        uint256 user2Shares = stNEO.sharesOf(user2);

        // Calculate the amount of shares to burn based on the formula used in Hardhat test
        uint256 sharesToBurn = totalShares - (totalSupply * (totalShares - user2Shares) / (totalSupply - user2Balance + 10 ether));

        // Expected amounts before and after the burn
        stNEO.getPooledEthByShares(sharesToBurn);
        vm.prank(user2);
        stNEO.burnShares(user2, sharesToBurn);
        stNEO.getPooledEthByShares(sharesToBurn);

        // Check all conditions after burning
        assertEq(stNEO.totalSupply(), 300 ether); // Assuming total supply should stay the same based on your context setup
        assertEq(stNEO.balanceOf(user1) + stNEO.balanceOf(initialHolder), 105 ether); // Ensure the balance is correctly redistributed
        assertEq(stNEO.balanceOf(user2), 90 ether - 1); // Assuming an expected round error as stated
        assertEq(stNEO.balanceOf(user3), 105 ether);
        assertEq(stNEO.getTotalShares(), 285714285714285714285);
        assertEq(stNEO.sharesOf(initialHolder), 1 ether);
        assertEq(stNEO.sharesOf(user1), 99 ether);
        assertEq(stNEO.sharesOf(user2), 85714285714285714285);
        assertEq(stNEO.sharesOf(user3), 100 ether);
    }

    function testTransferSharesFrom() public {
        stNEO.setTotalPooledEther(100 ether);
        stNEO.mintShares(user1, 99 ether);

        // Initial checks for balances
        assertEq(stNEO.balanceOf(user1), 99 ether);
        assertEq(stNEO.balanceOf(nobody), 0 ether);

        // Setup user2 as an approved spender but with no allowance initially
        vm.prank(user1);
        stNEO.approve(user2, 0);

        // Test transfer of 0 tokens
        vm.startPrank(user2);
        stNEO.transferSharesFrom(user1, nobody, 0);
        assertEq(stNEO.balanceOf(nobody), 0 ether);
        assertEq(stNEO.balanceOf(user1), 99 ether);
        vm.stopPrank();

        // Should revert due to allowance exceeded
        vm.startPrank(user2);
        vm.expectRevert("ALLOWANCE_EXCEEDED");
        stNEO.transferSharesFrom(user1, nobody, 30 ether);
        vm.stopPrank();

        // Approve and perform a valid transfer
        vm.prank(user1);
        stNEO.approve(user2, 30 ether);

        vm.startPrank(user2);
        stNEO.transferSharesFrom(user1, nobody, 30 ether);
        assertEq(stNEO.balanceOf(nobody), 30 ether);
        assertEq(stNEO.balanceOf(user1), 69 ether); // 99 - 30
        vm.stopPrank();

        // Check for reversion due to balance exceeded after reducing balance
        vm.prank(user1);
        stNEO.approve(user2, 75 ether);
        
        vm.startPrank(user2);
        vm.expectRevert("BALANCE_EXCEEDED");
        stNEO.transferSharesFrom(user1, nobody, 75 ether);
        vm.stopPrank();

        // Increasing the total pooled ether to see effect on balances and allowances
        stNEO.setTotalPooledEther(120 ether); // Assume this affects shares somehow
        vm.prank(user1);
        stNEO.approve(user2, 84 ether);

        // Finally transfer shares that are available
        vm.startPrank(user2);
        stNEO.transferSharesFrom(user1, nobody, 69 ether); // Now should work as allowance and balance are sufficient
        assertEq(stNEO.balanceOf(user1), 0 ether); // All transferred out
        assertEq(stNEO.balanceOf(nobody), 118.8 ether); 
        vm.stopPrank();

    }
}
