#! /bin/bash


PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\nWelcome to My Salon, how can I help you?\n"
SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME; do
  echo "$SERVICE_ID) $NAME"
done

GET_APPOINTMENT() {
  
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z "$SERVICE_NAME" ]]; then
    echo -e "\nI could not find that service. What would you like today?"
    SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME; do
      echo "$SERVICE_ID) $NAME"
    done

    GET_APPOINTMENT
  else
    # Prompt for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    if [[ -z "$CUSTOMER_ID" ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

    # Prompt for appointment time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Insert appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Confirmation message
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Start the process
GET_APPOINTMENT