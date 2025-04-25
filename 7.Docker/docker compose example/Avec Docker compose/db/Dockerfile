FROM mysql

# Set the environment variables
ENV MYSQL_ROOT_PASSWORD=test123++
ENV MYSQL_DATABASE=businessdb
ENV MYSQL_USER=test
ENV MYSQL_PASSWORD=test123++


# Copy the script that will be executed on container startup
COPY script.sql /docker-entrypoint-initdb.d/

# Build the Docker image
# docker build -t your_image_name .

# Run the Docker container
# docker run -d -p 3308:3306 -v your_volume_name:/var/lib/mysql --name your_container_name your_image_name
