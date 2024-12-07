FROM mysql

# Set the environment variables
ENV MYSQL_ROOT_PASSWORD=test123++
ENV MYSQL_DATABASE=businessdb
ENV MYSQL_USER=test
ENV MYSQL_PASSWORD=test123++


# Copy the script that will be executed on container startup
COPY script.sql /docker-entrypoint-initdb.d/



