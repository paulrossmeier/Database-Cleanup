#!/bin/bash
#KEY=$(curl -s 'https://sjc-api.objectrocket.com/v2/tokens/' --user 'prossmeier@objectrocket.com' | python -m json.tool | grep token)



#TOKEN=API_TOKEN

#First Auth to get the API token:

TOKEN=$(curl -s 'https://sjc-api.objectrocket.com/v2/tokens/' --user prossmeier@objectrocket.com | python -m json.tool | grep token | tr -d '"' |  awk -F ":" '{ print $2}' | sed 's/,*$//g')

echo "Your API token is $TOKEN"



INSTANCES=$(curl -s https://sjc-api.objectrocket.com/v2/instances/ -H "X-Auth-Token: $TOKEN" | python -m json.tool | grep name | tr -d '"' |  awk -F ":" '{ print $2}' | sed 's/,*$//g' | tr -d ' ')

#INSTANCES=$(echo $INSTANCE | tr -d ' ')

echo "$INSTANCES" > /tmp/instance_list

echo "You have the following instances on this account: "
cat /tmp/instance_list

#INSTANCES=$(echo $INSTANCE | tr -d ' ')

echo $INSTANCES


#echo "https://sjc-api.objectrocket.com/v2/mongodb/$INSTANCE/databases"
echo "https://sjc-api.objectrocket.com/v2/mongodb/$INSTANCES/databases"

#curl -s https://sjc-api.objectrocket.com/v2/mongodb/$INSTANCES/databases -H "X-Auth-Token: $TOKEN" | python -m json.tool | grep name

DATABASES=$(curl -s https://sjc-api.objectrocket.com/v2/mongodb/$INSTANCES/databases -H "X-Auth-Token: $TOKEN" | python -m json.tool | grep name | tr -d '"' |  awk -F ":" '{ print $2}' | sed 's/,*$//g' | tr -d ' ')

echo $DATABASES > /tmp/database_list

echo "You have the following datbases on "  `cat /tmp/instance_list`   `cat /tmp/database_list`


rm /tmp/instance_list
rm /tmp/database_list

exit 0
