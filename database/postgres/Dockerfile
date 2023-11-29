FROM postgres:latest as postgres
COPY ./init.sql /docker-entrypoint-initdb.d/
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=123456
EXPOSE 5432
