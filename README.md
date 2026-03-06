# 🧪 VLab-as-a-Service (VLaaS)

> **Browser-based Virtual Lab Platform** — Provision, access, and manage software environments for academic courses via Docker containers on OpenStack cloud infrastructure.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Docker](https://img.shields.io/badge/Docker-20.10%2B-blue?logo=docker)
![OpenStack](https://img.shields.io/badge/OpenStack-Yoga%2B-red?logo=openstack)
![Platform](https://img.shields.io/badge/Platform-Academic%20Labs%20%26%20Exams-green)

---

## 📖 Overview

**VLab-as-a-Service (VLaaS)** is an open-source platform that delivers browser-accessible software environments to students without requiring any local installation. Built on **Docker** containers provisioned on an **OpenStack** private cloud, it supports:

- 💻 **IDE & Development Tools** — Eclipse, VS Code, Android Studio
- 📊 **Data Science & AI/ML** — Jupyter Notebook, RStudio, ML Workspace (GPU)
- 🐧 **OS Environments** — Ubuntu (XFCE/LXQT), CentOS with GNOME
- 🗄️ **Database Tools** — SQLite, DB Browser for SQLite
- 📱 **Mobile Dev** — Android Emulator via Docker

Students access their lab environment through a **URL in any browser** (via noVNC / web-based VNC), making it ideal for:
- Regular practical lab sessions
- End-semester examinations (proctored)
- Remote/thin-client access scenarios

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Student Browser                           │
│                  http://<vm-ip>:<port>/vnc.html                  │
└────────────────────────────┬─────────────────────────────────────┘
                             │ HTTP / noVNC / WebSocket
┌────────────────────────────▼─────────────────────────────────────┐
│                        NGINX Reverse Proxy                       │
│              (optional auth via htpasswd / token)                │
└────────────────────────────┬─────────────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────────┐
│              OpenStack Private Cloud (Nova / Neutron)            │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────────────┐   │
│  │  VM / Host 1│  │  VM / Host 2│  │   GPU VM / Host 3      │   │
│  │  Docker     │  │  Docker     │  │   Docker + NVIDIA       │   │
│  │  ─────────  │  │  ─────────  │  │   ─────────────────    │   │
│  │  Container  │  │  Container  │  │   ML Workspace GPU      │   │
│  │  (noVNC)    │  │  (Jupyter)  │  │   (GPU passthrough)     │   │
│  └─────────────┘  └─────────────┘  └────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Role |
|---|---|
| **OpenStack** | Provision and manage virtual machines (Nova, Neutron, Cinder) |
| **Docker** | Container runtime on each VM; isolates student environments |
| **noVNC / VNC** | Browser-based desktop access (no client install needed) |
| **NGINX** | Reverse proxy with optional basic auth / routing |
| **Portal (optional)** | Web UI for admins to provision/manage containers |

---

## 🖼️ Supported Lab Environments

| Image | Use Case | Access | Default Password |
|---|---|---|---|
| `jiteshsojitra/docker-ubuntu-xfce-container` | Linux, Data Structures, SQLite | noVNC `:6901/vnc.html` | `soisvnc@123` |
| `accetto/ubuntu-vnc-xfce-g3` | Ubuntu 22.04 General Labs | VNC `:5901` / noVNC `:6901` | `soisvnc@123` |
| `sreedocker123/ubuntuvscodedotnet:latest` | Ubuntu + VS Code + .NET SDK 8.0 | VNC `:5901` / noVNC `:6901` | `soisvnc@123` |
| `sreedocker123/docker-eclipse-novnc` | Java / Eclipse IDE | noVNC `:6080` | `ubuntu@123` |
| `rocker/verse` | R Studio (Statistics / AIML) | Web UI `:8787` | `soisrstudio@123` |
| `jupyter/scipy-notebook` | Jupyter Notebook (AIML) | Web UI `:8888` | Token: `msois@123` |
| `mltooling/ml-workspace-gpu` | Full ML/AI GPU Workspace | Web UI `:8080` | Per-user |
| `budtmo/docker-android-x86-8.1` | Android Emulator | noVNC `:6080` | N/A |
| `consol/centos-xfce-vnc` | CentOS GNOME Environment | VNC `:5901` | Default |

---

## 🚀 Quick Start

### Prerequisites

- Ubuntu 20.04 / 22.04 VM provisioned on OpenStack
- Minimum: **8 GB RAM**, **4 vCPUs**, **50 GB disk**
- For GPU workloads: NVIDIA GPU with MIG or passthrough support
- Docker CE 20.10+

### 1. Install Docker on VM

```bash
bash scripts/install-docker.sh
```

### 2. Launch a Lab Container

```bash
# General Linux / Data Structures Lab
bash scripts/launch-container.sh linux

# Java / Eclipse Lab
bash scripts/launch-container.sh eclipse

# RStudio Lab
bash scripts/launch-container.sh rstudio

# Jupyter Notebook
bash scripts/launch-container.sh jupyter

# ML GPU Workspace
bash scripts/launch-container.sh mlgpu --user student1 --port 7001
```

### 3. Access via Browser

```
http://<openstack-vm-ip>:<port>/vnc.html
```

For RStudio / Jupyter:
```
http://<openstack-vm-ip>:<port>
```

---

## 📁 Repository Structure

```
vlab-as-a-service/
│
├── README.md                    # This file
│
├── scripts/                     # Shell scripts for provisioning
│   ├── install-docker.sh        # Install Docker CE on Ubuntu VM
│   ├── launch-container.sh      # Unified container launcher
│   ├── stop-all-containers.sh   # Stop and remove all containers
│   ├── provision-users.sh       # Batch-provision per-student containers
│   └── healthcheck.sh           # Check running containers & ports
│
├── containers/                  # Docker run configs per environment
│   ├── linux-lab.sh             # Ubuntu XFCE + SQLite
│   ├── vscode-dotnet.sh         # Ubuntu + VS Code + .NET
│   ├── eclipse-java.sh          # Eclipse IDE (Java)
│   ├── rstudio.sh               # RStudio / rocker
│   ├── jupyter.sh               # Jupyter Notebook
│   ├── ml-workspace-gpu.sh      # ML Workspace GPU (multi-user)
│   ├── android-emulator.sh      # Android Docker
│   └── centos-gnome.sh          # CentOS GNOME VNC
│
├── nginx/                       # NGINX reverse proxy configs
│   ├── nginx.conf               # Main NGINX config
│   ├── vlab-proxy.conf          # Virtual host / upstream config
│   └── setup-nginx.sh           # Script to install & configure NGINX
│
├── openstack/                   # OpenStack provisioning helpers
│   ├── create-vm.sh             # Launch a VM via OpenStack CLI
│   ├── openstack-rc.sh          # Sample OpenStack RC env vars
│   └── flavors.md               # Recommended VM flavors/specs
│
├── k8s/                         # Optional Kubernetes deployment
│   ├── deployment.yaml          # Example K8s deployment
│   ├── service.yaml             # NodePort / LoadBalancer service
│   └── README.md                # K8s setup notes
│
├── portal/                      # Admin web portal (optional)
│   ├── index.html               # Simple lab management UI
│   └── README.md
│
└── docs/                        # Additional documentation
    ├── architecture.md          # Detailed architecture notes
    ├── lab-environments.md      # Per-environment setup guide
    ├── exam-mode.md             # Using VLaaS for examinations
    ├── gpu-setup.md             # GPU / NVIDIA MIG configuration
    └── troubleshooting.md       # Common issues & fixes
```

---

## 📋 Exam Mode

VLaaS has been used successfully to conduct **proctored practical examinations** for MSoIS programs. Key features for exam use:

- Each student gets an **isolated container** with a unique URL
- Thin clients (even with only a browser) can access the full lab environment
- Admin can **stop all containers** post-exam with a single script
- Optional NGINX basic auth adds a layer of access control per student

See [`docs/exam-mode.md`](docs/exam-mode.md) for full setup instructions.

---

## 🖥️ Infrastructure

VLaaS was deployed and tested on a private OpenStack cloud with the following server specs:

- **CPU:** Intel Core i5-7400 (3.00GHz, 4 Cores)
- **RAM:** 32 GB DDR4
- **Storage:** 500 GB HDD
- **Ports:** 8× USB 3.1, 3× Video (VGA + 2× DP)
- **OS:** Ubuntu Server 20.04 / 22.04

Multiple servers run dedicated services (compute nodes, GPU node, storage).

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/new-lab-image`)
3. Commit your changes (`git commit -m 'Add: new lab environment for XYZ'`)
4. Push to the branch (`git push origin feature/new-lab-image`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🏫 Acknowledgements

Developed and deployed at **MSoIS, Manipal** for academic lab and examination use.  
Built on top of open-source Docker images from the community.

---

> **VLaaS** — *Any lab. Any device. Any browser.*
