#!/usr/bin/env bash

# variables
HOME_PATH="/home/vagrant/Downloads"
INSTALLATION_PATH="/home/vagrant/Prometheus/server"
NODE_EXPORTER_PATH="/home/vagrant/Prometheus/node_exporter"
PROMETHEUS_VERSION="2.26.0"

# Update OS
sudo apt-get update -y

# Creating vagrant directory
mkdir $HOME_PATH && cd $HOME_PATH

# Download prometheus installation files
wget https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz

# Create directory for prometheus installation files
mkdir -p $INSTALLATION_PATH && cd $INSTALLATION_PATH

# Extract files
tar -xvzf /home/vagrant/Downloads/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz && cd prometheus-$PROMETHEUS_VERSION.linux-amd64

# Check prometheus version
./prometheus -version

# Create directory for node_exporter which can be used to send ubuntu metrics to the prometheus server
mkdir -p $NODE_EXPORTER_PATH && cd $NODE_EXPORTER_PATH

# Download node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.darwin-amd64.tar.gz -O /home/vagrant/Downloads/node_exporter-1.3.1.linux-amd64.tar.gz

# Extract node_exporter
tar -xvzf /home/vagrant/Downloads/node_exporter-1.3.1.linux-amd64.tar.gz

# Create a symbolic link of node_exporter
sudo ln -s $NODE_EXPORTER_PATH/node_exporter-1.3.1.linux-amd64/node_exporter /usr/bin

# Edit node_exporter configuration file and add configuration so that it will automatically start in next boot
cat <<EOF > /etc/init/node_exporter.conf
# Run node_exporter-1.3.1.linux-amd64
start on startup
script
   /usr/bin/node_exporter
end script
EOF

# Start service of node_exporter
sudo service node_exporter start

cd /home/vagrant/Prometheus/server/prometheus-$PROMETHEUS_VERSION.linux-amd64/

# Edit prometheus configuration file which will pull metrics from node_exporter
cat <<EOF > prometheus.yml
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.
  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'
# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'node-prometheus'
    static_configs:
      - targets: ['localhost:9100']
EOF

# start prometheus
nohup ./prometheus > prometheus.log 2>&1 &