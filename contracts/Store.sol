// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Store {

    // A store for digital items with a payable manager

    struct Item {
        string name;
        uint256 id;
        uint256 price;
        bool isSold;
    }

    Item[] inventory;
    address payable manager;

    event AddedItem(string indexed name, uint256 indexed id, uint256 price);
    event UpdatedManager(address newManager);   

    constructor() {
        manager = payable(msg.sender);
    }

    function addToInventory(string memory _name, uint256 _id, uint256 _price) public onlyManager {
        inventory.push(Item(_name, _id, _price, false));
        emit AddedItem(_name, _id, _price);
    }

    function getInventoryCount() public view returns (uint256) {
    return inventory.length;
    }

    function getItem(uint256 index) public view returns (string memory, uint256, uint256, bool) {
        Item memory item = inventory[index];
        return (item.name, item.id, item.price, item.isSold);
    }

    function buy(uint256 _id) public payable {
        require(_id < inventory.length, "Not a valid ID");
        require(!inventory[_id].isSold, "Item not available");
        require(msg.value >= inventory[_id].price, "Not enough funds");
        inventory[_id].isSold = true;

        manager.transfer(inventory[_id].price);

        if(msg.value > inventory[_id].price){
            payable(msg.sender).transfer(msg.value - inventory[_id].price);
        }

    }

    modifier onlyManager() {
        require(msg.sender == manager, "You are not the manager");
        _;
    }

    function updateManager(address payable _newManager) public onlyManager(){
        manager = _newManager;
        emit UpdatedManager( _newManager);
    }

}