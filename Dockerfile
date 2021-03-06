FROM resin/armv7hf-debian:jessie
MAINTAINER http://sitch.io

ENV FEED_RADIO_TARGETS="GSM"

RUN apt-get update && apt-get install -y --no-install-recommends \
    expect \
    git=1:2.1.4-2.1+deb8u3 \
    logrotate=3.8.7-1+b1 \
    gcc=4:4.9.2-2 \
    gpsd=3.11-3 \
    gpsd-clients=3.11-3 \
    kmod=18-3 \
    lshw=02.17-1.1 \
    libfftw3-double3=3.3.4-2 \
    librtlsdr0=0.5.3-3 \
    libc6=2.19-18+deb8u10 \
    libudev1=215-17+deb8u7 \
    python-pip \
    python-dev \
    tcl && \
    apt-get clean && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Place Kalibrate
COPY binaries/kal-linux-arm /usr/local/bin/

# Place Filebeat
COPY binaries/filebeat-linux-arm /usr/local/bin
ADD https://raw.githubusercontent.com/elastic/beats/master/LICENSE /filebeat-lic

# Get Kalibrate source for posterity
ADD https://github.com/hainn8x/kalibrate-rtl/archive/master.zip /app/source


# Place the Logstash init script
# COPY init/logstash-forwarder /etc/init.d/

# Place config templates
RUN mkdir -p /etc/templates
COPY configs/filebeat.json /etc/templates

# Get the scripts in place
COPY sitch/ /app/sitch

COPY requirements.txt /requirements.txt

WORKDIR /app/sitch

RUN pip install virtualenv==15.1.0 && \
    virtualenv venv && \
    . ./venv/bin/activate && \
    pip install -r /requirements.txt

CMD /app/sitch/venv/bin/python ./runner.py 2>&1
