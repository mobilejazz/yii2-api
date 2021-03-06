#!/bin/bash

# Create symbolic link for the site
rm -rf /var/www/html
ln -s /app/app /var/www/html

source /config


# Create database
mysql -uroot -p${mysql_root_password} -e "CREATE DATABASE ${image_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# Create user
mysql -uroot -p${mysql_root_password} -e "GRANT ALL PRIVILEGES ON ${image_name}.* TO ${image_name}@localhost IDENTIFIED BY '${mysql_app_password}'"

# Go to app folder
cd /app/app

# Update config files
sed -i "s/%database_name%/${image_name}/g" environments/dev/common/config/main-local.php
sed -i "s/%database_name%/${image_name}/g" environments/prod/common/config/main-local.php
sed -i "s/%app_password%/${mysql_app_password}/g" environments/dev/common/config/main-local.php
sed -i "s/%app_password%/${mysql_app_password}/g" environments/prod/common/config/main-local.php
sed -i "s/%mandrill_api_key%/${mandrill_api_key}/g" environments/dev/common/config/main-local.php
sed -i "s/%mandrill_api_key%/${mandrill_api_key}/g" environments/prod/common/config/main-local.php
sed -i "s/%parse_appid%/${parse_appid}/g" environments/dev/common/config/main-local.php
sed -i "s/%parse_appid%/${parse_appid}/g" environments/prod/common/config/main-local.php
sed -i "s/%parse_masterkey%/${parse_masterkey}/g" environments/dev/common/config/main-local.php
sed -i "s/%parse_masterkey%/${parse_masterkey}/g" environments/prod/common/config/main-local.php
sed -i "s/%parse_apikey%/${parse_apikey}/g" environments/dev/common/config/main-local.php
sed -i "s/%parse_apikey%/${parse_apikey}/g" environments/prod/common/config/main-local.php

sed -i "s/%languages%/${languages}/g" api/config/main.php
sed -i "s/%languages%/${languages}/g" backend/config/main.php
sed -i "s/%languages%/${languages}/g" frontend/config/main.php


sed -i "s/%app_name%/${app_name}/g" common/config/main.php


# Install composer packages
composer global require "fxp/composer-asset-plugin"
composer update
composer install

# Init yii
./init --env=$1 --overwrite=All

# Yii migate
./yii migrate --interactive=0

# Add oauth client
mysql -uroot -p${mysql_root_password} -e "USE ${image_name}; DELETE FROM oauth_clients;";
mysql -uroot -p${mysql_root_password} -e "USE ${image_name}; INSERT INTO oauth_clients (client_id, client_secret, redirect_uri, grant_types, scope, user_id) VALUES ('${oauth_client_name}', '${oauth_client_pass}', 'http://${image_name}', 'client_credentials password refresh_token', NULL, NULL);"


# Update deploy scripts
cd /app/deploy

cp config.sample.php config.php
sed -i "s/%environment%/$1/g" config.php
sed -i "s/%branch%/$2/g" config.php
sed -i "s/%app_name%/${app_name}/g" config.php

echo "www-data ALL=(ALL) NOPASSWD: /app/deploy/deploy" >> /etc/sudoers
