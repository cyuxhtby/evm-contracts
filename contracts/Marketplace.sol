// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Marketplace{
    struct Item{
        uint256 id;
        string name;
        address payable seller;
        uint256 price;
        bool isSold;
    }

    Item[] public items;
    address public deployer;

    // The indexed keyword makes the specified parameters searchable in the event logs for searching/filtering events
    event ItemAdded(uint256 indexed itemId, string name, address seller, uint256 price);
    event ItemSold(uint256 indexed itemId, string name, address buyer, uint256 price);

    constructor(){
        deployer = msg.sender;
    }

    function addItem(string memory _name, uint256 _price) public{
        require(_price > 0, "price must be greater than zero");
        uint256 itemId = items.length;
        items.push(Item(itemId, _name, payable(msg.sender), _price, false ));
        emit ItemAdded(itemId, _name, msg.sender, _price);
    }

    // The storage keyword allows `item` to directly access and update the corresponding item in the `items` array.
    function buyItem(uint256 _itemId) public payable{
        require(_itemId < items.length, "Not a valid item ID");
        Item storage item = items[_itemId];
        require(!item.isSold, "The item is no longer available");
        require(msg.value >= item.price, "Insufficient funds");

        item.isSold = true;
        item.seller.transfer(item.price);
        emit ItemSold(_itemId, item.name, msg.sender, item.price);
    }

    function getItem(uint256 _itemId) public view returns (string memory, address, uint256, bool){
        require(_itemId < items.length, "Not a valid item ID");
        Item memory item = items[_itemId];
        return (item.name, item.seller, item.price, item.isSold);
    }

    function getItemCount() public view returns (uint256){
        return items.length;
    }

    function removeItem(uint256 _itemId) public onlySeller(_itemId) {
        items[_itemId] = items[items.length - 1];
        items.pop();
    }

    modifier onlySeller(uint256 _itemId){
        require(_itemId < items.length, "Not a valid item ID");
        require(msg.sender == items[_itemId].seller, "Only the seller can call this function");
        _;
    }
}
