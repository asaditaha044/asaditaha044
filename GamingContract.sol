// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLottery {
    address public owner;
    uint256 public ticketPrice;
    address[] public players;
    uint256 public maxTicketsPerPlayer = 10; // Maximum tickets per player

    event Winner(address winner, uint256 prize);
    event TicketPurchased(address player, uint256 price);
    event TicketPriceUpdated(uint256 newPrice);
    event OwnershipTransferred(address previousOwner, address newOwner);

    constructor(uint256 _ticketPrice) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
    }

    function buyTicket() public payable {
        require(msg.value == ticketPrice && ticketPrice > 0, "Incorrect ticket price");
        require(players.length < maxTicketsPerPlayer, "Maximum tickets per player reached");
        
        players.push(msg.sender);
        emit TicketPurchased(msg.sender, msg.value);
    }

    function drawWinner() public {
        require(msg.sender == owner, "Only owner can draw winner");
        require(players.length > 0, "No players participated");

        uint256 index = random() % players.length;
        address winner = players[index];
        uint256 prize = address(this).balance;

        // Distribute the prize in multiple transactions
        for (uint256 i = 0; i < players.length; i++) {
            (bool success, ) = payable(players[i]).call{value: prize / players.length}("");
            require(success, "Prize transfer failed");
        }

        emit Winner(winner, prize);
        delete players;
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players.length)));
    }

    function updateTicketPrice(uint256 newPrice) public {
        require(msg.sender == owner, "Only owner can update ticket price");
        ticketPrice = newPrice;
        emit TicketPriceUpdated(newPrice);
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
