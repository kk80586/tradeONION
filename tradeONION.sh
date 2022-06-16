#!/bin/bash
CURRVER=0.9.0
#cd "${0%/*}"
# 
# WARNING: Buy and Sell ONLY show ONION price (not bid or ask)
# This software is not associated with nor endorsed by DeepOnion©, TradeOgre©, StakeCube© or SouthXchange© who shall be held harmless for use or misuse of this product.
# Other names of companies or products listed in this script are copyright of their respective owners and shall also be held harmless.
# This SOFTWARE PRODUCT is provided by THE PROVIDER "as is" and "with all faults." THE PROVIDER makes no representations or warranties of any kind 
# concerning the safety, suitability, lack of viruses, inaccuracies, typographical errors, or other harmful components of this SOFTWARE PRODUCT. 
# There are inherent dangers in the use of any software, and you are solely responsible for determining whether this SOFTWARE PRODUCT is compatible 
# with your equipment and other software installed on your equipment. You are also solely responsible for the protection of your equipment and backup 
# of your data, and THE PROVIDER will not be liable for any damages you may suffer in connection with using, modifying, or distributing this SOFTWARE PRODUCT.
################      IMPORTANT!!!  READ THIS!!!        ######################
# WARNING: Buy and Sell ONLY show ONION price  (not bid or ask)              #
##############################################################################
#                                                                            #
#     API KEY/SECRET                                                         #
# To run this you will need an account, API KEY and SECRET at TradeOgre.     #
# You will need to create a file in the same directory as this file named    #
# shellogreks.txt   You need to put your API KEY/SECRET in the file on one   #
# line with a colon ":" between them.                                        # 
# Do not hit enter at the end of the line.                                   # 
# Example:                                                                   #
# ac67d2345:1d742a34c9  (they will be much longer)
# 
# For Stakecube- Copy API KEY to scks.txt and SECRET to scks2.txt
#
# For SouthXchange- Copy API KEY to sxcks.txt and SECRET to sxcks2.txt 
#
#
#
#                                                                            #
# You will need to have curl and jq available. Please let me know if your    #
# system asks for anything else.                                             #
#                                                                            #
# CREDIT: Inspired by https://github.com/ShellCrypto/ShellOgre               #
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
# SouthXchange order book
# SouthXchange cancelMarketOrders
#
#  
##############################################################################
################################  API info  ################################## 
# https://tradeogre.com/help/api
# https://github.com/stakecube/DevCube
# https://main.southxchange.com/home/Api
# 
##############################################################################

## Set key and secret.
# KEY= for testing
# SECRET= for testing
#
#
ksvalue1=`cat shellogreks.txt`   # TradeOgre KEY:SECRET
ksvalue2=`cat scks.txt`          # StakeCube KEY
ksvalue3=`cat scks2.txt`         # StakeCube SECRET
ksvalue4=`cat sxcks.txt`         # SouthXchange KEY
ksvalue5=`cat sxcks2.txt`        # SouthXchange SECRET
ksvalue=$ksvalue1
#    echo $ksvalue
#######################
###          ######## ENDPOINTS #########
ENDPOINT1="https://tradeogre.com/api/v1/"
ENDPOINT2="https://stakecube.io/api/v2/"
ENDPOINT3="https://www.southxchange.com/api/"
ENDPOINT4="https://www."
ENDPOINT=$ENDPOINT1

