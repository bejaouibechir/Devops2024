# Use the official PHP base image
FROM php:apache

WORKDIR /var/www/html

# Install mysqli extension
RUN docker-php-ext-install mysqli

# Copy the website files into the container
COPY src/ .

# Expose port 80
EXPOSE 80

