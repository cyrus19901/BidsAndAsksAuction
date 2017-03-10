contract ExchangeTX {
    struct Bid {
        address owner;
        uint price;
        uint amount;
        uint date;
    }
    struct Ask {
        address owner;
        uint price;
        uint amount;
        uint date;
    }

    Bid[] public BidLedger;
    Ask[] public AskLedger;

    modifier bidInMarket(uint _price) { // Modifier
        if (AskLedger.length > 0) {
            if (_price < AskLedger[AskLedger.length-1].price ) throw;
        }
        _;
    }

    modifier askInMarket(uint _price) {
        if (BidLedger.length > 0) {
            if (_price > BidLedger[BidLedger.length-1].price) throw;
        }
        _;
    }

    function submitBid(uint _price, uint _amount) bidInMarket(_price) returns (bool) {
        Bid memory b;
        b.price = _price;
        b.amount = _amount;
        for(uint i = 0; i < BidLedger.length; i++) {
            if (BidLedger[i].price > _price) {
                Bid[] memory tempLedger = new Bid[](BidLedger.length - i);
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
        }
        BidLedger.push(b);
        return true;
    }
    function getbid(uint bid_index) external returns(uint,uint){
        return (AskLedger[bid_index].price,AskLedger[bid_index].amount);
    }

    function submitAsk(uint _price, uint _amount) askInMarket(_price) returns (bool) {
        Ask memory a;
        a.price = _price;
        a.amount = _amount;
        for(uint i = 0; i < AskLedger.length; i++) {
            if(AskLedger[i].price < _price) {
                Ask[] memory tempLedger = new Ask[](AskLedger.length - i);
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
        }
        AskLedger.push(a);
        return true;
    }
    function getask(uint ask_index) external returns(uint,uint){
        return (AskLedger[ask_index].price,AskLedger[ask_index].amount);
    }
    function matchBid(uint bid_index, uint ask_index) returns (bool) {
        if(BidLedger[bid_index].amount <= 0 || BidLedger[bid_index].price < AskLedger[ask_index].price) {
            return true;
        }
        BidLedger[bid_index].amount--;
        AskLedger[ask_index].amount--;
        if(AskLedger[ask_index].amount <= 0 ) {
            if(ask_index <= 0) {
                return true;
            }
            ask_index--;
            return matchBid(bid_index, ask_index);
        }
        return matchBid(bid_index, ask_index);
    }

    function matchAsk(uint ask_index, uint bid_index) returns (bool) {
        if(AskLedger[ask_index].amount <= 0 || AskLedger[ask_index].price > BidLedger[bid_index].price) {
            return true;
        }
        AskLedger[ask_index].amount--;
        BidLedger[bid_index].amount--;
        if(BidLedger[bid_index].amount <= 0) {
            if (bid_index <= 0) {
                return true;
            }
            bid_index--;
            return(matchAsk(ask_index, bid_index));
        }
        return(matchAsk(ask_index, bid_index));
    }

    function cleanAskLedger() returns (bool) {
        for(uint i = AskLedger.length - 1; i >= 0; i--) {
            if(AskLedger[i].amount > 0) {
                AskLedger.length = i + 1;
                return true;
            }
        }
        return false;
    }

    function cleanBidLedger() returns (bool) {
        for(uint i = BidLedger.length - 1; i >= 0; i--) {
            if(BidLedger[i].amount <= 0) {
                BidLedger.length = i + 1;
                return true;
            }
        }
        return false;
    }

}
