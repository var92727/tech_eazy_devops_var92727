# TechEazy Assignment 1 - DevOps Lift & Shift

This repo contains automation for deploying the given Java app to AWS EC2.

## Steps to Run

1. Launch an EC2 (Ubuntu 22.04, t2.micro free-tier).
2. SSH into instance:
   ```bash
   ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
   ```
3. Clone this repo:
   ```bash
   git clone https://github.com/<your-username>/tech_eazy_devops_varunkumar.git
   cd tech_eazy_devops_varunkumar
   ```
4. Run deployment:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh Dev
   ```
5. App will be available at:
   ```
   http://<EC2-PUBLIC-IP>:80
   ```
6. Logs are stored in `app.log`.  
7. Instance will auto-shutdown after configured time (default: 1 hour in Dev).
