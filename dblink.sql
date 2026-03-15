CREATE DATABASE LINK spinzone_dblink
CONNECT TO spinzon IDENTIFIED BY password
USING 'tns_service_name';

-- no tnsnames.ora file needed
CREATE DATABASE LINK <link_alias>
  CONNECT TO <remote_username>
  IDENTIFIED BY <remote_password>
  USING '(DESCRIPTION=
            (ADDRESS=
              (PROTOCOL=TCP)
              (HOST=<remote_host>)
              (PORT=<port>))
            (CONNECT_DATA=
              (SERVICE_NAME=<remote_service_name>)))';