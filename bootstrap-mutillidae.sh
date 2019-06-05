#! /bin/sh

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

WWW_ROOT=/var/www/localhost/htdocs/
GITCOMMIT=master
MUTILLIDAE_ZIP=https://github.com/webpwnized/mutillidae/archive/${GITCOMMIT}.zip

MUTILLIDAE_DIR=mutillidae-${GITCOMMIT}

function download {
    echo "Initilising www root with new Mutillidae"
    echo " * Downloading from GitHub (${MUTILLIDAE_ZIP})"

    cd ${WWW_ROOT}
    rm -f index.html
    wget -O - ${MUTILLIDAE_ZIP} | unzip -

    if test ! -d ${MUTILLIDAE_DIR} ; then
        return 1
    fi
    sed -i -E \
        -e 's/^Allow from \d+\.\d+\.\d+\.\d+\/\d+/### Do not edit line, please set ALLOW_SUBNET\n&\n### End do not edit/' \
        ${MUTILLIDAE_DIR}/.htaccess
    sed -i -E \
        -e "s|(DB_HOST', ')[^']+|\1localhost|" \
        -e "s|(DB_PASSWORD', ')[^']+|\1|" \
        ${MUTILLIDAE_DIR}/includes/database-config.inc
    cat - > index.html <<EOF
<html>
 <head>
  <title>Mutillidae Redirect</title>
 </head>
 <body>
  <script>
   window.location.replace('mutillidae-${GITCOMMIT}/')
  </script>
 </body>
</html>
EOF
}

if ! (test -d ${WWW_ROOT}/${MUTILLIDAE_DIR} || download) ; then
   echo "ERROR: Unable to bootstrap Mutillidae"
   exit 1
fi

# start services

echo Starting httpd/mysqld

cat - <<EOF | sed -i -E -f - ${WWW_ROOT}/${MUTILLIDAE_DIR}/.htaccess
/^### Do not edit line, please set ALLOW_SUBNET/bX
b
:X
p
aAllow from ${ALLOW_SUBNET}
:Y
N
/\n### End do not edit/c### End do not edit
bY
EOF

sed -i -E \
    -e '/^Allow from.*### sed tag/bX ; b ; :X' \
    -e "s|m[^#]*#|m ${ALLOW_SUBNET} #|" \

if ! (httpd && \
          mysqld_safe --datadir='/var/lib/mysql' --nowatch) ; then
    echo "ERROR: Failed to start required services"
    exit 1
fi

echo "Mutillidae bootstrapping done!"
echo " * Please access it on port 80."
echo " * SQL logs are at: /var/lib/mysql"
echo " * Apache logs are at: /var/log/apache2"
echo

cd /
if test -n "$*" ; then
    echo "Executing passed in command."
    exec "$@"
else
    echo "No command passed as arguments so dropping to shell."
    exec /bin/sh
fi
