sudo mysql -u"root" -p"rootmysql" < secure_db.sql

sudo cp *.php /var/www/html

number_of_users=$(mysql -uroot -prootmysql < count_users.sql | grep "[0-9]")
bash harden_passwords.sh $number_of_users