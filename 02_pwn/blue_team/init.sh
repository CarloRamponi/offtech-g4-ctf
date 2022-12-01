# Update the database scheme to be more secure and robust
sudo mysql -u"root" -p"rootmysql" < secure_db.sql

# For each existing user generate a new strong password and store them in a hashed format
number_of_users=$(mysql -u"root" -p"hT2yX5yoHIIURD6DU6InYupXq3k90HcZ" < count_users.sql | grep "[0-9]")
bash harden_passwords.sh $number_of_users
sudo mysql -u"root" -p"hT2yX5yoHIIURD6DU6InYupXq3k90HcZ" < db_harden_passwords.sql

# Copy the updated server files
sudo cp *.php /var/www/html