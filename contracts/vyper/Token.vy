
from vyper.interfaces import ERC20
from vyper.interfaces import ERC20Detailed

implements ERC20
implements ERC20Detailed

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

name: public(String[32]) # 32 chars
symbol: public(String[32])
decimals: public(uint8)

# public functions auto generate getter functions
balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)
minter: address

# external + no return = initializer function
@external 
def __init__(_name: String[32], _symbol: String[32], _decimals: uint8, _supply: uint256):
    init_supply: uint256 = _supply * 10 ** convert(_decimals, uint256)
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.totalSupply = init_supply
    self.balanceOf[msg.sender] = init_supply
    self.minter = msg.sender
    log Transfer(empty(address), msg.sender, init_supply) # emit transfer from null address

@external
def transfer(_to: address, _value: uint256) -> bool:
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    log Transfer(msg.sender, _to, _value)
    return True

# TODO: transferFrom

# TODO: approve


@external
def mint(_to: address, _value: uint256):
    assert msg.sender == self.minter
    assert _to != empty(address)
    self.totalSupply += _value
    self.balanceOf[_to] += _value
    log Transfer(empty(address), _to, _value)