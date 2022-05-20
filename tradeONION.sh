#!/bin/bash
CURRVER=1.1.0
#cd "${0%/*}"
# 
# WARNING: Buy and Sell ONLY show ONION price (not bid or ask)
# This software is not associated with nor endorsed by DeepOnion©, TradeOgre© or StakeCube©  who shall be held harmless for use or misuse of this product.
# Other names of companies or products listed in this script are copyright of their respective owners and shall also be held harmless.
# This SOFTWARE PRODUCT is provided by THE PROVIDER "as is" and "with all faults." THE PROVIDER makes no representations or warranties of any kind 
# concerning the safety, suitability, lack of viruses, inaccuracies, typographical errors, or other harmful components of this SOFTWARE PRODUCT. 
# There are inherent dangers in the use of any software, and you are solely responsible for determining whether this SOFTWARE PRODUCT is compatible 
# with your equipment and other software installed on your equipment. You are also solely responsible for the protection of your equipment and backup 
# of your data, and THE PROVIDER will not be liable for any damages you may suffer in connection with using, modifying, or distributing this SOFTWARE PRODUCT.
################      IMPORTANT!!!  READ THIS!!!        ######################
# WARNING: Buy and Sell ONLY show ONION price  (not bid or ask)              #
# To run this you will need an account, API KEY and SECRET at TradeOgre.     #
# You will need to create a file in the same directory as this file named    #
# shellogreks.txt   You need to put your API KEY/SECRET in the file on one   #
# line with a colon ":" between them.                                        # 
# Do not hit enter at the end of the line.                                   # 
# Example:                                                                   #
# ac67d2345:1d742a34c9  (they will be much longer)
# 
#
#
#
#                                                                            #
# You will need to have curl and jq available. Please let me know if your    #
# system asks for anything else.                                             #
#                                                                            #
# CREDIT: I forked this from https://github.com/ShellCrypto/ShellOgre        #
# I made changes to it to work with DeepOnion and added a couple features.   #
# It is still kind of rough and I will clean up some things as I get time.   #
# It works for me but I make no promise that it will not take all your DOGE. #
# I can not be responsible if it wipes out your pr0n collection.             #
# I ADVISE TO READ THE CODE FOR YOUR SAFETY AND PEACE OF MIND.               #
# This script is licensed under the GNU General Public License v3.0          #
#                                                                            #
#                                                                            #
# WARNING: Buy and Sell ONLY show ONION price (not bid or ask)               #
##############################################################################
# TODO:
# Too much to waste time writing up a TODO list right now :P
#
# Reduce code via functions.
# Complete converting script to dynamic. 
# Complete [default] inputs. 
# Learn at least enough jq to pretty up the output.
# SC Ticker - convert scientific e notation to float.
# Convert all calls to TradeOgre.
# Update comments/docs
#  
##############################################################################
################################  API info  ################################## 
# https://tradeogre.com/help/api
# https://github.com/stakecube/DevCube/
# 
# 
##############################################################################

## Set key and secret.
# KEY=
# SECRET=
#
ksvalue1=`cat shellogreks.txt`   # TradeOgre KEY:SECRET
ksvalue2=`cat scks.txt`          # StakeCube KEY
ksvalue3=`cat scks2.txt`         # StakeCube SECRET
ksvalue4=`cat scitcoks.txt`      # Citex
ksvalue5=`cat sxchangeks.txt`    # SouthXchange
ksvalue=$ksvalue1
#    echo $ksvalue
#######################
###          ######## ENDPOINTS #########
ENDPOINT1="https://tradeogre.com/api/v1/"
ENDPOINT2="https://stakecube.io/api/v2/"
ENDPOINT3="https://www.citex.co.kr/api/v2/"
ENDPOINT4="https://www.southxchange.com/api/v4/"
ENDPOINT=$ENDPOINT1

