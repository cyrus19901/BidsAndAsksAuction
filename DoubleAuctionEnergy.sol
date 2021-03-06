contract DoubleAuction {
    
    struct Buyer {
        address owner;
        uint price;
        uint amount;
        uint date;
        uint deposit;
    }
    struct Seller {
        address owner;
        uint price;
        uint amount_promised;
        uint amount_produced;
        uint date;
        uint deposit;
    }
    
    struct Utility{
        address owner;
        uint price;
        uint date;
    }
    uint deposit_amount=500;
    uint bid_period;
    
    Utility public UtilityLedger;
    Buyer[] public BidLedger;
    Seller[] public AskLedger;
    
    mapping (address => uint) public balances;
    event Sent(address from , address to, uint amount);
    function submitBidBuyer(uint _price, uint _amount, address _owner)  returns (bool) {
        Buyer memory b;
        b.price = _price;
        b.amount = _amount;
        b.owner = _owner;
        b.date = now;
        b.deposit = deposit_amount;
        for(uint i = 0; i < BidLedger.length; i++) {
            if (BidLedger[i].price > _price && BidLedger[i].date < BidLedger[0].date+ 900) {
                Buyer[] memory tempLedger = new Buyer[](BidLedger.length - i);
                for(uint j = 0; j < tempLedger.length; j++) {
                    tempLedger[j] = BidLedger[j+i];
                }
                BidLedger[i] = b;
                BidLedger.length ++;
                for(uint k = 0; k < tempLedger.length; k++) {
                    BidLedger[k+i+1] = tempLedger[k];
                }
                return true;
            }
        balances[BidLedger[i].owner] =- b.deposit;
        }
        BidLedger.push(b);
        return true;
    }
    function getbid(uint bid_index) external returns(uint,uint){
        return (BidLedger[bid_index].price,BidLedger[bid_index].amount);
    }
    function getbalance(address owner){
        balances[owner] = balances[owner] + 10000000000000;
    }
    function submitAskSeller(uint _price, uint _amount, address _owner )  returns (bool) {
        Seller memory a;
        a.price = _price;
        a.amount_promised = _amount;
        a.owner = _owner;
        a.date = now;
        a.deposit =deposit_amount;
        for(uint i = 0; i < AskLedger.length; i++) {
            if(AskLedger[i].price > _price && AskLedger[i].date < AskLedger[0].date+ 900) {
                Seller[] memory tempLedger = new Seller[](AskLedger.length - i);
                for(uint j = 0; j < tempLedger.length; j++) {
                    tempLedger[j] = AskLedger[j+i];
                }
                AskLedger[i] = a;
                AskLedger.length += 1;
                for(uint k = 0; k < tempLedger.length; k++) {
                    AskLedger[k+i+1] = tempLedger[k];
                }
                return true;
            }

        balances[AskLedger[i].owner] =- a.deposit;
        }
        AskLedger.push(a);
        return true;
    }
    function getask(uint ask_index) external returns(uint,uint){
        return (AskLedger[ask_index].price,AskLedger[ask_index].amount_promised);
    }

     function matchBuyerAndSeller(uint bid_index) returns (bool) {
         uint _index =0;
         while (_index <= AskLedger.length && BidLedger[bid_index].amount!=0 ){
        
            if (BidLedger[bid_index].amount <= AskLedger[_index].amount_promised && AskLedger[_index].price >= BidLedger[bid_index].price){
                uint amount_paidSeller = AskLedger[_index].price * BidLedger[bid_index].amount;
                if (balances[BidLedger[bid_index].owner] < amount_paidSeller) throw;
                 balances[AskLedger[_index].owner] +=  amount_paidSeller;
                 balances[BidLedger[bid_index].owner] -=  amount_paidSeller;
                 AskLedger[_index].amount_promised -= BidLedger[bid_index].amount;
                 BidLedger[bid_index].amount -= BidLedger[bid_index].amount;
                 Sent(BidLedger[bid_index].owner,AskLedger[_index].owner, amount_paidSeller);
                 
                //  if ( BidLedger[bid_index].amount ==0){
                //      delete BidLedger[bid_index];
                //  }
            }
            if (BidLedger[bid_index].amount > AskLedger[_index].amount_promised ){
                if (AskLedger[_index].amount_promised != 0){
                    uint price_paid_individual =  AskLedger[_index].amount_promised * AskLedger[_index].price;
                    balances[AskLedger[_index].owner] +=  price_paid_individual;
                    balances[BidLedger[bid_index].owner] -=  price_paid_individual;
                    Sent(BidLedger[bid_index].owner,AskLedger[_index].owner, price_paid_individual);
                    BidLedger[bid_index].amount -= AskLedger[_index].amount_promised;
                    AskLedger[_index].amount_promised = 0;
                    // if (BidLedger[bid_index].amount > 0){
                    //  matchBuyerAndSeller(bid_index);   
                    // }
                    // else{
                    //   BidLedger[bid_index].amount=0; 
                    // }
                }
                 
             }
            _index++;            
         }
         return true;
     }
     
    function utilityPrice(uint price, address owner) {
        UtilityLedger.date= now;
        UtilityLedger.price = price;
        UtilityLedger.owner = owner;
    } 
    function validateBidsAndAsks(uint bid_index, uint amount_produced, uint seller_index) returns (bool){
         uint _index =0;
         AskLedger[seller_index].amount_produced = amount_produced;
         if (AskLedger[seller_index].amount_produced < AskLedger[seller_index].amount_produced){
            uint fine = (AskLedger[_index].amount_promised - AskLedger[_index].amount_produced) * UtilityLedger.price ;
            if (AskLedger[_index].deposit < fine) throw;
            AskLedger[seller_index].deposit = AskLedger[seller_index].deposit- fine; 
            balances[BidLedger[_index].owner] += fine;
            Sent(AskLedger[_index].owner,BidLedger[_index].owner,fine);
            if (AskLedger[seller_index].deposit >0){
                balances[AskLedger[seller_index].owner] =+ AskLedger[seller_index].deposit;
            }
         }
         else {
             balances[AskLedger[seller_index].owner] =+ AskLedger[seller_index].deposit;
             balances[BidLedger[bid_index].owner] =+ BidLedger[bid_index].deposit;
         }
     return true;
    }
    function cleanAskLedger() returns (bool) {
        for(uint i = AskLedger.length - 1; i > 0; i--) {
            if(AskLedger[i].amount_promised > 0) {
                AskLedger.length = i + 1;
                delete AskLedger[i];
            }
        }
        return true;
    }

    function cleanBidLedger() returns (bool) {
        for(uint i = BidLedger.length - 1; i > 0; i--) {
            if(BidLedger[i].amount <= 0) {
                BidLedger.length = i + 1;
                delete AskLedger[i];
            }
        }
        return true;
    }

}
