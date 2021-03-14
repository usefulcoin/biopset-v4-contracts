pragma solidity ^0.6.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./BIOPToken.sol";
import "./ContinuousToken/curves/BancorBondingCurve.sol";
contract BIOPTokenV4 is BancorBondingCurve, ERC20 {
    using SafeMath for uint256;
    address public bO = 0x0000000000000000000000000000000000000000;//binary options
    address payable dao = 0x0000000000000000000000000000000000000000;
    bool dxR = false;//dex reward started
    bool ibcod = false;//ibco started
    address public v3;
    uint256 public lEnd;//launch end
    uint256 public epoch = 0; //rewards epoch 
    uint256 public eS;//end of current epoch
    uint256 public perE = 92857142857142850000000000000;//rewards per epoch (650000000000000000000000000000 total)
    uint256 public tTE;//claims left this epoch
    uint256 public tbca =250000000000000000000000000000;//total bonding curve available
                                      

    uint256 public soldAmount = 0;
    uint256 public buyFee = 2;//10th of percent
    uint256 public sellFee = 0;//10th of percent

    constructor(string memory name_, string memory symbol_, address v3_,  uint32 _reserveRatio) public ERC20(name_, symbol_) BancorBondingCurve(_reserveRatio) {
      dao = msg.sender;
      v3_ = v3_;
      lEnd = block.timestamp + 6 days;
      _mint(msg.sender, 100000);
      soldAmount = 100000;
      eS = block.timestamp + 30 days;
      tTE = 92857142857142850000000000000;
    }


    
    modifier onlyBinaryOptions() {
        require(bO == msg.sender, "Ownable: caller is not the Binary Options Contract");
        _;
    }
    modifier onlyGov() {
        require(dao == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /** 
     * @dev transfer ownership of this contract
     * @param g_ the new governance address
     */
    function transferGovernance(address payable g_) external onlyGov {
        require(g_ != 0x0000000000000000000000000000000000000000);
        dao = g_;
    }

    /** 
     * @dev a one time function to setup governance. can only be set once
     * @param d_ the address of dex rewards contract
     */
    function setupDEXRewards(address payable d_) external onlyGov {
        require(d_ != 0x0000000000000000000000000000000000000000);
        require(dxR == false);
        dxR = true;
        _mint(d_, 80000000000000000000000000000);
    }

    /** 
     * @dev a one time function to setup governance. can only be set once
     * @param d_ the address of dex rewards contract
     */
    function setupIBCO(address payable d_) external onlyGov {
        require(d_ != 0x0000000000000000000000000000000000000000);
        require(ibcod == false);
        ibcod = true;
        _mint(d_, 250000000000000000000000000000);
    }

    /** 
     * @dev set the fee users pay in ETH to buy BIOP from the bonding curve
     * @param newFee_ the new fee (in tenth percent) for buying on the curve
     */
    function updateBuyFee(uint256 newFee_) external onlyGov {
        require(newFee_ > 0 && newFee_ < 40, "invalid fee");
        buyFee = newFee_;
    }

    /**
     * @dev set the fee users pay in ETH to sell BIOP to the bonding curve
     * @param newFee_ the new fee (in tenth percent) for selling on the curve
     **/
    function updateSellFee(uint256 newFee_) external onlyGov {
        require(newFee_ > 0 && newFee_ < 40, "invalid fee");
        sellFee = newFee_;
    } 

    /**
     * @dev called by the binary options contract to update a users Reward claim
     * @param amount the amount in BIOP to add to this users pending claims
     **/
    function updateEarlyClaim(uint256 amount) external onlyBinaryOptions {
        if (lEnd < block.timestamp) {
            updateEpoch(amount.mul(8));
            _mint(tx.origin, amount.mul(8));
        } else {
            updateEpoch(amount);
            _mint(tx.origin, amount);
        }
    }

    //epochs run 30 days. except the final epoch that goes on until rewards run out.
    // unused rewards are rolled over into the next epoch.
    function updateEpoch(uint256 amount) internal {
            require(tTE.sub(amount) >= 0, "insufficent claims avail");
            tTE = tTE.sub(amount);
            if (block.timestamp > eS && epoch < 7) {
                //every 30 days the next epoch can begin
                epoch = epoch.add(1);
                eS = block.timestamp + 30 days;
                tTE = perE.add(tTE);
            }
    }
     /**
     * @notice one time function used at deployment to configure the connected binary options contract
     * @param options_ the address of the binary options contract
     */
    function setupBinaryOptions(address payable options_) external onlyGov {
        bO = options_;
    }

    /**
     * @dev one time swap of v3 to v4 tokens
     * @notice all v3 tokens will be swapped to v4. This cannot be undone
     */
    function swapv3v4() external {
        BIOPToken b3 = BIOPToken(v3);
        uint256 balance = b3.balanceOf(msg.sender);
        require(balance >= 0, "insufficent biopv2 balance");
        require(b3.transferFrom(msg.sender, address(this), balance), "transfer failed");
        _mint(msg.sender, balance);
    }


    


    //bonding curve functions

     /**
    * @dev method that returns BIOP amount sold by curve
    */   
    function continuousSupply() public override view returns (uint) {
        return soldAmount;
    }

    /**
    * @dev method that returns curves ETH (reserve) balance
    */    
    function reserveBalance() public override view returns (uint) {
        return address(this).balance;
    }

    /**
     * @notice purchase BIOP from the bonding curve. 
     the amount you get is based on the amount in the pool and the amount of eth u send.
     */
     function buy() public payable {
        uint256 purchaseAmount = msg.value;
        
         if (buyFee > 0) {
            uint256 fee = purchaseAmount.div(buyFee).div(100);
            require(dao.send(fee), "buy fee transfer failed");
            purchaseAmount = purchaseAmount.sub(fee);
        } 
        uint rewardAmount = getContinuousMintReward(purchaseAmount);
        require(soldAmount.add(rewardAmount) <= tbca, "maximum curve minted");
        
        _mint(msg.sender, rewardAmount);
        soldAmount = soldAmount.add(rewardAmount);
    }

    
     /**
     * @notice sell BIOP to the bonding curve
     * @param amount the amount of BIOP to sell
     */
     function sell(uint256 amount) public returns (uint256){
        require(balanceOf(msg.sender) >= amount, "insufficent BIOP balance");

        uint256 ethToSend = getContinuousBurnRefund(amount);
        if (sellFee > 0) {
            uint256 fee = ethToSend.div(buyFee).div(100);
            require(dao.send(fee), "buy fee transfer failed");
            
            ethToSend = ethToSend.sub(fee);
        }
        soldAmount = soldAmount.sub(amount);
        _burn(msg.sender, amount);
        require(msg.sender.send(ethToSend), "transfer failed");
        return ethToSend;
        }
}
