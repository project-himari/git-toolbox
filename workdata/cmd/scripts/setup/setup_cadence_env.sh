#!/bin/bash

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Please run as root (e.g. sudo ./install_cadence_env.sh)"
    exit 1
fi


#=====================================#
#Install Xcelium Required Packages
#=====================================#
echo "[INFO] Updating package list..."
sudo apt update

echo "[INFO] Installing core utilities..."
sudo apt install -y autofs net-tools nfs-common ldap-utils mailutils ksh tigervnc-standalone-server tigervnc-viewer

echo "[INFO] Installing Perl modules..."
sudo apt install -y ksh libauthen-sasl-perl libnet-ldap-perl libconvert-asn1-perl libxml-sax-perl libxml-sax-base-perl \
libxml-namespacesupport-perl libxml-libxml-perl libxml-libxslt-perl libxml-parser-perl libxml-twig-perl \
libxml-xpath-perl libwww-perl libio-socket-ssl-perl libnet-libidn-perl libnet-ssleay-perl libxml-simple-perl \
libintl-perl

echo "[INFO] Installing BIND DNS tools..."
sudo apt install -y bind9 bind9utils bind9-doc
#=====================================#


echo "[INFO] Installing required packages..."

echo "[DONE] All dependencies installed successfully."
