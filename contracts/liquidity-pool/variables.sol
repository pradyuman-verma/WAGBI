//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from '../dependencies/IERC20.sol';

contract Variables {
    // TOKENS
    // weth
    address internal immutable WETH_ADDR;
    uint256 internal immutable WETH_DECIMALS;
    uint256 internal immutable WETH_BORROW_ALLOWANCE;

    // usdc
    address internal immutable USDC_ADDR;
    uint256 internal immutable USDC_DECIMALS;
    uint256 internal immutable USDC_BORROW_ALLOWANCE;

    // dai
    address internal immutable DAI_ADDR;
    uint256 internal immutable DAI_DECIMALS;
    uint256 internal immutable DAI_BORROW_ALLOWANCE;

    // wbtc
    address internal immutable WBTC_ADDR;
    uint256 internal immutable WBTC_DECIMALS;
    uint256 internal immutable WBTC_BORROW_ALLOWANCE;

    // RATE CURVE DATA (Common for all tokens for MVP)
    uint256 internal constant SLOPE_1 = 1585489599; // slope is in 18 decimals
    uint256 internal constant CONSTANT_1 = 0;
    uint256 internal constant SIGN_1 = 1;
    uint256 internal constant KINK = 10000; // 10000 => 100%
    uint256 internal constant SLOPE_2 = 0;
    uint256 internal constant CONSTANT_2 = 0;
    uint256 internal constant SIGN_2 = 0;
    uint256 internal constant FEE = 0; // 10000 => 100%

    // POOL DATA
    // borrowing wont be allowed above borrow utilization cap
    uint256 internal constant BORROW_UTILIZATION_CAP = 9.5e7; // 95%
    // supply wont be allowed above raw supply cap
    uint256 internal constant RAW_SUPPLY_CAP = 5.76e17;
    // borrow wont be allowed above raw borrow cap
    uint256 internal constant RAW_BORROW_CAP = 2.88e17;

    // MARKETS
    address internal immutable OC_MARKET_ADDR;
    address internal immutable UC_MARKET_ADDR;

    // STORAGE VARIABLES

    // status = 2 throws
    uint256 internal _status;

    // authority
    address public auth;

    // Exchange prices of tokens stored in single uint
    // token => exchange prices
    // 6 things stored in 256 bits:-
    // Next 27 bits => 0-26 => utilization (sufficient as it will be always be <= 1e8)
    // Next 32 bits => 27-58 => last update timestamp (sufficient for 83 years after deployment)
    // Next 40 bits => 59-98 => supply exchange price (sufficient as it will be <= 1e12)
    // Next 40 bits => 99-138 => borrow exchange price (sufficient as it will be <= 1e12)
    // Next 59 bits => 139-197 => total raw supply (sufficient with raw supply cap; raw supply <= 5.76e17)
    // Last 58 bits => 198-255 => total raw borrow (sufficient with raw borrow cap; raw borrow <= 2.88e17)
    mapping(address => uint256) public _poolData;

    // protocol => token => protocol data (token specific)
    // 2 things stored in a single uint:-
    // First 1 bit => 0 => token supply allowance (1 -> allowed, 0 -> not allowed)
    // Next 58 bit => 1-58 => token borrow allowance
    // Last 197 bits blank
    mapping(address => mapping(address => uint256)) public _protocolData;

    // Whitelisted user is mapped to the protocol which whitelisted it
    // Parameters of user's interaction with liquidity contracts depend upon the protocol which whitlisted it
    // user => protocol
    mapping(address => address) public _userToProtocol;

    // User data
    // user => token => uint
    // 2 things stored in a single uint:-
    // First 59 bits => 0-58 => user raw supply (raw supply = totalSupply / supplyExchangePrice)
    // Next 58 bits => 59-116 => user raw borrow (raw borrow = totalBorrow / borrowExchangePrice)
    // Last 139 bits blank
    mapping(address => mapping(address => uint256)) public _userData;

    constructor(
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_,
        address oc_,
        address uc_
    ) {
        WETH_ADDR = wethAddr_;
        WETH_DECIMALS = IERC20(WETH_ADDR).decimals();
        WETH_BORROW_ALLOWANCE = 5 * (10**(WETH_DECIMALS + 9));
        USDC_ADDR = usdcAddr_;
        USDC_DECIMALS = IERC20(USDC_ADDR).decimals();
        USDC_BORROW_ALLOWANCE = 5 * (10**(USDC_DECIMALS + 9));
        DAI_ADDR = daiAddr_;
        DAI_DECIMALS = IERC20(DAI_ADDR).decimals();
        DAI_BORROW_ALLOWANCE = 5 * (10**(DAI_DECIMALS + 9));
        WBTC_ADDR = wbtcAddr_;
        WBTC_DECIMALS = IERC20(WBTC_ADDR).decimals();
        WBTC_BORROW_ALLOWANCE = 5 * (10**(WBTC_DECIMALS + 9));
        OC_MARKET_ADDR = oc_;
        UC_MARKET_ADDR = uc_;
    }
}
