## DevOps Task

Page available at https://fuel50.djameson.dev

In this repository you can find the terraform code for the task. At a high level it provisions a ALB with a certificate for fuel50.djameson.dev. The ALB redirects non secure web traffic (http) to https. The ALB forwards traffic to an EC2 instance running an nginx server that returns 'Hello World!'. The EC2 instance is set up to only accept ingress traffic from the ALB. 

If I had more time I would:

1. Run the web server on the EC2 instance in a container. This would improve security by providing additional isolation if the web server was exploited. Would run the container as non-root. 

2. Add a IDS/IPS to the base OS, e.g. Crowdstrike. 

3. Check firewall settings on Ubuntu server

Going forward I would rather use a CDN to host static content, as that removes a lot of the security risks involved in managing your own infrastructure.

## Security Questions

Endpoint protection (IDS/IPS etc..), Key or Cert only SSH, Firewall Rules, Ensure SELinux is installed/running, Agents for metrics and aggregated logging


Endpoint protection - Provides monitoring, alerting, response playbooks for any known exploits.

Key/Cert SSH - Never use passwords for SSH

Firewall Rules - Make sure only the ports that are in use are open

SELinux/AppArmor - Provides more control over what activities user/process/daemon can do.

Metrics/Aggregated logging - Provides more visibility, alerts can be set up 


GDPR Compliance, Ransomware, Data Breaches

### GDPR  

Fuel50 is a global company. If they do business in Europe they are subject to GDPR. It is a big risk because there are serious fines for breaching it, as well as reputational damage.

- Processes in place to delete individuals data
- Make sure data is only being stored in correct region
- Minimize personal data 
- Report data breaches on time

### Ransomware  

This is a big risk to any business for obvious reasons

- As much isolation as possible between infrastructure to mitigate spreading. 
- IDS/IPS systems to help prevent and alert you. 
- DR plan that is practiced frequently. 
- Isolation between backups and live environments. 

### Data Breaches 

Fuel50 will probably store a lot of sensitive data. There are legal, financial, and reputational consequences of a data breach. 

- Most of the Ransomware section applies as well. 
- Common causes are weak/stolen credentials. Set up 2FA and have good password policies.
- Employee education around common attack vectors e.g. phishing emails. 
- Regular employee testing, e.g. send fake phishing emails
- External pentesting 
