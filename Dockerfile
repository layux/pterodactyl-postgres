# Use the official MariaDB latest image as the base
FROM postgres:latest

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Add a user for the container
RUN adduser --disabled-password --home /home/container container && \
    chown -R container:container /home/container

USER container
ENV  USER=container HOME=/home/container

# Set the working directory
WORKDIR /home/container

# Set the entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]