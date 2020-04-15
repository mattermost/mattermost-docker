#!/bin/bash

function remove_mattermost_user (){
    echo "Remove mattermost user with email: $1"
    mattermost user delete $1 --confirm
}

echo "---------------------------------------------------------------"
echo "Warning! This script with delete all mattermost users except for your Mattermost System Admin user"
echo "Warning! This script will delete all mattermost teams except for bond-financial"

echo "---------------------------------------------------------------"
echo "Input login_id corresponding to your Mattermost System Admin."
read -p 'mattermost login_id (e.g., user@bond.tech): ' login_id
read -sp 'mattermost password: ' password

echo "---------------------------------------------------------------"
# ssh into mattermost instance
# ssh -i "mm_key_pair.pem" root@ec2-18-191-19-234.us-east-2.compute.amazonaws.com
mattermost_api=http://localhost:8000/api/v4/

echo -e "\nGet mattermost header login_id: $login_id, password: $password, mattermost_api: $mattermost_api"
header_token=$(curl -i -d '{"login_id":"'$login_id'","password":"'$password'"}' ${mattermost_api}users/login | tr -d '\r' | sed -En 's/^Token: (.*)/\1/p')
echo "Mattermost token found: $header_token"
if [ -z "$header_token" ];
then
    echo "Unable to fetch token from mattermost."
    exit 1
fi

echo "---------------------------------------------------------------"
echo -e "\nGet my mattermost user"
curl -i -H "Authorization: Bearer $header_token" -H 'Content-Type: application/json' ${mattermost_api}users/me
my_user_roles=$(curl -i -H "Authorization: Bearer $header_token" -H 'Content-Type: application/json' ${mattermost_api}users/me | tail -n -1 | jq -r '.["roles"]')


echo "---------------------------------------------------------------"
echo -e "\nGet my mattermost user roles: $my_user_roles \n"
if [[ $my_user_roles != *"system_admin"* ]]
then
    echo "User is not a System Admin!"
    exit 1
fi

echo "---------------------------------------------------------------"
# curl -i -H 'Authorization: Bearer 6rknhashnbd65m1i356aph6iwe' -H 'Content-Type: application/json' http://localhost:8065/api/v4/users
echo "Get mattermost users header_token: $header_token, mattermost_api: $mattermost_api"
user_info=$(curl -i -H "Authorization: Bearer $header_token" -H 'Content-Type: application/json' ${mattermost_api}users | tail -n -1) 
echo "Mattermost users found: $user_info"

echo "---------------------------------------------------------------"
echo "Loop and remove each mattermost users except super admin user."
for email in $(echo "${user_info}" | jq -r '.[] | @base64'); do
    _jq() { echo ${email} | base64 -decode | jq -r ${1}
    }
    email=$(_jq '.email')
    if [ "$login_id" != "$email" ] && [ "qa@bond.tech" != "$email" ] && [ "admin@bond.tech" != "$email" ];
    then
        remove_mattermost_user $email
    fi
done

echo "---------------------------------------------------------------"
echo "Loop and remove each mattermost teams except bond-financial team."
for i in `mattermost team list | grep -v "{"`
do
    if [[ $i != "bond-financial" ]]
    then
        echo "Delete team "$i
        mattermost team delete $i --confirm
    fi
done

echo "System Admin User: "
mattermost user search $login_id
echo "Bond Financial Team: "
mattermost team list

echo -e "All users and teams are purged sucessfully!"
