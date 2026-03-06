# VLaaS — Exam Mode Guide

## Overview

VLaaS has been used successfully to conduct **proctored practical examinations** for MSoIS programs (e.g., November 2019 batch). This guide covers how to set up and manage the platform specifically for examination sessions.

---

## Pre-Exam Checklist

- [ ] OpenStack VMs are provisioned and running
- [ ] Docker is installed on all host VMs
- [ ] Lab container images are pre-pulled on hosts (`docker pull <image>`)
- [ ] NGINX reverse proxy is configured (optional but recommended)
- [ ] Student URL sheet is prepared (student name → access URL)
- [ ] Test access from a thin client / browser before the exam

---

## Step 1 — Pre-pull Docker Images

To avoid delays during the exam, pull images in advance:

```bash
sudo docker pull jiteshsojitra/docker-ubuntu-xfce-container
sudo docker pull sreedocker123/docker-eclipse-novnc
sudo docker pull rocker/verse
sudo docker pull jupyter/scipy-notebook:83ed2c63671f
sudo docker pull mltooling/ml-workspace-gpu:0.13.2
```

---

## Step 2 — Provision Student Containers

### Option A — Batch provision (ML GPU workspaces)

1. Create a `students.txt` file with one username per line:
   ```
   student01
   student02
   student03
   ```

2. Run the batch provisioner:
   ```bash
   bash scripts/provision-users.sh students.txt 7001
   ```
   This launches one container per student, starting at port 7001.

### Option B — Single shared container (general labs)

For labs where all students use the same environment (e.g., Eclipse, Jupyter):

```bash
bash scripts/launch-container.sh eclipse
```

Students access the same container URL. Suitable when each student saves work locally.

---

## Step 3 — Distribute Access URLs

Generate and share the URL sheet:

```bash
bash scripts/healthcheck.sh
```

Example URL sheet:

| Student | URL | Username | Password |
|---------|-----|----------|----------|
| Alice   | http://172.16.51.79:7001 | alice | alice@123 |
| Bob     | http://172.16.51.79:7002 | bob | bob@123 |
| ...     | ... | ... | ... |

---

## Step 4 — During the Exam

- Students open the URL on **any browser** (Chrome recommended)
- For noVNC containers: append `/vnc.html` to the URL
- Thin clients with only a browser can access the full desktop environment
- Admin can monitor via: `sudo docker stats`

### Enable Basic Auth (optional, for added security)

```bash
# Create password file
sudo htpasswd -c /etc/nginx/.htpasswd student01

# Uncomment auth_basic lines in nginx/vlab-proxy.conf
# Reload NGINX
sudo nginx -s reload
```

---

## Step 5 — Post-Exam Cleanup

Stop and remove all containers after the exam:

```bash
bash scripts/stop-all-containers.sh
```

Or force without confirmation:

```bash
bash scripts/stop-all-containers.sh --force
```

---

## Exam Infrastructure — Real Usage (MSoIS, Nov 2019)

- **Duration:** November 23–28, 2019 (5 days)
- **Setup:** Multiple VMs on private OpenStack cloud
- **Environments used:** Eclipse IDE, RStudio, Jupyter Notebook, SQLite
- **Access:** Students used thin clients with browser-only access
- **Outcome:** Successful end-to-end practical examination with zero local software installation

---

## Tips & Best Practices

1. **Test 24 hours before** — spin up containers and access from the actual exam room
2. **Pre-pull images** — pulling during the exam causes delays
3. **One container per student** — avoids interference between students
4. **Monitor resource usage** — use `docker stats` to spot overloaded VMs
5. **Keep a backup VM ready** — if a host VM fails, quickly migrate containers
6. **Record access URLs** — keep a spreadsheet with student → URL mapping