#
MARKETS=markets           # Retrieve a listing of all markets and basic information including current price, volume, high, low, bid and ask.
# /orders/{market}   # Retrieve the current order book for {market} such as BTC-ONION.
# /ticker/{market}   # Retrieve the ticker for {market}, volume, high, and low are in the last 24 hours, initialprice is the price from 24 hours ago.
# /history/{market}  # Retrieve the history of the last trades on {market} limited to 100 of the most recent trades. The date is a Unix UTC timestamp.
#######################
# endpoints Private API    ( Buy, Sell, Cancel, Orders, Balance are method POST )
COIN=ONION                  # My favorite coin
ORDERS=orders/              #
BUY=order/buy               # Fields= market quantity price . 
SELL=order/sell             # Fields= market quantity price .
HISTORY=history/            #
CANCEL=order/cancel         # Fields= uuid all . Cancel an order on the order book by uuid. The uuid parameter can also be set to all.
MYORDERS=account/orders     # Fields= market . Retrieve the active orders under your account. The market field is optional, and leaving it out will return all orders in every market. Date is a Unix UTC timestamp.
TICKER=ticker/              #
MYBALANCE=account/balance   # Fields= currency . Get the balance of a specific currency for you account. The currency field is required, such as ONION.
# /account/order/{uuid}     # Retrieve information about a specific order by the uuid of the order.
MYBALANCES=account/balances # Retrieve all balances for your account.
############################################################################
# StakeCube
EXCHSPOTEP='exchange/spot/myOrderHistory?'
EXCHSPOTORDERQEP='exchange/spot/order?'
AMPSIDEEQ='\&side='
AMPPRICEEQ='\&price='
AMPMARKETEQ='\&market='
AMPAMOUNTEQ='\&amount='
SIDEEQ='side='
PRICEEQ='price='
AMOUNTEQ='amount='
#
# 
# 
# params
#TRADESMKT=trades\?market= 
TRADESMKT=trades/
MYTRADES='myTrades?'
MARKETEQ='market='
urlenc='-H "Content-Type: application/x-www-form-urlencoded"'

############################################################################# 
#######   StakeCube endpoints ###############################################
#############################################################################
# ENDPOINT2="https://stakecube.io/api/v2/"
##   ##################  PUBLIC  #############
#  exchange/spot/arbitrageInfo?ticker=ONION
#
#  exchange/spot/markets?baseMarket=BTC&orderBy=volume 
#            Parameter	      Description	            Example
#            ---------        -----------               -------
# (optional) market	       specific market pair	        ONION_BTC
# (optional) baseMarket	   specific base market	        BTC
# (optional) category	   specific category	        BTC, ONION, ALTS, STABLE
# (optional) orderBy	   the list's ordering	        volume  or change
# (optional) orderData	   include order information	true or false
# (optional) priceHistory  include price history	    true or false'
#
#  ORDER
#            Parameter	      Description	              Example
#            ---------        ------------                -------
# (required) market	the    chosen market pair	          ONION_BTC
# (required) side	the    market side to place the order BUY or SELL
# (required) price	the    price in the Base coin	      0.00010000 (BTC)
# (required) amount	the    amount in the Market coin	  10 (ONION)
# (required) nonce	the    incremental integer	          UNIX Timestamp
# (required) signature	   the parameter's HMAC signature HEX Format

#Note: The side must be in full caps, e.g: BUY or SELL, not buy or sell.

#Example: POST https://stakecube.io/api/v2/exchange/spot/order

