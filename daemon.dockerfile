FROM gcc:latest

# Install Postgre Libs
RUN apt-get update
RUN apt-get install -y libpq-dev

# Install Paho MQTT
WORKDIR /app
RUN \
if [ ! -d "paho.mqtt.c" ]; then \ 
    git clone https://github.com/eclipse/paho.mqtt.c.git; \
fi

WORKDIR /app/paho.mqtt.c
RUN make

RUN make uninstall
RUN make install

# Compile
WORKDIR /app
COPY ./daemon/* /app
RUN make


