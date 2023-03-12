#!/bin/sh

sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

sudo apt update -y

sudo apt upgrade -y

sudo apt install git -y

sudo apt install nginx -y

sudo apt install mysql-server -y

sudo apt install redis-server -y

sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y

sudo add-apt-repository ppa:ondrej/php -y

sudo apt update -y

sudo apt install php8.2 -y

sudo apt install php8.2-fpm -y

sudo apt install php8.2-redis -y

sudo apt install php8.2-bcmath -y

sudo apt install php8.2-curl -y

sudo apt install php8.2-json -y

sudo apt install php8.2-mbstring -y

sudo apt install php8.2-mysql -y

sudo apt install php8.2-pdo -y

sudo apt install php8.2-tokenizer -y

sudo apt install php8.2-xml -y

sudo apt install php8.2-zip -y

sudo curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php

sudo HASH=`curl -sS https://composer.github.io/installer.sig`

sudo php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

sudo sed -i 's/#Port 22/Port 8590/g' /etc/ssh/sshd_config

sudo systemctl restart sshd

sudo rm -rf /var/www/html/*

sudo chown -R $USER:www-data /var/www

sudo chmod -R 775 /var/www

cd $HOME

mkdir .git

git init .git/ --bare

touch .git/hooks/post-receive

echo '#!/bin/sh\numask 022\nGIT_WORK_TREE=/var/www/html git checkout -f' > .git/hooks/post-receive

chmod +x .git/hooks/post-receive

sudo echo 'server {
    listen 80;
    listen [::]:80;
    server_name example.com;
    root /srv/example.com/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}' > /etc/nginx/sites-available/default