#POST Body: market=ONION_BTC&side=BUY&price=0.00010000&amount=10&nonce=123&signature=xxx
# 
# 
#
#
#
#
#
##############################################
#                  ######## VARIABLES ########  
# COINV=              # Coin Choice
# coin_choice=        # The coin you want to buy, sell, etc.
# ksvalue=            # The $KEY:$SECRET pair for authorization for Private API use.
# market=             # BTC-ONION     BTC-(coin)
# quantity=           # BTC must be >= 0.00005000
# minquantity         # Minimum quantity to satisfy BTC amount
# price=              # 0.00000381    must be > 0.00000001
# ONIONUSD=           # USD price of ONION
# BTCONION=           # BTC price of ONION
# BTCBTC=             # Current USD price of BTC 
# CURRENTBTC=         # Your current balance of BTC  
# CURRENTONION=       # Your current balance of ONION
# EPOCHTIME           # Unix epoch- number of seconds that have elapsed since January 1, 1970 at midnight UTC time minus the leap seconds.
# DATETIME            # 
# MKT1=BTC-ONION      # 
# 
###########################################################################################################################################################
#              ######## COLORS #########
# -e '\E[32;40m'"\033[1m"    # Green on Black
# -e '\E[31;40m'"\033[1m"    # Red on Black
# -e '\E[34;40m'"\033[1m"    # Blue on Black
# -e '\E[33;40m'"\033[1m"    # Yellow on Black
# -e '\E[36;40m'"\033[1m"    # Cyan on Black
# -e '\E[35;40m'"\033[1m"    # Magenta on Black
# -e '\E[37;40m'"\033[1m"    # White on Black
# -e '\E[33;47m'"\033[1m"    # Black on White
# 
#######################################################################
#
## Print selection menu.
clear
echo $ENDPOINT
showMenu(){
echo -e '\E[32;40m'"\033[1m"
unset market ; unset quantity ; unset price 
  echo "===================================="
  echo "        tradeONION    "
  echo "===================================="
  echo "[0]  EXIT"
  echo "[1]  Get Coin Balance"
  echo "[2]  Get All Balances"
  echo "[3]  BUY ONION with BTC"
  echo "[4]  SELL ONION for BTC"
  echo "[5]  CANCEL Order by uuid"
  echo "[6]  Display Order Book" 
  echo "[7]  My Market Orders"
  echo "[8]  Market Ticker"
  echo "[9]  Market History"
  echo "[10] All Markets"
  echo "[11] Convert Epoch time"
  echo "[12] Check for update"
  echo "[13] Testing Area"
  echo "[14] Choose an Exchange"
  echo "[15] StakeCube Testing"
  echo "===================================="
  printf "\n"
  
  read -p "Please Select A Number: " mc
  return $mc
  
           }

## 
while [[ "$m" != "0" ]]
do
##
 if [[ "$m" == "1" ]]; then
    ## Get Coin Balance.
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    read -p "Get currency balance [ONION]:" COINV ; COINV=${COINV:-ONION}
    echo Your $COINV balance is: 
    echo -e '\E[33;40m'"\033[1m"
    curl -s --request POST \
    --url $ENDPOINT$MYBALANCE \
    --user $ksvalue \
    --form currency=$COINV | jq '.balance' | tr '"' ' '
    
    echo -e '\E[32;40m'"\033[1m"
    echo Your available $COINV balance is:
    echo -e '\E[33;40m'"\033[1m"
    curl -s --request POST \
    --url $ENDPOINT$MYBALANCE \
    --user $ksvalue \
    --form currency=$COINV | jq '.available' | tr '"' ' '
    echo -e '\E[32;40m'"\033[1m"
    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
  
    
    
    echo "StakeCube"
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    
       
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    
    
      
    fi
    printf "\n"
#####  22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
    elif [[ "$m" == "2" ]]; then
    ## Get All Balances.
    
   # read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    echo "Your Coin balances are: "
    echo -e '\E[33;40m'"\033[1m"
    (curl -s --request GET \
    --url $ENDPOINT$MYBALANCES \
    --user $ksvalue | jq -c -r  '.balances | to_entries[] | [ "\(.key), \(.value)" ]' | sed '/0.00000000/d' | tr '[]"' ' ' )
    echo -e '\E[32;40m'"\033[1m"
    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
   
    
    echo "StakeCube"
      
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    
    
    fi
    
    printf "\n" 
