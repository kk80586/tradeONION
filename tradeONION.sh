#!/bin/bash
# 
# WARNING: Buy and Sell ONLY show ONION price (not bid or ask)
# This software is not associated with nor endorsed by DeepOnion© or TradeOgre© who shall be held harmless for use or misuse of this product.
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
# ac67d2345:1d742a34c9  (they will be much longer)                           #
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
# Complete converting script to dynamic. 
# Complete [default] inputs. 
# Learn at least enough jq to pretty up the output.
# Convert all calls to TradeOgre.
#  
##############################################################################
## Set key and secret.
# KEY=
# SECRET=
#
ksvalue1=`cat shellogreks.txt`
ksvalue2=`cat stacubeks.txt`
ksvalue3=`cat citcoks.txt`
ksvalue4=`cat sxchangeks.txt`
ksvalue=$ksvalue1
#    echo $ksvalue
#
# HMAC
#echo -n "password" | openssl sha256 -hmac "nonbase64key"
#echo -n "value" | openssl sha1 -hmac "key"
#
#######################
#                  ######## ENDPOINTS #########
ENDPOINT1=https://tradeogre.com/api/v1/
ENDPOINT2=https://stakecube.io/api/v2/
ENDPOINT3=https://www.citex.co.kr/api/v2/
ENDPOINT4=https://www.southxchange.com/api/v4/
ENDPOINT=$ENDPOINT1
# endpoints Public API    ( All are method (GET) )
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
CURRVER=1.0.0
#######################
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
showMenu(){
echo -e '\E[32;40m'"\033[1m"
unset market ; unset quantity ; unset price 
  echo "===================================="
  echo "    ShellOgreONION    "
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

    elif [[ "$m" == "2" ]]; then
    ## Get All Balances.
    
   # read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo "Your Coin balances are: "
    echo -e '\E[33;40m'"\033[1m"
    (curl -s --request GET \
    --url $ENDPOINT$MYBALANCES \
    --user $ksvalue | jq -c -r  '.balances | to_entries[] | [ "\(.key), \(.value)" ]' | sed '/0.00000000/d' | tr '[]"' ' ' )
    echo -e '\E[32;40m'"\033[1m"
        
    elif [[ "$m" == "3" ]]; then
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
    printf "\n"
    
    elif [[ "$m" == "4" ]]; then
    ## Buy BTC with ONION

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
    printf "\n"
        
    elif [[ "$m" == "5" ]]; then
    ## Cancel Order
    
    echo "Use <all> to Cancel ALL orders."
    read -p "Enter the uuid # " uuid
    
    curl -s --request POST \
    --user $ksvalue \
    --url $ENDPOINT$CANCEL  \
    --form uuid=$uuid 
        
    printf "\n"
        
    elif [[ "$m" == "6" ]]; then
    ## Dispay Order Book
    
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[36;40m'"\033[1m"
    (curl -s --request GET \
    --url $ENDPOINT$ORDERS$market | jq . | tr -d '{,"}' | sed 's/success: true//g')  
    
    elif [[ "$m" == "7" ]]; then
    ## Get My Market Orders
    
    unset market
    echo "Type <all> for all Markets."
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
    
    printf "\n"
        
    elif [[ "$m" == "8" ]]; then
    ## Market Ticker
    
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[33;40m'"\033[1m"
    curl -s --request GET \
    --url $ENDPOINT$TICKER$market 
    
    printf "\n"
    printf "\n"
        
    elif [[ "$m" == "9" ]]; then
    ## GET Market History
    
    read -p "Enter Market [BTC-ONION]:" market ; market=${market:-BTC-ONION}
    echo -e '\E[36;40m'"\033[1m""                    Latest trades are at bottom of list."
    echo -e '\E[34;40m'"\033[1m"
    echo "           DATE           TYPE              PRICE                  QUANTITY"
    echo -e '\E[32;40m'"\033[1m""           ----           ----              -----                  --------"
    (curl -s --request GET \
    --url $ENDPOINT$HISTORY$market | jq -cn --stream "fromstream(1|truncate_stream(inputs))")
                                     
    #  jq '.[].date |= todateiso8601' 
    #  | .[].departure |= todateiso8601'
    
    printf "\n"
        
    elif [[ "$m" == "10" ]]; then
    ## All Markets
      
    echo -e '\E[34;40m'"\033[1m"
    (curl -s --request GET \
    --url $ENDPOINT$MARKETS | jq -cn --stream "fromstream(1|truncate_stream(inputs))")
            
    printf "\n"  
        
    elif [[ "$m" == "11" ]]; then
    ## Date Converter
      
    read -p "Type or paste Epoch time :" EPOCHTIME
    echo -e '\E[36;40m'"\033[1m"
    DATETIME= date -d @$EPOCHTIME
    echo $DATETIME    
    
    printf "\n" 
    
    elif [[ "$m" == "12" ]]; then
    ## Check For Update
    
    LATESTVER=$(curl -s  -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/kk80586/ShellOgreONION/tags | grep -n 'v1' | head -1 | sed -n 's/name//p' | sed 's/.*://' | tr -d  ' ":v,-')
      echo -e '\E[33;40m'"\033[1m"
      echo "Latest version is:" $LATESTVER
      echo "Your verion is:   " $CURRVER
   
     printf "\n"
       
    elif [[ "$m" == "13" ]]; then
    ## TESTING area
    
           
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
