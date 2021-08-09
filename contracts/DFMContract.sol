//"SPDX-License-Identifier: MIT"
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./LGEContract.sol";

contract DFMContract is LGEContract {
    mapping(address => uint256) donations;

    modifier whenDfmAlive() {
        require(dfmOpened, "DFM-Dfm: has not yet opened");
        _;
    }

    modifier acceptable(address token) {
        require(
            token == WETH || token == DAI || token == WBTC || token == USDC,
            "no acceptable token"
        );
        _;
    }

    function donate(address token, uint256 amount)
        external
        whenDfmAlive
        acceptable(token)
        returns (bool)
    {
        require(amount > 0, "DFM-Dfm: can't donate with zero");

        IERC20(token).transferFrom(_msgSender(), address(this), amount);
        donations[token] += amount;

        return true;
    }

    function setBalancerSwapFee(uint256 swapFeePercentage) public onlyOwner whenDfmAlive {
        IWeightedPool(balancerPool).setSwapFeePercentage(swapFeePercentage);
    }
}
