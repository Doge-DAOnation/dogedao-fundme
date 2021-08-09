// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20F.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract DDToken is ERC20F, Ownable {
    address private immutable lge; // LGE Contract's address
    address private immutable dfm; // DFM Contract's address
    address private immutable rwd; // Reward Contract's address
    address private immutable don; // Donation Contract's address

    constructor(
        address _lge,
        address _dfm,
        address _rwd,
        address _don
    ) ERC20F("DogeFundMe", "DD", 200) {
        // 200 means 2% for fee expression, 2 equals 0.02%
        lge = _lge;
        dfm = _dfm;
        rwd = _rwd;
        don = _don;
        // mint 9.125 trillion
        uint256 initialSupply = 9.125e12 * (10**decimals());
        _mint(_lge, (initialSupply * 88) / 100);
        _mint(owner(), (initialSupply * 12) / 100);
    }

    function decimals() public pure override returns (uint8) {
        return 8;
    }

    function _storeFee(uint256 fee) private {
        uint256 dfmShare = (fee * 80) / 100;
        unchecked {
            _balances[rwd] += fee - dfmShare;
        }
        _balances[dfm] += dfmShare;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        uint256 fee;
        (, fee) = _calculateFee(amount);
        _mint(don, amount);
        unchecked {
            _balances[don] -= fee;
        }
        _storeFee(fee);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        uint256 fee = _transfer(_msgSender(), recipient, amount);
        _storeFee(fee);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 fee = _transfer(sender, recipient, amount);
        _storeFee(fee);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(
            currentAllowance >= amount,
            "DDToken: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
}
