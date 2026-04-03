FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
RUN mkdir -p /opt/mssql-tools/bin \
    && if [ -x /opt/mssql-tools18/bin/sqlcmd ]; then ln -sf /opt/mssql-tools18/bin/sqlcmd /opt/mssql-tools/bin/sqlcmd; fi

COPY init.sql /init.sql
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER mssql
ENTRYPOINT ["/entrypoint.sh"]