#
MARKETS=markets           # Retrieve a listing of all markets and basic information including current price, volume, high, low, bid and ask.
# /orders/{market}   # Retrieve the current order book for {market} such as BTC-ONION.
# /ticker/{market}   # Retrieve the ticker for {market}, volume, high, and low are in the last 24 hours, initialprice is the price from 24 hours ago.
# /history/{market}  # Retrieve the history of the last trades on {market} limited to 100 of the most recent trades. The date is a Unix UTC timestamp.
#######################
# endpoints Private API    ( Buy, Sell, Cancel, Orders, Balance are method POST )
COIN=ONION           # My favorite coin
ORDER=order/
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
#            ######## CONVERT ########
# echo "1.0074E+05" | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}'   # e notation to decimal
# nonce1=$(date +%s%N | cut -b1-13)                                              # Unix time (current)
# DATETIME= date -d @$EPOCHTIME                                                  # 
# 
#######################################################################
#
editor=nano
#
#
## Print selection menu.
clear
showMenu(){
echo -e '\E[32;40m'"\033[1m"
unset market ; unset quantity ; unset price
#echo $ENDPOINT
  echo "===================================="
  echo "        tradeONION    " ; printf "\x1b[38;2;255;0;0m$ENDPOINT\x1b[0m\n"; echo -n -e '\E[32;40m'"\033[1m"
  echo "===================================="
  echo "[0]  EXIT"
  echo "[1]  Get Coin Balance"
  echo "[2]  Get All Account Balances"
  echo "[3]  BUY/SELL ONION (or other)"
  echo "[4]  CANCEL Order(s)"
  echo "[5]  Display Order Book"
  echo "[6]  My Market Orders" 
  echo "[7]  Market Ticker"
  echo "[8]  Market History"
  echo "[9]  All Markets on exchange"
  echo "[10] Miscellaneous"
  echo "[11] Choose an Exchange"
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
    ## Balances
    
    skey1=$ksvalue2
  nonce1=$(date +%s%N | cut -b1-13)
  skey2=$ksvalue3
signature3=$(printf "nonce=$nonce1" | openssl dgst -sha256 -hmac "$skey2"  | sed 's/.*= //')
      
      (curl -v --request GET \
      --url https://stakecube.io/api/v2/user/account?nonce=$nonce1\&signature=$signature3 \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      -H "X-API-KEY: $skey1" | jq )
       
        
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "SouthXchange"

      
#   POST https://www.southxchange.com/api/listBalances
#Parameters
#None
#Result
#Field	Description
#Array of [Balance entry]
#[Balance entry]
#Currency	Currency code
#Deposited	Total amount deposited for this currency code
#Available	Total amount that is not committed in orders
#Unconfirmed	Total amount unconfirmed in pending deposits

 nonce1=$(date +%s%N | cut -b1-13)
 skey1="$ksvalue4"
 skey2="$ksvalue5"
 sxurleq="https://www.southxchange.com/api/listBalances"

body1="{\"key\":\"$skey1\",\"nonce\":\"$nonce1\"}"

    mysig=$(echo -n "$body1" | openssl dgst -sha512 -hmac "$skey2")
  mysig1="${mysig:9}"
    
    (curl -s --request POST \
    --url $sxurleq \
     -H "Content-Type: application/json" \
     -H "Hash: $mysig1" \
    --data "$body1" | tr ',[]' ' ')


    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "exchangex"
        
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
    ## Balences
    
    skey1=$ksvalue2
  nonce1=$(date +%s%N | cut -b1-13)
  skey2=$ksvalue3
signature3=$(printf "nonce=$nonce1" | openssl dgst -sha256 -hmac "$skey2"  | sed 's/.*= //')
      
      (curl -v --request GET \
      --url https://stakecube.io/api/v2/user/account?nonce=$nonce1\&signature=$signature3 \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      -H "X-API-KEY: $skey1" | jq )
        
    echo "StakeCube"
  #  echo "Sorry, StakeCube provides no API call for balance."
    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "SouthXchange"
    #(curl GET https://www.southxchange.com/api/markets | jq )
  
    #   POST https://www.southxchange.com/api/listBalances
#Parameters
#None
#Result
#Field	Description
#Array of [Balance entry]
#[Balance entry]
#Currency	Currency code
#Deposited	Total amount deposited for this currency code
#Available	Total amount that is not committed in orders
#Unconfirmed	Total amount unconfirmed in pending deposits

 nonce1=$(date +%s%N | cut -b1-13)
 skey1="$ksvalue4"
 skey2="$ksvalue5"
 #arr=("Currency" "Deposited" "Available" "Unconfirmed" # printf '%s\n' "${arr[@]}")
 sxurleq="https://www.southxchange.com/api/listBalances"

body1="{\"key\":\"$skey1\",\"nonce\":\"$nonce1\"}"

    mysig=$(echo -n "$body1" | openssl dgst -sha512 -hmac "$skey2")
    mysig1="${mysig:9}"
    
    read -a arr < <(echo $(curl -v -s --request POST \
    --url $sxurleq \
     -H "Content-Type: application/json" \
     -H "Hash: $mysig1" \
    --data "$body1" | jq -r ".[] | .Currency, .Deposited, .Available, .Unconfirmed"))     
    
    
 read -p "How many coins do you have/want to list? " x 
 x=$x-1
 echo "       Currency  Deposited      Available      Unconfirmed"
 echo "       --------  ---------      ---------      -----------"
 
for ((i=0; i<=$x; i++))
do
 printf '%14s'  "${arr[$k]}"  "   ${arr[$k+1]} " "${arr[$k+2]}" "${arr[$k+3]} "; printf "\n"
 k=$k+4
done
 
    printf "\n"
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "exchangeX"
    
    fi
    
    printf "\n" 
#####  33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333    
    elif [[ "$m" == "3" ]]; then
    ## BUY/SELL ONION with BTC

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
    
while true; do
    read -p "Is this a BUY or SELL order (use lowercase) [buy]:" side1 ; side1=${side1:-buy}
    side1=${side1,,}
    
    if [[ "$side1" == "sell" ]]
    then
    side1="sell"
    else 
    side1="buy"
    fi
    market="BTC-ONION"
    read -p "Which market would you like [$market]:" market ; market=${market:-BTC-ONION}
        
    minquantity=$(echo 0.00005000/$BTCONION | bc)
    echo "Minimum quantity of "$COIN" is : " $minquantity
    read -p "Enter quantity desired [$minquantity]: " quantity ; quantity=${quantity:-$minquantity} 
    read -p "Enter price bid per coin (default= current BUY price) [$BTCONION] : " price ; price=${price:-$BTCONION}
    
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
   curl -s -v --request POST \
    --url $ENDPOINT$ORDER$side1 \
    --user $ksvalue \
    --form market=$market \
    --form quantity=$quantity \
    --form price=$price         #  | tee -a $log_file
    echo $ENDPOINT$ORDER$side1
    
    printf "\n"
 ######################################################
 
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    ## BUY/SELL ONION with BTC
    
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
 ## BUY/SELL ONION with BTC
 
 read bid1 ask2 last3 < <(echo $(curl -v -X GET https://www.southxchange.com/api/price/ONION/BTC | jq -r '.Bid, .Ask, .Last' | tr -d '"'))
  bid1=$(echo "$bid1" | awk -F"E" 'BEGIN{OFMT="%10.8f"} {print $1 * (10 ^ $2)}')
  ask2=$(echo "$ask2" | awk -F"E" 'BEGIN{OFMT="%10.8f"} {print $1 * (10 ^ $2)}')
  last3=$(echo "$last3" | awk -F"E" 'BEGIN{OFMT="%10.8f"} {print $1 * (10 ^ $2)}')
  echo "b " $bid1
  echo "a " $ask2
  echo "l " $last3
 sleep 3s
 # BTC price
 read btclast < <(echo $(curl -v -X GET https://www.southxchange.com/api/price/BTC/TUSD | jq -r '.Last' | tr -d '"'))
 btclast=$(echo "$btclast" | awk -F"E" 'BEGIN{OFMT="%10.8f"} {print $1 * (10 ^ $2)}')
 echo "btc " $btclast
 echo -e '\E[31;40m'"\033[1m"
 echo "shhh.. :" $ksvalue5
 echo -e '\E[32;40m'"\033[1m"
 
    CURRENTBTC=$(curl -s --request POST \
    --url https://tradeogre.com/api/v1/account/balance \
    --user $ksvalue \
    --form currency=BTC | jq '.available' | tr -d '"')
    BTCBTC=$(curl -s https://api-pub.bitfinex.com/v2/ticker/tBTCUSD | awk -F',' '{print  $7}')
      
    ONIONUSD=$(echo $btclast*$last3 | bc)
    echo "| If you are going to bid less than the ONION Price       |"
    echo "| you will need to buy more than the minimum quantity.    |"
    echo "| If you get an error 'Quantity must be at least 0.00001' |"
    echo "| then increase quantity or bid higher price.             |"
    echo -e '\E[31;40m'"\033[1m" " WARNING: Displayed Buy price default is price, not bid or ask."
    echo " Use ticker. Will be fixed in next version.";echo -e '\E[32;40m'"\033[1m"
    echo Current ONION Last Price is: 1 ONION = "$last3"
    echo Current ONION Ask Price is: 1 ONION = "$ask2"
    echo Current ONION Bid Price is: 1 ONION = "$bid1" BTC /  $ONIONUSD USD. &&
    echo Your current BTC balance is $CURRENTBTC BTC. 1 BTC = $btclast
   # buybtconion="BTC-ONION"
   # skey1=$ksvalue2 
   # skey2=$ksvalue3
    while true; do
    read -p "Is this a BUY or SELL order (use LOWERCASE) [buy]:" side1 ; side1=${side1:-BUY}
    side1=${side1,,}
   # side2=${side1,,}
    read -p "Which Listing Currency would you like [ONION]:" market ; market=${market:-ONION}
    read -p "which Reference Currency would you like [BTC]:" matket2 ; market2=${market2:-BTC}
    minquantity=$(echo 0.00001000/$last3 | bc)
    echo "Minimum quantity of ONION is : " $minquantity
    read -p "Enter quantity desired [$minquantity]: " quantity ; quantity=${quantity:-$minquantity}
    read -p "Enter limit-price bid in Reference Currency per Listing coin (default= current $side1 price) [$last3] : " price ; price=${price:-$ask2}
    read -p " SPOT ROUTINE GOES HERE  " x
    echo -e '\E[33;40m'"\033[1m"
    echo "This is a "${side1,,}" order."
    echo "You entered (read carefully):"
    echo "market= " $market
    echo "Reference Market= " $market2
    echo "quantity= " $quantity
    echo "price= " $price
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
    skey1="$ksvalue4"
    skey2="$ksvalue5"
    
urleq="https://www.southxchange.com/api/placeOrder"

body1="{\"key\":\"$skey1\",\"nonce\":\"$nonce1\",\"listingCurrency\":\"$market\",\"referenceCurrency\":\"$market2\",\"type\":\"$side1\",\"amount\":\"$quantity\",\"limitPrice\":\"$price\"}"

    mysig=$(echo -n "$body1" | openssl dgst -sha512 -hmac "$skey2")
  mysig1="${mysig:9}"
    
    (curl -s --request POST \
    --url $urleq \
     -H "Content-Type: application/json" \
     -H "Hash: $mysig1" \
    --data "$body1" )
    
#Places an order in a given market. Permission required: Place Order


#POST https://www.southxchange.com/api/placeOrder
#Parameters
#Field	Description
#listingCurrency	Market listing currency
#referenceCurrency	Market reference currency
#type	Order type. Possible values: buy, sell
#amount	Order amount in listing currency
#limitPrice	Optional price in reference currency. If null then order is executed at market price
#Result
#Order code
 
     printf "\n"
###########################################################
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "exchangeX"
    
    printf "\n"
    
    fi
#####  4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444    
    elif [[ "$m" == "4" ]]; then
    ## Cancel Order
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    echo "Use <all> to Cancel ALL orders."
    read -p "Enter the uuid # " uuid
    
    curl -s --request POST \
    --user $ksvalue \
    --url $ENDPOINT$CANCEL  \
    --form uuid=$uuid
        
    printf "\n"
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    ## Cancel Order
    nonce1=$(date +%s%N | cut -b1-13) 
    signature1='&signature='
    cancel1='cancel?'
    nonce2='&nonce='
    skey1=$ksvalue2
    skey2=$ksvalue3
    xapi="'X-API-KEY: "
    xapi1=$skey1\'
    xapikey=\"$xapi$xapi1\"
    HMAC1="-hmac "
    HMAC=$HMAC1$skey2
        
    echo "Type cancel to cancel all orders in specified market pair"
    read -p "Enter the Order # " orderIDnum
    if [[ "$orderIDnum" == "cancel" ]]
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
   
#   Endpoint: /exchange/spot/cancelAll
#Type: POST
#Parameter	Description	Example
#(required) market	the chosen market pair	SCC_BTC
#(required) nonce	the incremental integer	UNIX Timestamp
#(required) signature	the parameter's HMAC signature	HEX Format
#Example: POST https://stakecube.io/api/v2/exchange/spot/cancelAll

#POST Body: market=SCC_BTC&nonce=123&signature=xxx"

   
   
   
   
   
       
    printf "\n"
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "SouthXchange"
    ## CANCEL Order
    
    # order = 179058298 
  
#  CANCEL ORDER

#Cancels a given order. Permission required: Cancel Order


#POST https://www.southxchange.com/api/cancelOrder
#Parameters
#Field	Description
#orderCode	Order code to cancel
#CANCEL MARKET ORDERS

#Cancels all orders in a given market. Permission required: Cancel Order


#POST https://www.southxchange.com/api/cancelMarketOrders
#Parameters
#Field	Description
#listingCurrency	Market listing currency
#referenceCurrency	Market reference currency
  
  
    nonce1=$(date +%s%N | cut -b1-13)
    skey1="$ksvalue4"
    skey2="$ksvalue5"
    
urleq="https://www.southxchange.com/api/cancelOrder"
read -p "Enter order code: " ordercode
body1="{\"key\":\"$skey1\",\"nonce\":\"$nonce1\",\"ordercode\":\"$ordercode\"}"

    mysig=$(echo -n "$body1" | openssl dgst -sha512 -hmac "$skey2")
  mysig1="${mysig:9}"
    
    (curl -s --request POST \
    --url $urleq \
     -H "Content-Type: application/json" \
     -H "Hash: $mysig1" \
    --data "$body1" )
   
    printf "\n"
        
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo " exchangeX"
    
    
    fi
##### 555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
    
    elif [[ "$m" == "5" ]]; then
    ## Dispay Order Book
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[36;40m'"\033[1m"
    (curl -s --request GET \
    --url $ENDPOINT$ORDERS$market | jq . | tr -d '{,"}' | sed 's/success: true//g')
       
        
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    ## Dispay Order Book     
    
    read -p "Enter Market [ONION_BTC]:" market ; market=${market:-ONION_BTC}
    echo -e '\E[36;40m'"\033[1m"
    
    (curl -s GET https://stakecube.io/api/v2/exchange/spot/orderbook?market=$market | jq . | tr -d '{,"}' | sed 's/success: true//g')
        
    echo "StakeCube"
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "SouthXchange"
#    BOOK

#Lists order book of a given market

#GET https://www.southxchange.com/api/book/{listingCurrencyCode}/{referenceCurrencyCode}
#See example

#Field	Description
#BuyOrders	Buy orders. Array of [Order entry]
#SellOrders	Sell orders. Array of [Order entry]
#[Order entry]
#Index	Incremental value for each book entry
#Amount	Book entry total amount
#Price	Book entry price

# read bid1 ask2 last3 < <(echo $(curl -v -X GET https://www.southxchange.com/api/book/ONION/BTC | jq -r '.Index, .Amount, .Price' | tr -d '"'))
#  bid1=$(echo "$bid1" | awk -F"E" 'BEGIN{OFMT="%10.8f"} {print $1 * (10 ^ $2)}')
#  ask2=$(echo "$ask2" | awk -F"E" 'BEGIN{OFMT="%10.8f"} {print $1 * (10 ^ $2)}')
#  last3=$(echo "$last3" | awk -F"E" 'BEGIN{OFMT="%10.8f"} {print $1 * (10 ^ $2)}')
#  echo "b " $bid1
#  echo "a " $ask2
#  echo "l " $last3

nonce1=$(date +%s%N | cut -b1-13)
 skey1="$ksvalue4"
 skey2="$ksvalue5"
 sxurleq="https://www.southxchange.com/api/book"

read -p "Which Listing Currency would you like [ONION]:" listingCurrency ; listingCurrency=${listingCurrency:-ONION}
read -p "which Reference Currency would you like [BTC]:" referenceCurrency ; referenceCurrency=${referenceCurrency:-BTC}
  
    (curl -s --request GET \
    --url $sxurleq/$listingCurrency/$referenceCurrency | jq -r )                                          # -r .[] | tr -d ',}{' )
     
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "exchangex"
    
    
    fi
    
    printf "\n"
  #####  6666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666 
    elif [[ "$m" == "6" ]]; then
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
       
    (curl --request GET \
    --url https://stakecube.io/api/v2/exchange/spot/myOpenOrder?nonce=$nonce1\&signature=$signature3 \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H "X-API-KEY: $skey1" | jq )
    #--data nonce=$nonce1 \
    #--data signature=$signature3 | jq )
       
   printf "\n" 
####################################################################    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    #echo "SouthXchange"
    
#  LIST ORDERS

#Lists all pending orders. Permission required: List Orders


#POST https://www.southxchange.com/api/listOrders
#Parameters
#None
#Result
#Field	Description
#Array of [Order entry]
#[Order entry]
#Code	Order code
#Type	Order type. Possible values: buy, sell
#Amount	Pending amount in listing currency
#OriginalAmount	Original amount in listing currency
#LimitPrice	Order price in reference currency
#ListingCurrency	Market listing currency
#ReferenceCurrency	Market reference currency

     
   nonce1=$(date +%s%N | cut -b1-13) 
   skey2=$ksvalue5

  mysig=$(echo -n "{\"key\":\"$ksvalue4\",\"nonce\":\"$nonce1\"}" | openssl dgst -sha512 -hmac "$skey2")
  mysig1="${mysig:9}"

    
(curl -s -X POST https://www.southxchange.com/api/listOrders -H "Content-Type: application/json" -H "Hash: $mysig1" -d "{\"key\":\"$ksvalue4\",\"nonce\":\"$nonce1\"}" | jq )
    
      
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "exchangeX"
    
    
    fi
    
    printf "\n"
##### 77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
    elif [[ "$m" == "7" ]]; then
    ## Market Ticker
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[33;40m'"\033[1m"
    curl -s --request GET \
    --url $ENDPOINT$TICKER$market
    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    
    
    read -p "Enter Market [ONION_BTC]:" market ; market=${market:-ONION_BTC}
    echo -e '\E[33;40m'"\033[1m"
  
 (curl -s --request GET https://stakecube.io/api/v2/exchange/spot/markets?market=$market | jq )
 
    printf "\n"
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "SouthXchange"
    
    read -p "Enter Listing coin [ONION]:" lcoin ; lcoin=${lcoin:-ONION}
    read -p "Enter Reference coin [BTC]:" rcoin ; rcoin=${rcoin:-BTC}
    (curl -X GET https://www.southxchange.com/api/price/$lcoin/$rcoin )
    
    printf "\n"
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "exchangeX"
        
    
    fi
    printf "\n"
#####  888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
    elif [[ "$m" == "8" ]]; then
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
    read -p "Enter Market [ONION_BTC]:" market ; market=${market:-ONION_BTC}
    (curl -s GET https://stakecube.io/api/v2/exchange/spot/trades?market=$market | jq . | tr -d '{[,"]}')
    #(curl GET  $ENDPOINT2$EXCHSPOTEP$TRADESMKT \
    # -d $market)
    
    # -H "Content-Type: application/x-www-form-urlencoded"
   # echo $ENDPOINT2$EXCHSPOTEP$TRADESMKT$market
    unset market
    
    
    # echo "StakeCube"
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "SouthXchange"
 nonce1=$(date +%s%N | cut -b1-13)   
 nonce2=1369678202000  # May 27, 2013 2:10:02 PM GMT
    
(curl -X  GET https://www.southxchange.com/api/history/{ONION}/{BTC}/{$nonce2}/{$nonce1}/{1} | jq . | tr -d '{[,"]}')   
     
#    HISTORY ( historical market data )

#List market history between two dates


#GET https://www.southxchange.com/api/history/{listingCurrencyCode}/{referenceCurrencyCode}/{start}/{end}/{periods}
#See example

#Parameters
#Field	Description
#listingCurrencyCode	Market listing currency
#referenceCurrencyCode	Market reference currency
#start	Start date in milliseconds from January 1, 1970
#end	End date in milliseconds from January 1, 1970
#periods	Number of periods to get (Optional: defaults to 100)
#Result
#Array of [History Entry]
#[History Entry]
#Date	Start date of the period
#PriceHigh	Highest price of the period
#PriceLow	Lowest price of the period
#PriceOpen	First price of the period
#PriceClose	Last price of the period
#Volume	Volume of the period
    
    
    printf "\n"   
    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "exchangeX"
    
    
    fi
    printf "\n"
#####  99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
    elif [[ "$m" == "9" ]]; then
    ## All Markets
    
    if [[ "$ENDPOINT" == "$ENDPOINT1" ]]; then
    echo -e '\E[34;40m'"\033[1m"
    (curl -s --request GET \
    --url $ENDPOINT$MARKETS | jq -cn --stream "fromstream(1|truncate_stream(inputs))")
    
    elif [[ "$ENDPOINT" == "$ENDPOINT2" ]]; then
    
    read -p "Enter Base Market [BTC]:" market ; market=${market:-BTC}
    echo -e '\E[34;40m'"\033[1m"
    (curl -s GET https://stakecube.io/api/v2/exchange/spot/markets?baseMarket=$market&orderBy=volume | jq -cn --stream "fromstream(1|truncate_stream(inputs))")
    echo -e '\E[33;40m'"\033[1m"; read -n 1 -r -s -p $'Waiting for response. After response, press any key to continue...\n' a
    echo -e '\E[32;40m'"\033[1m"
    # curl GET https://stakecube.io/api/v2/exchange/spot/markets?baseMarket=BTC&orderBy=volume
    # echo -e '\E[33;40m'"\033[1m"
    # echo "Press any key to continue..."
    
    
    elif [[ "$ENDPOINT" == "$ENDPOINT3" ]]; then
    echo "SouthXchange"
   
 (curl -s -X GET https://www.southxchange.com/api/markets | jq -sc 'sort_by(.)[]' ) # | tr -d '"')
 #| jq . ) #| tr -d '{["]}')
 # | jq -s 'sort_by(.date)'
# 
#    MARKETS

#Lists all markets


#GET https://www.southxchange.com/api/markets
#See example

#Field	Description
#Array of [Market entry]
#[Market entry] (Array)
#Index 0	Listing currency code
#Index 1	Reference currency code


#
#MARKETS (Version 2)

#Lists all markets


#GET https://www.southxchange.com/api/v2/markets
#See example

#Field	Description
#Array of [Market entry]
#[Market entry] (Array)
#Index 0	Listing currency code
#Index 1	Reference currency code
#Index 2	Market ID

    elif [[ "$ENDPOINT" == "$ENDPOINT4" ]]; then
    echo "exchangeX"
    
    
    fi
            
    printf "\n" 
#####  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    elif [[ "$m" == "10" ]]; then
    ## Miscellaneous
     i=1
while [ $i = 1 ] ; do
clear
echo -e '\E[32;40m'"\033[1m"
echo "Miscellaneous"
echo -e '\E[33;40m'"\033[1m"
echo "Exit this menu             = 0"
echo "Arbitrage (By StakeCube)   = 1"
echo "StakeCube Account info     = 2"  
echo "Check for Update           = 3" 
echo "SouthXchange New Address   = 4"  
echo "Epoch Date Converter       = 5"
echo "My address list            = 6"
echo "SouthXchange withdraw      = 7"
echo "StakeCube My Order History = 8"
echo
read -p "Type a number [0, 1, 2, 3, 4, 5, 6, 7, 8] :" x

   case $x in
    0) echo -ne '\n' | showMenu
    $x=0
    i=0   
    ;;
    1) read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
       (curl --request GET https://stakecube.io/api/v2/exchange/spot/arbitrageInfo?ticker=ONION | jq )
    i=0
    ;;
    2) skey1=$ksvalue2
       nonce1=$(date +%s%N | cut -b1-13)
       skey2=$ksvalue3
       signature3=$(printf "nonce=$nonce1" | openssl dgst -sha256 -hmac "$skey2"  | sed 's/.*= //')
      
       (curl --request GET \
       --url https://stakecube.io/api/v2/user/account?nonce=$nonce1\&signature=$signature3 \
       -H 'Content-Type: application/x-www-form-urlencoded' \
       -H "X-API-KEY: $skey1" | jq ) 
    i=0
    ;;
    3) LATESTVER=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/kk80586/tradeONION/tags | grep -n 'v1' | head -1 | sed -n 's/name//p' | sed 's/.*://' | tr -d  ' ":v,-')
       echo -e '\E[33;40m'"\033[1m"
       echo "Latest version is:" $LATESTVER
       echo "Your verion is   :" $CURRVER
    i=0
    ;;
    4) nonce1=$(date +%s%N | cut -b1-13) 
       skey1=$ksvalue4 
       skey2=$ksvalue5
       read -p "Enter Market [ONION]:" market ; market=${market:-ONION}
       mysig=$(echo -n "{\"key\":\"$skey1\",\"nonce\":\"$nonce1\",\"currency\":\"$market\"}" | openssl dgst -sha512 -hmac "$skey2")
       mysig1="${mysig:9}"
       curl -X POST https://www.southxchange.com/api/generatenewaddress -H "Content-Type: application/json" -H "Hash: $mysig1" -d "{\"key\":\"$skey1\",\"nonce\":\"$nonce1\",\"currency\":\"$market\"}"
       read -p "Press ENTER to continue:" z
    i=0
    ;;
    5) read -p "Type or paste Epoch time :" EPOCHTIME
       echo -e '\E[36;40m'"\033[1m"
       DATETIME= date -d @$EPOCHTIME
       echo $DATETIME
       read -p "Press ENTER to continue:" z
    i=0
    ;;
    6) ## Rate Limits
       #(curl -s -X GET https://stakecube.io/api/v2/system/rateLimits |jq )
       echo "You can create a list of exchange addresses or other info you wish to save."
       echo "The editor used is nano. You can change that in the script if you wish to use" 
       echo "a different editor."
       echo "This will create and/or open a file named exchanges.txt in you home (user) directory."
       echo "If you chose this option by accident just close the editor ( <CTRL> z ) or close" 
       echo "the program window if using GUI."
       read -p "Press ENTER to continue:" z
       $editor ~/exchanges.txt
    i=0
    ;;
    7) nonce1=$(date +%s%N | cut -b1-13)
       skey1="$ksvalue4"
       skey2="$ksvalue5"
       sxurleq="https://www.southxchange.com/api/withdraw"
       body1="{\"key\":\"$skey1\",\"nonce\":\"$nonce1\",\"currency\":\"ONION\",\"address\":\"DYyWY1YS7EDFVKjtTW3i5JEdR61beBYzLF\",\"amount\":\"5\"}"
       mysig=$(echo -n "$body1" | openssl dgst -sha512 -hmac "$skey2")
       mysig1="${mysig:9}"
       (curl -s --request POST \
       --url $sxurleq \
       -H "Content-Type: application/json" \
       -H "Hash: $mysig1" \
       --data "$body1" | jq )
    i=0
    ;;
    8) nonce1=$(date +%s%N | cut -b1-13)
       market=ONION_BTC    
       skey1=$ksvalue2 
       skey2=$ksvalue3
       read -p "Which market would you like [ONION_BTC]:" market ; market=${market:-ONION_BTC}
       echo -e '\E[32;40m'"\033[1m"
       signature3=$(printf "market=ONION_BTC&limit=100&nonce=$nonce1" | openssl dgst -sha256 -hmac "$skey2"  | sed 's/.*= //')
       mysig2=$signature1$mysig
       (curl -H "Content-Type: application/x-www-form-urlencoded" -H "X-API-KEY: $skey1" \
       --request GET "$ENDPOINT2""$EXCHSPOTEP"market=ONION_BTC\&limit=100\&nonce="$nonce1"\&signature="$signature3" | jq )
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
    
    
    
    
    
    
    
    
    printf "\n"
#####  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB    
    elif [[ "$m" == "11" ]]; then
    ## Choose Exchange

i=1
while [ $i = 1 ] ; do
clear
echo -e '\E[32;40m'"\033[1m"
echo "Choose an exchange"
echo -e '\E[33;40m'"\033[1m"
echo "TradeOgre    = 1"  
echo "StakeCube    = 2" 
echo "SouthXchange = 3"  
#echo "exchangeX    = 4" 
echo
read -p "Type a number [1, 2, 3] :" x

   case $x in
    1) ENDPOINT=$ENDPOINT1
    ksvalue=$ksvalue1
    i=0
    ;;
    2) ENDPOINT=$ENDPOINT2
    ksvalue=$ksvalue2
    skey1=$ksvalue2 
    skey2=$ksvalue3
    #echo $skey2
    i=0
    ;;
    3) ENDPOINT=$ENDPOINT3
    ksvalue=$ksvalue4
    #echo $ksvalue5
    i=0
  #  ;;
  #  4) ENDPOINT=$ENDPOINT4
  #  ksvalue=$ksvalue6
  #  i=0
    ;;
    *) 
    i=1;;
  
  esac
done
echo -e '\E[32;40m'"\033[1m"  
#echo $ENDPOINT  
#echo $ksvalue
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

####################################################################################################################################
# ChangeLog -                                                                                                                      #
# 05/31/2022 - Change TradeOgre to BUY or SELL. (#3)                                                                               #
# 


clear
exit 0;
