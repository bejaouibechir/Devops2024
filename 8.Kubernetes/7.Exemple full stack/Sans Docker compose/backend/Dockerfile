# Use the official PHP base image
FROM php:apache

# Install mysqli extension
RUN docker-php-ext-install mysqli

# Copy the website files into the container
COPY src/ /var/www/html/

# Expose port 80
EXPOSE 80
