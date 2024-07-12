// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "src/test_helpers/StETHPermitMock.sol";
import "../src/StNEOPermit.sol";

contract StNEOPermitTest is Test {
    StNEOPermitMock private stNEOPermit;
    address private alice;
    address private bob;
    address private charlie;
    uint256 private deadline;
    bytes32 private domainSeparator;
    uint256 private nonce;
    bytes32 PERMIT_TYPEHASH =
    0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;


    function setUp() public {
        stNEOPermit = new StNEOPermitMock{value: 1 ether}();
        alice = vm.addr(1);
        bob = vm.addr(2);
        charlie = vm.addr(3);

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(charlie, "Charlie");

        // Setup deadline to be a future time
        deadline = block.timestamp + 1 days;
        domainSeparator = PERMIT_TYPEHASH;

        // Fund Alice with tokens
        vm.deal(alice, 10 ether);
        stNEOPermit.mintShares(alice, 10 ether);
    }

    // function testValidPermit() public {
    //     uint256 value = 1 ether;
    //     nonce = stNEOPermit.nonces(alice);

    //     // Alice signing the permit
    //     bytes32 digest = keccak256(abi.encodePacked(
    //         "\x19\x01",
    //         domainSeparator,
    //         keccak256(abi.encode(
    //             PERMIT_TYPEHASH,
    //             alice,
    //             bob,
    //             value,
    //             nonce,
    //             deadline
    //         ))
    //     ));

    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint160(alice), digest);

    //     // Charlie submits the permit on behalf of Alice
    //     vm.prank(charlie);
    //     stNEOPermit.permit(alice, bob, value, deadline, v, r, s);

    //     // Validate the new allowance and nonce
    //     assertEq(stNEOPermit.allowance(alice, bob), value);
    //     assertEq(stNEOPermit.nonces(alice), nonce + 1);
    // }

    // function testRevertInvalidSignature() public {
    //     uint256 value = 1 ether;
    //     nonce = stNEOPermit.nonces(alice);

    //     // Generate an invalid signature
    //     bytes32 digest = keccak256(abi.encodePacked(
    //         "\x19\x01",
    //         domainSeparator,
    //         keccak256(abi.encode(
    //             PERMIT_TYPEHASH,
    //             alice,
    //             bob,
    //             value,
    //             nonce,
    //             deadline
    //         ))
    //     ));

    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint160(bob), digest); // Bob signs instead of Alice

    //     vm.expectRevert("INVALID_SIGNATURE");
    //     stNEOPermit.permit(alice, bob, value, deadline, v, r, s);
    // }

    // function testRevertExpiredPermit() public {
    //     uint256 value = 1 ether;
    //     nonce = stNEOPermit.nonces(alice);
    //     uint256 expiredDeadline = block.timestamp - 10; // Expired deadline

    //     // Alice signing the permit
    //     bytes32 digest = keccak256(abi.encodePacked(
    //         "\x19\x01",
    //         domainSeparator,
    //         keccak256(abi.encode(
    //             PERMIT_TYPEHASH,
    //             alice,
    //             bob,
    //             value,
    //             nonce,
    //             expiredDeadline
    //         ))
    //     ));

    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint160(alice), digest);

    //     vm.expectRevert("DEADLINE_EXPIRED");
    //     stNEOPermit.permit(alice, bob, value, expiredDeadline, v, r, s);
    // }

    // function testNonSequentialNonce() public {
    //     uint256 value = 1 ether;
    //     nonce = 1 + stNEOPermit.nonces(alice);  // Use a future nonce

    //     // Alice signing the permit with an incorrect nonce
    //     bytes32 digest = keccak256(abi.encodePacked(
    //         "\x19\x01",
    //         domainSeparator,
    //         keccak256(abi.encode(
    //             PERMIT_TYPEHASH,
    //             alice,
    //             bob,
    //             value,
    //             nonce,
    //             deadline
    //         ))
    //     ));

    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint160(alice), digest);

    //     vm.expectRevert("INVALID_SIGNATURE");
    //     stNEOPermit.permit(alice, bob, value, deadline, v, r, s);
    // }
}