#####  33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333    
    elif [[ "$m" == "3" ]]; then
    ## Buy ONION with BTC

    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    BTCONION=$(curl -s --request GET \
    --url https://tradeogre.com/api/v1/ticker/BTC-ONION | jq '.price' | tr -d '"')
  
    CURRENTBTC=$(curl -s --request POST \
    --url https://tradeogre.com/api/v1/account/balance \
    --user $ksvalue \
    --form currency=BTC | jq '.available' | tr -d '"')
    BTCBTC=$(curl -s https://api-pub.bitfinex.com/v2/ticker/tBTCUSD | awk -F',' '{print  $7}')
    ONIONUSD=$(echo $BTCBTC*$BTCONION | bc)
    echo "| If you are going to bid less than the ONION Price       |"
    echo "| you will need to buy more than the minimum quantity.    |"
    echo "| If you get an error 'Quantity must be at least 0.00005' |"
    echo "| then increase quantity or bid higher price.             |"
    echo -e '\E[31;40m'"\033[1m" " WARNING: Displayed Buy price default is price, not bid or ask."
    echo " Use ticker. Will be fixed in next version.";echo -e '\E[32;40m'"\033[1m"
    echo Current ONION Price is: 1 ONION = "$BTCONION" BTC /  $ONIONUSD USD. &&
    echo Your current BTC balance is $CURRENTBTC BTC. 1 BTC = $BTCBTC
    buybtconion="BTC-ONION"
    
    printf "\n"
  while true; do
    read -p "Which market would you like [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    minquantity=$(echo 0.00005000/$BTCONION | bc)
    echo "Minimum quantity of ONION is : " $minquantity
    read -p "Enter quantity desired [$minquantity]: " quantity ; quantity=${quantity:-$minquantity} 
    read -p "Enter price bid per ONION (default= current BUY price) [$BTCONION] : " price ; price=${price:-$BTCONION}
    echo -e '\E[33;40m'"\033[1m"
    echo "This is a BUY order."
    echo "You entered (read carefully):"
    echo "market= " $market
    echo "quantity= " $quantity
    echo "price= " $price
    echo
    read -p "Are the above values what you wanted ?" yn
    echo -e '\E[32;40m'"\033[1m"
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) continue;;
        * ) echo "Please answer yes or no.";;
    esac
  done
    while true; do
     echo -e '\E[31;40m'"\033[1m"
   read -p "Would you like to execute this transaction?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exec $0;;
        * ) echo "Please answer yes or no.";;
    esac
  done  
   echo -e '\E[32;40m'"\033[1m"
   curl -s --request POST \
    --url $ENDPOINT$BUY \
    --user $ksvalue \
    --form market=$market \
    --form quantity=$quantity \
    --form price=$price         #  | tee -a $log_file
 
 ######################################################
 
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    ## Buy ONION with BTC
    
    BTCONION=$(curl -s --request GET \
    --url https://tradeogre.com/api/v1/ticker/BTC-ONION | jq '.price' | tr -d '"')
  
    CURRENTBTC=$(curl -s --request POST \
    --url https://tradeogre.com/api/v1/account/balance \
    --user $ksvalue \
    --form currency=BTC | jq '.available' | tr -d '"')
    BTCBTC=$(curl -s https://api-pub.bitfinex.com/v2/ticker/tBTCUSD | awk -F',' '{print  $7}')
    ONIONUSD=$(echo $BTCBTC*$BTCONION | bc)
    echo "| If you are going to bid less than the ONION Price       |"
    echo "| you will need to buy more than the minimum quantity.    |"
    echo "| If you get an error 'Quantity must be at least 0.00002' |"
    echo "| then increase quantity or bid higher price.             |"
    echo -e '\E[31;40m'"\033[1m" " WARNING: Displayed Buy price default is price, not bid or ask."
    echo " Use ticker. Will be fixed in next version.";echo -e '\E[32;40m'"\033[1m"
    echo Current ONION Price is: 1 ONION = "$BTCONION" BTC /  $ONIONUSD USD. &&
    echo Your current BTC balance is $CURRENTBTC BTC. 1 BTC = $BTCBTC
    buybtconion="BTC-ONION"
    skey1=$ksvalue2 
    skey2=$ksvalue3
    echo $skey2
    while true; do
    read -p "Is this a BUY or SELL order (use UPPERCASE) [BUY]:" side1 ; side1=${side1:-BUY}
    side1=${side1^^}
    side2=${side1^^}
    read -p "Which market would you like [ONION_BTC]:" market ; market=${market:-ONION_BTC}
    minquantity=$(echo 0.00002000/$BTCONION | bc)
    echo "Minimum quantity of ONION is : " $minquantity
    read -p "Enter quantity desired [$minquantity]: " quantity ; quantity=${quantity:-$minquantity} 
    read -p "Enter price bid per Base coin (default= current BUY price) [$BTCONION] : " price ; price=${price:-$BTCONION}
    
    echo -e '\E[33;40m'"\033[1m"
    echo "This is a "${side1^^}" order."
    echo "You entered (read carefully):"
    echo "market= " $market
    echo "quantity= " $quantity
    echo "price= " $price
    echo
    read -p "Are the above values what you wanted ?" yn
    echo -e '\E[32;40m'"\033[1m"
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) continue;;
        * ) echo "Please answer yes or no.";;
    esac
  done
    while true; do
     echo -e '\E[31;40m'"\033[1m"
   read -p "Would you like to execute this transaction?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exec $0;;
        * ) echo "Please answer yes or no.";;
    esac
  done  
   echo -e '\E[32;40m'"\033[1m"
    
    
    nonce1=$(date +%s%N | cut -b1-13)
    nonce3='nonce='
    marketv=$market
    signature1="\&signature=" 
    skey1=$ksvalue2 
    skey2="$ksvalue3"
    xapi='-H "X-API-KEY: '
    xapi1=$skey1\"
    xapikey="$xapi$xapi1"
    echo '"xapikey"' $xapikey
    skey3=\"${skey2}\"  
    echo "skey3" $skey3
    HMAC1="-hmac "
    echo "HMAC1" $HMAC1
    HMAC=$HMAC1$skey2
    echo "HMAC" $HMAC
    MYORDERHIST="myOrderHistory\?"
    urlenc='"Content-Type: application/x-www-form-urlencoded"'

