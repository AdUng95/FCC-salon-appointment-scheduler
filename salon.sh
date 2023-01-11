#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

# show available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # if service chosen not available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "Sorry we do not provide that service, please choose another one."
    else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    # get customer choice
    read SERVICE_ID_SELECTED
    # if customer choice is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "Sorry, that is not a valid number! Please try again."
      else
        AVAIL_SERVICES2=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id = $SERVICE_ID_SELECTED")
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      #if a number but not available
        if [[ -z $AVAIL_SERVICES2 ]]
        then
        # send back to main menu
          MAIN_MENU "Sorry, that is not a service we provide. Is there another service you would like today?"
          else
          echo -e "\nWhat is your phone number?"
          read CUSTOMER_PHONE
        # check if existing or new customer
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          # if new customer, get name and phone then add to table
          if [[ -z $CUSTOMER_NAME ]]
          then
            echo -e "\nIt appears I do not have your number on record, may I have your name please?"
            read CUSTOMER_NAME
            INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          
          # ask for desired appointment time
          echo "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
          read SERVICE_TIME
          # update appt table with info given
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          INSERT_APPT_INFO=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

        # if an existing customer
          else
          # ask for appt time for selected service
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          echo "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
          read SERVICE_TIME
          # update appt table with info given
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          INSERT_APPT_INFO=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
          fi
        fi
    fi
  fi
}

MAIN_MENU
