#!/bin/bash

# Update the package list to ensure we have the latest information on available packages
sudo apt update -y

# Install the Apache2 web server
sudo apt install apache2 -y

# Start the Apache2 service to begin serving web pages
sudo systemctl start apache2

# Enable the Apache2 service to start automatically on system boot
sudo systemctl enable apache2

# Output a simple HTML message to the default web page
echo "<h1> Hello World </h1>"