urleq="https://stakecube.io/api/v2/exchange/spot/order"
#body1="market=ONION_BTC&side=SELL&price=0.00099969&amount=100&nonce=$nonce1"
signature3=$(printf "market=$marketv&side=$side1&price=$price&amount=$quantity&nonce=$nonce1" | openssl dgst -sha256 -hmac "$skey2"  | sed 's/.*= //')

    (curl -s --request POST \
    --url $urleq \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -H "X-API-KEY: $skey1" \
    --data market=$market \
    --data side=$side1 \
    --data price=$price \
    --data amount=$quantity \
    --data nonce=$nonce1 \
    --data signature=$signature3 | jq )

    printf "\n"
###########################################################    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    printf "\n"
###########################################################
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    
     printf "\n"
    
    fi
#####  4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444    
    elif [[ "$m" == "4" ]]; then
    ## Buy BTC with ONION

    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    ONIONBTC=$(curl -s --request GET \
    --url https://tradeogre.com/api/v1/ticker/BTC-ONION | jq '.price' | tr -d '"') 

    BTCUSD=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd" -H  "accept: application/json" | jq '.bitcoin.usd')

    CURRENTONION=$(curl -s --request POST \
      --url https://tradeogre.com/api/v1/account/balance \
      --user $ksvalue \
    --form currency=ONION | jq '.available' | tr -d '"')
        
     BTCONION=$(curl -s --request GET \
      --url https://tradeogre.com/api/v1/ticker/BTC-ONION | jq '.price' | tr -d '"')
     CURRENTBTC=$(curl -s --request POST \
      --url https://tradeogre.com/api/v1/account/balance \
      --user $ksvalue \
      --form currency=BTC | jq '.available' | tr -d '"')
    
    BTCBTC=$(curl -s https://api-pub.bitfinex.com/v2/ticker/tBTCUSD | awk -F',' '{print  $7}')
    ONIONUSD=$(echo $BTCBTC*$BTCONION | bc)
    echo "| If you are going to bid less than the ONION Price       |"
    echo "| you will need to buy more than the minimum quantity.    |"
    echo "| If you get an error 'Quantity must be at least 0.00005' |"
    echo "| then increase quantity or bid higher price.             |"
    echo -e '\E[31;40m'"\033[1m" " WARNING: Displayed Sell price is price, not bid or ask."
    echo "   Use ticker. Will be fixed in next version.";echo -e '\E[32;40m'"\033[1m"
    echo Current ONION Price is: 1 ONION = "$BTCONION" BTC / $ONIONUSD USD. &&
    echo Your current BTC balance is $CURRENTBTC BTC. 1 BTC = $BTCBTC
    
    while true; do
   
    read -p "Which market would you like [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    minquantity=$(echo 0.00005000/$BTCONION | bc)
    echo "Minimum quantity of ONION is: " $minquantity
    read -p "Enter quantity desired [$minquantity]:" quantity ; quantity=${quantity:-$minquantity} 
    read -p "Enter price of each ONION [$BTCONION]: " price ; price=${price:-$BTCONION}
    echo -e '\E[33;40m'"\033[1m"
    echo "This is a SELL order."
    echo "You entered (read carefully):"
    echo "market= " $market
    echo "quantity= " $quantity
    echo "price= " $price
    echo
    read -p "Are the above values what you wanted ?" yn
    echo -e '\E[31;40m'"\033[1m"
     case $yn in
        [Yy]* ) break;;
        [Nn]* ) continue;;
        * ) echo "Please answer yes or no.";;
     esac
    done
  
    while true; do
    read -p "Would you like to execute this transaction?" yn
     case $yn in
        [Yy]* ) break;;
        [Nn]* ) exec $0;;
        * ) echo "Please answer yes or no.";;
     esac
    done  
    curl --request POST \
    --url $ENDPOINT$SELL \
    --user $ksvalue \
    --form market=$market \
    --form quantity=$quantity \
    --form price=$price          #  | tee -a $log_file
    echo -e '\E[32;40m'"\033[1m"
    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    echo -e '\E[33;40m'"\033[1m"
    echo "Please use option \"3\" and choose \"SELL\" for order type."
    echo -e '\E[32;40m'"\033[1m"
    echo "StakeCube"
    printf "\n"
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    
    
    fi
