#!/bin/bash

####### This script is incomplete #######
###### Still need to find a way to remove non-mongo instances from $INSTANCES ######
#### Still need to compare $COLLECTIONS to empty set - and automatically add to /tmp/delete_databases#####
##### still need to add the DELETE_DATABASE API calls/loops#######
#### Still need to add error catching logic ######


#TOKEN=API_TOKEN
#INSTANCES=instances on the account (still need to filter out non mongo instances)
#DATABASES=Databases that are in each mongo instance
#COLLECTIONS=Collections in each database

#Get ObjectRocket UI username:
echo "Welcome to the empty database delection script"
echo ""
sleep .5
echo -n "Enter your ObjectRocket Login and press [ENTER]  "
read NAME

#First Auth to get the API token:
TOKEN=$(curl -s 'https://sjc-api.objectrocket.com/v2/tokens/' --user $NAME | python -m json.tool | grep token | tr -d '"' |  awk -F ":" '{ print $2}' | sed 's/,*$//g')

#check to see if it works
echo "Your API token is $TOKEN"
#=============================

#Next - Get the instance list
INSTANCES=$(curl -s https://sjc-api.objectrocket.com/v2/instances/ -H "X-Auth-Token: $TOKEN" | python -m json.tool | grep name | tr -d '"' |  awk -F ":" '{ print $2}' | sed 's/,*$//g' | tr -d ' ')

#Temp store the instance list
echo "$INSTANCES" > /tmp/instance_list

#Verify that it worked
echo "You have the following INSTANCES on this account: "
cat /tmp/instance_list

#add space
echo ""
echo ""
#=====================

#loop through the instances to get databases/collections/document count
for i in $INSTANCES;
do
#    echo $i
    DATABASES=$(curl -s https://sjc-api.objectrocket.com/v2/mongodb/$i/databases -H "X-Auth-Token: $TOKEN" | python -m json.tool | grep name | tr -d '"' |  awk -F ":" '{ print $2}' | sed 's/,*$//g' | tr -d ' ')
    for d in $DATABASES
    do
#      echo $d
      #echo "https://sjc-api.objectrocket.com/v2/mongodb/$i/databases/$d/collections/"
      #COLLECTIONS=$(curl -s https://sjc-api.objectrocket.com/v2/mongodb/$i/databases/$d/collections/ -H "X-Auth-Token: $TOKEN" | python -m json.tool | grep -v data | grep -vE "objectrocket.init|\}|\]|\{" | sed 's/,*$//g' | tr -d ' ' | tr -d '"')
      echo "Collections on INSTANCE $i, DATABASE $d"
      COLLECTIONS=$(curl -s https://sjc-api.objectrocket.com/v2/mongodb/$i/databases/$d/collections/ -H "X-Auth-Token: $TOKEN" | python -m json.tool | grep -v data | grep -vE "objectrocket.init|\}|\]|\{" | sed 's/,*$//g' | tr -d ' ' | tr -d '"')
      #collections for loop
      for c in $COLLECTIONS
      do
#        echo $c
        COUNT=$(curl -s https://sjc-api.objectrocket.com/v2/mongodb/$i/databases/$d/collections/$c/ -H "X-Auth-Token: $TOKEN" |  python -m json.tool | grep -v shards | grep size | tr -d '"' |  awk -F ":" '{ print $2}' | sed 's/,*$//g' | uniq )
        echo "The collection \"$c\" has $COUNT documents"
        if [ $COUNT -gt 0 ]; then
            echo Keep \"$c\"
            echo ""
	    echo $c >> /tmp/not_empty_collections
            echo $d >> /tmp/keep_databass
        else
            echo remove \"$c\"
            echo ""
	    echo $c >> /tmp/empty_collections
            echo $d >> /tmp/delete_databases
        fi
        done
      #echo $COLLECTIONS
      echo""
      done
done

#cat  /tmp/keep_databass
#cat  /tmp/delete_databases
echo ""
echo ""

clear
sleep 2

echo""
echo "The following collections will be removed"
echo `cat /tmp/empty_collections`

sleep 1
echo ""
echo ""
echo "The following collections will be kept"
cat /tmp/not_empty_collections
echo ""
rm -rf /tmp/empty_collections
rm -rf /tmp/not_empty_collections
rm -rf /tmp/instance_list
rm -rf /tmp/keep_databass
rm -rf /tmp/delete_databases
sleep 5

exit 0
