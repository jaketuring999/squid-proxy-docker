# Use Alpine Linux as the base image for a lightweight container
FROM alpine:3.20.3

#  Set environment variables for Squid configuration
ENV SQUID_VERSION=6.11 \
    SQUID_USER=squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_CACHE_DIR=/var/cache/squid

# Install Squid and Bash
RUN apk update && \
    apk add --no-cache squid bash && \
    # Create necessary directories with appropriate permissions
    mkdir -p ${SQUID_LOG_DIR} ${SQUID_CACHE_DIR} /var/spool/squid && \
    chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR} ${SQUID_CACHE_DIR} /var/spool/squid && \
    # Initialize Squid cache directories
    squid -z && \
    # Clean up to reduce image size
    rm -rf /var/cache/apk/*

#  Copy configuration files into the container
COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

#  Ensure the entrypoint script is executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose Squid's default port
EXPOSE 31280

# Re-declare environment variables (optional but good practice)
ENV SQUID_LOG_DIR=/var/log/squid
ENV SQUID_CACHE_DIR=/var/cache/squid
ENV SQUID_USER=squid

# Define the entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["squid", "-N"]
