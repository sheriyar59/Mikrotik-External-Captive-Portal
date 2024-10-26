# MikroTik External Captive Portal with RADIUS Authentication

This project demonstrates setting up a MikroTik Hotspot with FreeRADIUS authentication on an Ubuntu server. The MikroTik router authenticates users through FreeRADIUS, with the Hotspot network on a separate subnet and IP masquerading enabled for outbound traffic.

# Table of Contents

- [Overview](#overview)
- [Network Setup](#network-setup)
- [Requirements](#requirements)
- [Installation and Configuration](#installation-and-configuration)
  - [FreeRADIUS Configuration on Ubuntu](#freeradius-configuration-on-ubuntu)
  - [MikroTik Configuration](#mikrotik-configuration)
- [External Captive Portal Setup](#external-captive-portal-setup)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
---

## Overview
This setup includes:
- A FreeRADIUS server on Ubuntu for authenticating users on a MikroTik Hotspot.
- The Hotspot network (`192.168.2.0/24`) configured on MikroTik’s ether2, while the FreeRADIUS server resides on the 192.168.18.0/24 subnet, connected to ether1.

## Network Setup

| Device          | IP Address       | Role                    |
|-----------------|------------------|-------------------------|
| MikroTik Router | 192.168.2.1      | Hotspot Gateway         |
| FreeRADIUS      | 192.168.18.30    | RADIUS Authentication   |
| Hotspot Network | 192.168.2.0/24   | Guest Network           |
| Home Network    | 192.168.18.0/24  | Main Network with NAS   |

## Requirements
- **Ubuntu Server** running FreeRADIUS (configured at `192.168.18.30`)
- **MikroTik Router** with Hotspot enabled on the `192.168.2.0/24` subnet
- **phpMyAdmin** (optional, for managing RADIUS users in MySQL)

## Installation and Configuration

### FreeRADIUS Configuration on Ubuntu

1. **Install FreeRADIUS**:
   ```bash
   sudo apt update
   sudo apt install freeradius freeradius-mysql

2. **Configure Clients**:

- Open the FreeRADIUS clients configuration file:
   ```bash
  sudo nano /etc/freeradius/3.0/clients.conf
- Add the MikroTik router as a client
   ```bash
   client mikrotik-hotspot {
    ipaddr = 192.168.2.1
    secret = testing123
    shortname = mikrotik-hotspot
    require_message_authenticator = yes
   }
      
3. **Add Test Users (optional)**:
- Open the users file to add test users for local authentication:
```bash
sudo nano /etc/freeradius/3.0/users
```
- Add entries like the following:
```bash
testuser Cleartext-Password := "testuser"
```
4. **Restart FreeRADIUS:**
```bash
sudo systemctl restart freeradius
```
## MikroTik Configuration
1. **Add FreeRADIUS Server in MikroTik**:
- Go to ****Radius > Add New****:
- Service: ```hotspot```
- Address: ```192.168.18.130```
- Secret: testing123 (matches FreeRADIUS configuration)
- Authentication Port: 1812
- Accounting Port: 1813 (optional if accounting is enabled)
2. **Enable Hotspot RADIUS Authentication:** 
- Go to ****IP > Hotspot > Server Profiles >**** Edit your Hotspot profile.
- Enable ****Use RADIUS for Authentication (and Accounting if enabled).****
  
 3.**Enable Masquerading for Hotspot Network:**
- Go to ****IP > Firewall > NAT.****
- Add a rule:
- Src Address ```192.168.2.0/24```
- Chain: ```srcnat```
- Action: ```masquerade```

## External Captive Portal Setup
***Portal Setup Using Git***
1. ****Clone the Repository:****
- On the FreeRADIUS server (at 192.168.18.130), navigate to the web server’s root directory and clone the repository:
```bash
cd /var/www
git clone https://github.com/splash-networks/mikrotik-yt-radius-portal
mv mikrotik-yt-radius-portal portal
cd /var/www/portal
```
2. ****Configure Environment Variables:****
- Copy the .env.example file to .env and set the required environment variables:
  ```bash
  cp .env.example .env
  nano .env

3. ****Install Dependencies:****
   - Navigate to the public folder and install dependencies using Composer
   ```bash
    cd /var/www/hotspot/public
    php composer.phar install
***Apache Host***
1. ****Set Up Apache Host:****
   - Configure the Apache host (virtual if many) using the server’s IP ```(192.168.18.130)```. In the Apache configuration file, specify the DocumentRoot:
     ```bash
     DocumentRoot /var/www/hotspot/public
 ***Mikrotik Hotspot Login File***
1.****Edit the Login Page:****
- Modify ```login.html``` in the ```public``` folder to include your server IP (e.g., ```192.168.18.130```) in the action field.
- Upload this file to the MikroTik router under Files > Hotspot.
 2.****Update alogin.html (Optional):***
- Replace ```alogin.html``` on the MikroTik router to suppress the "You are logged in" message during hotspot login.
## Testing
1.****Connect to the Hotspot**** on a device and attempt to log in with the RADIUS credentials you configured.
2.****Monitor FreeRADIUS Logs*** on Ubuntu to ensure successful authentication:
```bash
sudo tail -f /var/log/freeradius/radius.log
```
## Troubleshooting
  - ****No Response from RADIUS Server:****
  - Ensure the firewall on Ubuntu allows UDP traffic on ports 1812 and 1813:
```bash
sudo ufw allow proto udp from 192.168.2.0/24 to any port 1812,1813

