FROM postgres:15-alpine

ENV POSTGRES_DB=stockmaster
ENV POSTGRES_USER=stockmaster
ENV POSTGRES_PASSWORD=stockmaster123

COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
