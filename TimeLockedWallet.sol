pragma solidity ^0.4.18;

import "https://github.com/radek1st/time-locked-wallets/blob/master/contracts/ERC20.sol";

contract TimeLockedWallet {

    address public creator;
    address public owner;
    uint256 public unlockDate;
    uint256 public gapDate;
    uint256 public createdAt;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyCreator {
        require(msg.sender == creator);
        _;
    }

    function TimeLockedWallet(
        address _creator,
        address _owner,
        uint256 _unlockDate,
        uint256 _gapDate
    ) public {
        creator = _creator;
        owner = _owner;
        unlockDate = _unlockDate;
        gapDate = _gapDate;
        createdAt = now;
    }

    // keep all the ether sent to this address
    function() payable public { 
        Received(msg.sender, msg.value);
    }

    // callable by owner only, after specified time
    function withdraw() onlyOwner public {
       require(now >= unlockDate);
       //now send all the balance
       msg.sender.transfer(this.balance);
       Withdrew(msg.sender, this.balance);
    }

    function backup() onlyCreator public {
       require(now >= unlockDate + gapDate);
       //now send all the balance
       msg.sender.transfer(this.balance);
       Withdrew(msg.sender, this.balance);
    }

    // callable by owner only, after specified time, only for Tokens implementing ERC20
    function withdrawTokens(address _tokenContract) onlyOwner public {
       require(now >= unlockDate);
       ERC20 token = ERC20(_tokenContract);
       //now send all the token balance
       uint256 tokenBalance = token.balanceOf(this);
       token.transfer(owner, tokenBalance);
       WithdrewTokens(_tokenContract, msg.sender, tokenBalance);
    }

    function amountleft() public view returns(uint256) {
        return (this.balance);
    }

    function timeleft() public view returns(uint256) {
        return (unlockDate - now);
    }

    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);
}
