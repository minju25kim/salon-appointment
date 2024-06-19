#!/bin/bash

PSQL="psql -X -A --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"

PRINT_SERVICES(){
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while IFS=" | " read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

PUT_CUSTOMERS(){
 $PSQL "INSERT INTO customers (name,phone) VALUES ('$1','$2')"
}

GET_CUSTOMER(){
  CUSTOMER=$($PSQL "SELECT * FROM customers WHERE phone='$1'")
  echo "$CUSTOMER"
}

PUT_APPOINTMENTS(){
  $PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($1,$2,'$3')"
  # get service from service id
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$2")
  # get name from customer id
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$1")
  echo "I have put you down for a $SERVICE_NAME at $3, $CUSTOMER_NAME."
}

CHECK_CUSTOMER(){
  SERVICE_ID=$1
  echo what is your phone number?
  read CUSTOMER_PHONE
  CUSTOMER="$(GET_CUSTOMER $CUSTOMER_PHONE)"
  if [[ $CUSTOMER ]] 
  then
    echo what time do you want?
    read SERVICE_TIME
    echo $CUSTOMER | while IFS="|" read CUSTOMER_ID NAME PHONE
    do
      PUT_APPOINTMENTS $CUSTOMER_ID $SERVICE_ID $SERVICE_TIME
    done
  else
    echo what is your name?
    read CUSTOMER_NAME
    echo what time do you want?
    read SERVICE_TIME
    PUT_CUSTOMERS $CUSTOMER_NAME $CUSTOMER_PHONE
    CUSTOMER="$(GET_CUSTOMER $CUSTOMER_PHONE)"
    echo $CUSTOMER | while IFS="|" read CUSTOMER_ID NAME PHONE
    do
      PUT_APPOINTMENTS $CUSTOMER_ID $SERVICE_ID $SERVICE_TIME
    done
  fi
}

CHECK_SERVICE_ID_SELECTED(){
  if [[ $1 ]] 
  then
    CHECK_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$1")
    # echo "$CHECK_SERVICE_ID
    if [[ $CHECK_SERVICE_ID ]] 
    then
      CHECK_CUSTOMER $CHECK_SERVICE_ID
    else
      MAIN_MENU "No such service."
    fi
  fi
}

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "How may I help you?" 
  PRINT_SERVICES
  read SERVICE_ID_SELECTED
  CHECK_SERVICE_ID_SELECTED $SERVICE_ID_SELECTED
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU
