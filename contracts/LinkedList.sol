// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract LinkedList {
    uint256[] private _data;
    mapping(uint256 => uint256) private _next;
    uint256 private _head;
    bool private _isEmpty;

    constructor() {
        _head = 0;
        _isEmpty = true;
    }

    function insertNode(uint256 data) public {
        _data.push(data);

        if (_isEmpty) {
            _head = 0;
            _next[0] = _data.length;  // Point to the end of the array
            _isEmpty = false;
        } else {
            uint256 currentNode = _head;
            while (_next[currentNode] != 0) {
                currentNode = _next[currentNode];
            }
            _next[currentNode] = _data.length - 1;
            _next[_data.length - 1] = _data.length;  // Point to the end of the array
        }
    }

    function printList() public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_data.length);

        if (_isEmpty) {
            return result;
        }

        uint256 currentNode = _head;
        for (uint256 i = 0; i < _data.length; i++) {
            result[i] = _data[currentNode];
            if (_next[currentNode] == _data.length) {  // Reached the end of the list
                break;
            }
            currentNode = _next[currentNode];
        }

        return result;
    }

    function getData(uint256 index) public view returns (uint256) {
        return _data[index];
    }
}
