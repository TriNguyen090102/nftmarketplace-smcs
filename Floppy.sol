//SPDX-License-Identifier: UNLICENSED
pragma solidity <=0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Floppy is ERC20, ERC20Burnable, Ownable {
    uint256 private cap = 50_000_000_000 * 10 ** uint256(18);
    constructor(
        address initialOwner
    ) ERC20("Floppy", "FLP") Ownable(initialOwner) {
        _mint(initialOwner, cap);
        transferOwnership(initialOwner);
    }
    function mint(address to, uint256 amount) public onlyOwner {
        require(ERC20.totalSupply() + amount <= cap, "Floppy: cap exceeded");
        _mint(to, amount);
    }
}
