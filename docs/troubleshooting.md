# VLaaS — Troubleshooting Guide

## Container Won't Start

```bash
# Check Docker logs
sudo docker logs <container-name>

# Check if port is already in use
sudo ss -tlnp | grep <port>

# Remove conflicting container
sudo docker rm -f <container-name>
```

---

## noVNC Page Loads But Screen is Black

- Wait 10–15 seconds after container start; the desktop takes time to initialize
- Try refreshing the browser
- Check VNC password: default is `soisvnc@123`
- Check container logs: `sudo docker logs <container-name>`

---

## Cannot Access URL from Browser

1. Check the container is running: `sudo docker ps`
2. Verify port is listening: `sudo ss -tlnp | grep <port>`
3. Check OpenStack security group allows the port
4. Check VM firewall: `sudo ufw status` — disable or allow the port

```bash
sudo ufw allow <port>/tcp
```

---

## ML GPU Container Fails (NVIDIA runtime error)

```bash
# Check NVIDIA driver
nvidia-smi

# Check Docker NVIDIA runtime
sudo docker run --rm --runtime nvidia nvidia/cuda:11.0-base nvidia-smi

# If nvidia-container-runtime is missing:
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

---

## Out of Memory / Container Killed

- Check available RAM: `free -h`
- Check which containers are using most memory: `sudo docker stats --no-stream`
- Add memory limit to container: `-m 2g --memory-swap 2g`
- Stop unused containers: `sudo docker stop <name>`

---

## Students Can't See Their Previous Work

Workspace persistence requires a volume mount (`-v`). Without a volume, all data is lost when the container stops. Use:

```bash
-v /home/<student>/workspace:/workspace
```

Or for Jupyter:
```bash
-v /home/<student>/data:/home/jovyan/Data
```

---

## RStudio Login Fails

- Username: `rstudio`
- Password: value of `PASSWORD` env var (default: `soisrstudio@123`)

---

## Jupyter Token Not Working

- Token is set via `JUPYTER_TOKEN` env var (default: `msois@123`)
- Access URL format: `http://<ip>:<port>/?token=msois@123`

---

## NGINX Proxy Showing 502 Bad Gateway

- The container backend is not running or not ready yet
- Check: `sudo docker ps` and `sudo curl -v http://localhost:<port>`
- Check NGINX logs: `sudo tail -f /var/log/nginx/error.log`

---

## General Debugging Commands

```bash
# List all containers (running and stopped)
sudo docker ps -a

# Follow container logs
sudo docker logs -f <container-name>

# Inspect container config
sudo docker inspect <container-name>

# Execute shell inside container
sudo docker exec -it <container-name> bash

# Check host resource usage
htop
df -h
free -h
```