##### 555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
    printf "\n"
    elif [[ "$m" == "5" ]]; then
    ## Cancel Order
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    echo "Use <all> to Cancel ALL orders."
    read -p "Enter the uuid # " uuid
    
    curl -s --request POST \
    --user $ksvalue \
    --url $ENDPOINT$CANCEL  \
    --form uuid=$uuid
##############################################################    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    nonce1=$(date +%s%N | cut -b1-13) 
    signature1='&signature='
    cancel1='cancel?'
    nonce2='&nonce='
    skey1=$ksvalue2
    skey2=$ksvalue3
    xapi="'X-API-KEY: "
    xapi1=$skey1\'
    xapikey=\"$xapi$xapi1\"
   # skey2=\"${skey2}\"\'  
    HMAC1="-hmac "
    HMAC=$HMAC1$skey2
        
    echo "Type cancel to cancel all orders in specified market pair"
    read -p "Enter the Order # " orderIDnum
    echo "$orderIDnum" "$cancelv"
    if [[ "$orderIDnum" == "$cancelv" ]]
    then 
    echo -e '\E[31;40m'"\033[1m"
    echo "!! WARNING - ALL active orders in the market pair you select will be CANCELLED !!"
    echo $orderIDnum
    echo -e '\E[32;40m'"\033[1m"
    read -p "Which market would you like to cancel [ONION_BTC]:" market ; market=${market:-ONION_BTC}
    echo "cancel all"
        
    urleq="https://stakecube.io/api/v2/exchange/spot/cancelAll"
    signature3=$(printf "market=$market&nonce=$nonce1" | openssl dgst -sha256 -hmac "$skey2"  | sed 's/.*= //')
    
    (curl -s --request POST \
    --url $urleq \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H "X-API-KEY: $skey1" \
    --data market=$market \
    --data nonce=$nonce1 \
    --data signature=$signature3 | jq )
      
   else
    urleq="https://stakecube.io/api/v2/exchange/spot/cancel"
    signature3=$(printf "orderId=$orderIDnum&nonce=$nonce1" | openssl dgst -sha256 -hmac "$skey2"  | sed 's/.*= //')
   
    (curl -s --request POST \
    --url $urleq \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H "X-API-KEY: $skey1" \
    --data orderId=$orderIDnum \
    --data nonce=$nonce1 \
    --data signature=$signature3 | jq )
   fi
       
           
    echo "StakeCube"
    
#####################################################################
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    
    
    
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    
    
    
    
    fi
        
    printf "\n"
