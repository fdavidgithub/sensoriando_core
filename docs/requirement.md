# Sensoriando
**Requirement**

Homologated
* Ubuntu 18.04

```console
sudo apt-get update
sudo apt-get upgrade
```

### Database
```console
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
sudo apt-get update
sudo apt-get install postgresql-13 libpq-dev
sudo vi /etc/postgres/13/main/pg_hba.conf
```

after: local	all	postgres	peer
before: local	all	postgres	trust

```console
sudo systemctl restart postgresql
```

### Broker MQTT
```console
sudo apt-get install mosquitto mosquitto-clients
```

### NTP
```console
sudo apt-get install ntp
sudo timedatectl set-timezone America/Sao_Paulo
sudo apt-get install ntpdate
service ntp stop
sudo service ntp stop
sudo ntpdate a.ntp.br
sudo service ntp start
```
### Management
```console
sudo apt-get install supervisor
sudo echo_supervisord_conf > /tmp/supervisord.conf
sudo cp /tmp/supervisord.conf /etc/supervisor/supervisord.conf
```

### Development
```console
sudo apt-get install build-essential gcc make cmake cmake-gui cmake-curses-gui
sudo apt-get install libssl-dev 
sudo apt-get install doxygen

git clone https://github.com/eclipse/paho.mqtt.c.git
cd paho.mqtt.c
make
make html
sudo make install
```

