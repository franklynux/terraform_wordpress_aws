#!/bin/bash

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /tmp/wordpress_install_log.txt
}

# Function to handle errors
handle_error() {
    if [ $? -ne 0 ]; then
        log_message "$1 failed. Exiting script."
        exit 1
    fi
}

log_message "Starting WordPress installation script"

# Install required packages including AWS CLI
log_message "Installing required packages"
sudo apt-get update -y
sudo apt-get install -y mysql-client apache2 php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip awscli
handle_error "Installing required packages"

# Fetch RDS endpoint from AWS SSM Parameter Store
log_message "Fetching RDS endpoint from AWS SSM Parameter Store"
RDS_ENDPOINT=$(aws ssm get-parameter --name "/wordpress/rds_endpoint" --query "Parameter.Value" --output text --region us-east-1)
handle_error "Fetching RDS endpoint"

# Extract RDS hostname and port number separately
MYSQL_HOST=$(echo $RDS_ENDPOINT | cut -d':' -f1)
MYSQL_PORT=$(echo $RDS_ENDPOINT | cut -d':' -f2)
log_message "RDS Host: $MYSQL_HOST, Port: $MYSQL_PORT"

MYSQL_USER="${MYSQL_USER:-wordpress}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-word1press2!}"
MYSQL_DATABASE="${MYSQL_DATABASE:-wordpressDB}"

# Set up MySQL database
log_message "Setting up MySQL database"
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
handle_error "Database setup"
log_message "Database setup completed"

# Download and set up WordPress
log_message "Downloading and setting up WordPress"
sudo wget https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz
handle_error "Downloading WordPress"

sudo tar xzf /tmp/latest.tar.gz -C /tmp/
handle_error "Extracting WordPress"

sudo rsync -avP /tmp/wordpress/ /var/www/html/
handle_error "Copying WordPress files"

sudo rm -f /var/www/html/index.html

cd /var/www/html/
sudo cp wp-config-sample.php wp-config.php
handle_error "Copying wp-config.php"

# Update wp-config.php with database settings
log_message "Updating wp-config.php"
sudo sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
sudo sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
sudo sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
sudo sed -i "s/'localhost'/'${MYSQL_HOST}'/" wp-config.php
handle_error "Updating wp-config.php with database settings"

# Add salt keys to wp-config.php
log_message "Adding security keys to wp-config.php"
sudo curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sudo tee -a wp-config.php > /dev/null
handle_error "Fetching WordPress salt keys"

# Set permissions
log_message "Setting permissions on /var/www/html/"
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;
log_message "Permissions set"

# Configure Apache
log_message "Configuring Apache"
sudo sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
handle_error "Updating Apache configuration"

sudo systemctl restart apache2
handle_error "Restarting Apache"
log_message "Apache configured and restarted"

# Health check script
log_message "Creating health check script"
cat <<EOF | sudo tee /var/www/html/health.php
<?php
require_once('wp-config.php');

\$conn = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
if (\$conn->connect_error) {
    header("HTTP/1.1 500 Internal Server Error");
    echo "Database connection failed: " . \$conn->connect_error;
} else {
    echo "Alright Sparky! Database Connection Successful!";
}
\$conn->close();
?>
EOF

log_message "Health check script created"

log_message "WordPress installation script completed"

# Completion message
echo "WordPress installation is complete. Visit your server's public IP to complete the installation."
echo "Health check page is available at: http://your-server-ip/health.php"
echo "Installation log available at: /tmp/wordpress_install_log.txt"
