#!/bin/bash
{
# Update system
sudo apt-get -qq update
sudo apt-get -qq upgrade -y

# Install Git
sudo apt-get -qq install git -y

# Configure Apache2
sudo apt-get -qq install apache2 -y
sudo systemctl enable apache2
sudo apt-get -qq install libapache2-mod-wsgi-py3
sudo a2enmod wsgi

# Clone Django app repo
cd /var/www/
sudo git clone https://github.com/innerProduct97/parking_lot.git
sudo chown -R ubuntu:ubuntu parking_lot/
cd parking_lot/



# Install Python and Django dependencies
sudo apt-get -qq install python3-pip python3-dev libpq-dev -y
sudo pip3 install -q virtualenv
virtualenv env
source env/bin/activate
pip3 install -q -r requirements.txt
./manage.py migrate

public_ip=$(curl http://checkip.amazonaws.com/)


# Create Apache2 Virtual Host
sudo touch /etc/apache2/sites-available/parking_lot.conf
sudo echo "
<VirtualHost *:80>
        ServerName $public_ip
        DocumentRoot /var/www/parking_lot

        ErrorLog /var/log/vhost.log

        Alias /static /var/www/parking_lot/static
        <Directory /var/www/parking_lot/static>
                Require all granted
        </Directory>

        Alias /media /var/www/parking_lot/media
        <Directory /var/www/parking_lot/media>
                Require all granted
         </Directory>

        <Directory /var/www/parking_lot/parkingLot>
                <Files wsgi.py>
                        Require all granted
                </Files>
        </Directory>

        WSGIDaemonProcess parkingLot python-path=/var/www/parking_lot python-home=/var/www/parking_lot/env
        WSGIProcessGroup parkingLot
        WSGIScriptAlias / /var/www/parking_lot/parkingLot/wsgi.py

</VirtualHost>
" | sudo tee /etc/apache2/sites-available/parking_lot.conf

# Enable Virtual Host
sudo a2ensite parking_lot.conf

# Changing Apache User and Group

# Replace the User line in apache2.conf
sudo sed -i "s/^User \${APACHE_RUN_USER}$/User ubuntu/" /etc/apache2/apache2.conf

# Replace the Group line in apache2.conf
sudo sed -i "s/^Group \${APACHE_RUN_GROUP}$/Group ubuntu/" /etc/apache2/apache2.conf

# Restart Apache2
sudo systemctl restart apache2
} &> /dev/null
echo "App is deployed successfully!"
echo "You can access it through the URL:http://$public_ip/"
