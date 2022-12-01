counter=0

echo "Updated passwords of already existing users" > updated_passwords_for_existing_users.sh
echo "USE ctf2;" > db_harden_passwords.sql

while [ $counter -lt $1 ]
do
    password=$(openssl rand -base64 32)
    hashed_password=$(htpasswd -bnBC 10 "" $password | tr -d ':')
    echo -e "user_$counter: $password \t>>>\t $hashed_password" >> updated_passwords_for_existing_users.sh
    echo "SELECT user FROM users LIMIT $counter, 1 INTO @curr_user;" >> db_harden_passwords.sql
    echo "UPDATE users SET pass=\"$hashed_password\" WHERE user=@curr_user;" >> db_harden_passwords.sql
    ((counter++))
done