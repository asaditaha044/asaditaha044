// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLottery {
    address public owner;
    uint256 public ticketPrice;
    address[] public players;

    event Winner(address winner, uint256 prize);
    event TicketPurchased(address player, uint256 price);

    constructor(uint256 _ticketPrice) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
    }

    function buyTicket() public payable {
        require(msg.value == ticketPrice && ticketPrice > 0, "Incorrect ticket price");
        players.push(msg.sender);
        emit TicketPurchased(msg.sender, msg.value);
    }

    function drawWinner() public {
        require(msg.sender == owner, "Only owner can draw winner");
        require(players.length > 0, "No players participated");

        uint256 index = random() % players.length;
        address winner = players[index];
        uint256 prize = address(this).balance;
        (bool success, ) = payable(winner).call{value: prize}("");
        require(success, "Prize transfer failed");

        emit Winner(winner, prize);
        delete players;
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players.length)));
    }
}