#####  666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
    elif [[ "$m" == "6" ]]; then
    ## Dispay Order Book
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[36;40m'"\033[1m"
    (curl -s --request GET \
    --url $ENDPOINT$ORDERS$market | jq . | tr -d '{,"}' | sed 's/success: true//g')
    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    
    (curl -s GET https://stakecube.io/api/v2/exchange/spot/orderbook?market=ONION_BTC | jq -r . )
    # | tr -d '{[,"]}' | sed 's/success: result: true//g')
    
    
    
    echo "StakeCube"
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    
    
    
    
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    
    
    fi
    
    printf "\n"
  #####  77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777 
    elif [[ "$m" == "7" ]]; then
    ## Get My Market Orders
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    unset market
    echo "Type <all> for all Markets."
    echo $ksvalue
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[33;40m'"\033[1m"
    if [[ $market == all ]]; then
    (curl -s --request POST \
    --url $ENDPOINT$MYORDERS \
    --user $ksvalue | jq . | tr -d '"[],{}')
    else
    (curl -s --request POST \
    --url $ENDPOINT$MYORDERS \
    --user $ksvalue \
    --form market=$market | jq . | tr -d '"[],{}')
    fi
    echo -e '\E[33;40m'"\033[1m"

####################################################################    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    nonce1=$(date +%s%N | cut -b1-13)
    market=ONION_BTC
    # limit1='&limit=100&nonce='
    signature1='&signature='
    skey1=$ksvalue2
    skey2=$ksvalue3
    # read -p "Enter Market [ONION_BTC]:" market ; market=${market:-ONION_BTC}
    
    urleq="https://stakecube.io/api/v2/exchange/spot/myOpenOrder"
    signature3=$(printf "nonce=$nonce1" | openssl dgst -sha256 -hmac "$skey2"  | sed 's/.*= //')
       
    (curl -v --request GET \
    --url https://stakecube.io/api/v2/exchange/spot/myOpenOrder?nonce=$nonce1\&signature=$signature3 \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H "X-API-KEY: $skey1" | jq )
    #--data nonce=$nonce1 \
    #--data signature=$signature3 | jq )
       
   printf "\n" 
####################################################################    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    # 3869475
    
    fi
    
    printf "\n"
#####  88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
    elif [[ "$m" == "8" ]]; then
    ## Market Ticker
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[33;40m'"\033[1m"
    curl -s --request GET \
    --url $ENDPOINT$TICKER$market
    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
       
    (curl -s --request GET \
    https://stakecube.io/api/v2/exchange/spot/arbitrageInfo?ticker=ONION | jq )
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    
    
    fi
    
    printf "\n"
    printf "\n"
#####  999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
    elif [[ "$m" == "9" ]]; then
    ## GET Market History
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[36;40m'"\033[1m""                    Latest trades are at bottom of list."
    echo -e '\E[34;40m'"\033[1m"
    echo "           DATE           TYPE              PRICE                  QUANTITY"
    echo -e '\E[32;40m'"\033[1m""           ----           ----              -----                  --------"
    (curl -s --request GET \
    --url $ENDPOINT$HISTORY$market | jq -cn --stream "fromstream(1|truncate_stream(inputs))")
                                     
    #  jq '.[].date |= todateiso8601' 
    #  | .[].departure |= todateiso8601'
    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
   # market="market=ONION_BTC"
    
    (curl -s GET https://stakecube.io/api/v2/exchange/spot/trades?market=ONION_BTC | jq . | tr -d '{[,"]}')
    #(curl GET  $ENDPOINT2$EXCHSPOTEP$TRADESMKT \
    # -d $market)
    
    # -H "Content-Type: application/x-www-form-urlencoded"
    echo $ENDPOINT2$EXCHSPOTEP$TRADESMKT$market
    unset market
    
    
    echo "StakeCube"
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    
    
    fi
    
    printf "\n"
#####  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    elif [[ "$m" == "10" ]]; then
    ## All Markets
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    echo -e '\E[34;40m'"\033[1m"
    (curl -s --request GET \
    --url $ENDPOINT$MARKETS | jq -cn --stream "fromstream(1|truncate_stream(inputs))")
    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    
    echo -e '\E[34;40m'"\033[1m"
    (curl -s GET https://stakecube.io/api/v2/exchange/spot/markets?baseMarket=BTC&orderBy=volume | jq -cn --stream "fromstream(1|truncate_stream(inputs))")
    echo -e '\E[33;40m'"\033[1m"; read -n 1 -r -s -p $'Waiting for response. After response, press any key to continue...\n' a
    echo -e '\E[32;40m'"\033[1m"
    # curl GET https://stakecube.io/api/v2/exchange/spot/markets?baseMarket=BTC&orderBy=volume
    # echo -e '\E[33;40m'"\033[1m"
    # echo "Press any key to continue..."
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "Citex"
    
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "SouthX"
    
    
    fi
            
    printf "\n" 
#####  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
    elif [[ "$m" == "11" ]]; then
    ## Date Converter
      
    read -p "Type or paste Epoch time :" EPOCHTIME
    echo -e '\E[36;40m'"\033[1m"
    DATETIME= date -d @$EPOCHTIME
    echo $DATETIME    
    
    printf "\n" 
#####  CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    elif [[ "$m" == "12" ]]; then
    ## Check For Update
        
    LATESTVER=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/kk80586/ShellOgreONION/tags | grep -n 'v1' | head -1 | sed -n 's/name//p' | sed 's/.*://' | tr -d  ' ":v,-')
      echo -e '\E[33;40m'"\033[1m"
      echo "Latest version is:" $LATESTVER
      echo "Your verion is:   " $CURRVER
       
   # echo $(curl -i -u kk80586 -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/kk80586/ShellOgreONION/tags)
      
   #   curl -H “Authorization: token  ” https://api.github.com/search/repositories?q=user:kk80586
      
   # curl -H “Authorization: token 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” -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/kk80586/tradeONION/tags
    
    printf "\n"
##### DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
    elif [[ "$m" == "13" ]]; then
    ## TESTING area
    
     ## Dispay Order Book
    
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[36;40m'"\033[1m"
    (curl -s --request GET \
    --url $ENDPOINT$ORDERS$market | jq . | tr -d '{,"}' | sed 's/success: true//g')  
    
printf "\n"
#####  EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
elif [[ "$m" == "14" ]]; then    
## Choose Exchange

i=1
while [ $i = 1 ] ; do
clear
echo -e '\E[32;40m'"\033[1m"
echo "Choose an exchange"
echo -e '\E[33;40m'"\033[1m"
echo "TradeOgre    = 1"  
echo "StakeCube    = 2" 
echo "Citex        = 3"  
echo "SouthXchange = 4" 
echo
read -p "Type a number [1, 2, 3, 4] :" x

   case $x in
    1) ENDPOINT=$ENDPOINT1
    ksvalue=$ksvalue1
    i=0
    ;;
    2) ENDPOINT=$ENDPOINT2
    ksvalue=$ksvalue2
    skey1=$ksvalue2 
    skey2=$ksvalue3
    echo $skey2
    i=0
    ;;
    3) ENDPOINT=$ENDPOINT3
    ksvalue=$ksvalue3
    i=0
    ;;
    4) ENDPOINT=$ENDPOINT4
    ksvalue=$ksvalue4
    i=0
    ;;
    *) 
    i=1;;
  
  esac
done
echo -e '\E[32;40m'"\033[1m"  
echo $ENDPOINT  
#echo $ksvalue
       
      printf "\n"
#####  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF    
      elif [[ "$m" == "15" ]]; then
      ## Arbitrage Info 
      
      
       (curl -s --request GET \
    https://stakecube.io/api/v2/exchange/spot/arbitrageInfo?ticker=ONION | jq )
      
      
      
     (curl GET https://stakecube.io/api/v2/exchange/spot/markets?baseMarket=BTC&orderBy=volume | jq -r -c .result)
      
      read -n 1 -r -s -p $'Waiting for response. After response, press any key to continue...\n' a
                  
      printf "\n"
      elif [[ "$m" == "16" ]]; then
      ## StakeCube Tesing
      
      
     curl GET https://stakecube.io/api/v2/system/rateLimits 
         
    printf "\n" 
      
  fi
  showMenu
  m=$?
done

####################################################################################################################################
# Readme.md                                                                                                                        # 
# 0. It is advised to read all of the text and as much code as you can in this script.                                             #
# 1. Please do not misuse or abuse the TradeOgre© API.                                                                             #
# 2. You must have an account on TradeOgre© as well as API key:secret pair to use this script.                                     #
# 3. This script is written to work [default] with ONION, as this is the coin I hodl :)                                            #
# 4. Most of the options have [defaults] where you can just press [ENTER] to accept the default.                                   #
# 5. This script can easily be changed to any coin you like that is traded on TraeOgre©                                            #
# 6. This script will let you perform most options for any BTC currency market including buy & sell.                               #
# 7. The buy and sell options have a pause to proofread the info you provided and a second pause to abandon the trade if need be.  #
# 8. Most other options have a default where you may press [ENTER] to accept or type in other market such as BTC-XMR.              #
# 9. This script has only been tested with BTC-ONION.                                                                              #
# A. This script has only been tested on Debian Linux in a bash shell using Konsole terminal emulator.                             #
# B. Do not run this script as root. It is not needed.                                                                             #
# C. Verify that you have curl and jq installed on your system.                                                                    #
# D. Familiarize yourself with https://tradeogre.com/help/api options and output.                                                  #
# E. WARNING: Buy and Sell ONLY show ONION price (not bid or ask)                                                                  #                                                                                                                             # F.                                                                                                                               #
####################################################################################################################################
clear
exit 0;
