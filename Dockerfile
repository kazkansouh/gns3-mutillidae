FROM alpine:3.9

# Copyright (C) 2019 Karim Kanso. All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Define subnet to that will have access to mutillidae (e.g. local network)
ENV ALLOW_SUBNET=172.17.0.0/16

# Expose port 80
EXPOSE 80

RUN apk add --no-cache \
                mariadb \
                php7-apache2 \
                php7-curl \
                php7-json \
                php7-mbstring \
                php7-mysqli \
                php7-mysqlnd \
                php7-session \
                php7-simplexml \
                php7-xml \
                php7-xmlwriter && \
        mysql_install_db --user=mysql --datadir=/var/lib/mysql

# patch apache AllowOverride directive from "none" to "all"
RUN { \
        echo '/^<Directory "\/var\/www\/localhost\/htdocs/bX' ; \
        echo 'b' ; \
        echo ':X' ; \
        echo 'N' ; \
        echo 's/\n( *AllowOverride )[^\n]*\n/\n\1All\n/' ; \
        echo '/\n<\/Directory>/b' ; \
        echo 'bX' ; \
        } | sed -E -f - -i /etc/apache2/httpd.conf

# Persist www location
VOLUME ["/var/www/localhost/htdocs/"]

# Persist database
VOLUME ["/var/lib/mysql/"]

COPY bootstrap-mutillidae.sh /

CMD ["/bootstrap-mutillidae.sh"]
