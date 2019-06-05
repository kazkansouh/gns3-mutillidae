# GNS3 Mutillidae Downloader

[Alpine][alpine] based Docker image that downloads and runs
[Mutillidae][mutillidae] designed for use with [GNS3][gns3]. The image
does not contain Mutillidae (to save having to rebuild the image on
each new release), instead it contains the needed the dependencies
(i.e. Apache, PHP7, MariaDB) and a bootstrap script that downloads the
latest version of Mutillidae on first use.

## Usage

### To setup in GNS3

Download the [appliance][appliance-file] and import into GNS3. When
running, set the `ALLOW_SUBNET` environment variable (see below).

### Access Control
The image requires that the environment variable `ALLOW_SUBNET` is set
to a trusted subnet/ip address. This variable defines which computers
are allowed to connect to the Mutillidae instance. By default, it is
set to `172.17.0.0/16`, this aligns with the default Docker subnet.

### Persistence
Optionally, set the following path as a Docker volume when creating
the container: `/var/www/localhost/htdocs/`. The bootstrap script will
check this location on boot, if it does not contain a Mutillidae
instance, one will be downloaded into it.

Optionally, set the following path as a Docker volume when creating
the container: `/var/lib/mysql/`. This contains the MySQL database
used by Mutillidae, thus persisting this location will negate starting
Mutillidae clean every time. If this is persisted, the bootstrap
script will fail when starting mysql as the tables have not been
initialised. The tables can be initialised with the following commands:

```
mkdir /host/path/db
chown 100:101 /host/path/db
docker run -t -i --rm              \
  -v /host/path/db:/var/lib/mysql/ \
  karimkanso/gns3-mutillidae       \
  mysql_install_db --user=mysql --datadir=/var/lib/mysql
```

As this runs `mysql_install` under user *mysql* it is required to
`chown` the directory before mounting.

### Normal Startup

**Note:** Upon first use, when Mutillidae starts it will complain
about an empty database. Just follow through the setup/reset database
link.

To start the image manually, allow access to all machines on the
`10.0.0.0/8` network and persist both the Mutillidae installation
(static information) and database (dynamic information) issue the
following command:

```
docker run -t -i --rm                                 \
  -e ALLOW_SUBNET=10.0.0.0/8                          \
  -v /host/path/mutillidae:/var/www/localhost/htdocs/ \
  -v /host/path/db:/var/lib/mysql/                    \
  karimkanso/gns3-mutillidae
```

Once started, the container will drop to a shell prompt and Mutillidae
can be accessed on the container's port 80.

#### Command pass-through

The bootstrap script will pass-through any arguments it gets. Thus, if
needed its possible to issue the following command to have a live feed
of Apache logs.

```
docker run -t -i --rm                                 \
  -e ALLOW_SUBNET=10.0.0.0/8                          \
  -v /host/path/mutillidae:/var/www/localhost/htdocs/ \
  -v /host/path/db:/var/lib/mysql/                    \
  karimkanso/gns3-mutillidae                          \
  /bootstrap-mutillidae.sh tail -f /var/log/apache2/access.log
```

# Other bits

Copyright 2019 Karim Kanso


[alpine]: https://alpinelinux.org/ "Alpine Linux"
[mutillidae]: https://www.owasp.org/index.php/OWASP_Mutillidae_2_Project "owasp.org: OWASP Mutillidae 2 Project"
[gns3]: https://www.gns3.com/ "GNS3 | The software that empowers network professionals"
[appliance-file]: https://github.com/kazkansouh/gns3-mutillidae/blob/master/mutillidae.gns3a "GNS3 Appliance File"
