# VLaaS — Architecture

## High-Level Overview

```
Student Device (Browser)
        │
        │  HTTP / WebSocket / noVNC
        ▼
┌───────────────────┐
│   NGINX Proxy     │  ← Optional: auth, routing, SSL
└────────┬──────────┘
         │
         ▼
┌────────────────────────────────────────────────┐
│           OpenStack Private Cloud              │
│                                                │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  Compute VM 1 │  │  Compute VM 2 │  ...      │
│  │  (Ubuntu)    │  │  (Ubuntu)    │            │
│  │              │  │              │            │
│  │  Docker      │  │  Docker      │            │
│  │  ──────────  │  │  ──────────  │            │
│  │  [Container] │  │  [Container] │            │
│  │  [Container] │  │  [Container] │            │
│  └──────────────┘  └──────────────┘            │
│                                                │
│  ┌──────────────────────────┐                  │
│  │   GPU VM (NVIDIA)        │                  │
│  │   Docker + nvidia-runtime │                  │
│  │   [ML Workspace × N]     │                  │
│  └──────────────────────────┘                  │
│                                                │
│  ┌──────────────┐                              │
│  │  Storage VM  │                              │
│  │  (Cinder /   │                              │
│  │   NFS)       │                              │
│  └──────────────┘                              │
└────────────────────────────────────────────────┘
```

---

## Component Details

### 1. OpenStack Layer

- **Nova** — Virtual machine lifecycle (create, start, stop, delete)
- **Neutron** — Network management; each VM gets an IP on the lab network
- **Cinder** — Block storage volumes for persistent student workspaces
- **Keystone** — Authentication for OpenStack API access
- **Glance** — VM image registry (Ubuntu 20.04/22.04 base images)

### 2. Docker Layer (per VM)

- Docker CE 20.10+ installed on each OpenStack VM
- Each student gets one or more containers with an isolated environment
- Containers expose ports (VNC: 5901, noVNC: 6901/6080, Web: 8787/8888/8080)
- Container images are pre-pulled to avoid startup delays

### 3. Browser Access (noVNC / WebVNC)

| Access Method | Port | Protocol | Notes |
|---|---|---|---|
| noVNC (browser desktop) | 6901, 6080 | HTTP + WebSocket | No client needed |
| Raw VNC | 5901 | VNC | Requires VNC client |
| RStudio Web | 8787 | HTTP | Built-in web UI |
| Jupyter Web | 8888 | HTTP | Built-in web UI |
| ML Workspace | 8080 | HTTP | Full workspace UI |

### 4. NGINX Reverse Proxy (optional)

- Routes `/lab/<env>/` paths to the correct container port
- Supports WebSocket proxying (needed for noVNC)
- Can enforce HTTP Basic Auth for exam security
- Can terminate SSL (HTTPS) with Let's Encrypt or self-signed certs

---

## Network Topology

```
[Thin Client / Browser]
        ↕ HTTP
[NGINX on host VM or dedicated proxy VM]
        ↕ HTTP upstream (127.0.0.1:<port>)
[Docker containers on host VM]
        ↕ (internal)
[OpenStack Neutron network]
        ↕
[Storage VM — NFS / Cinder volumes]
```

---

## Scalability

| Scenario | Recommended Setup |
|---|---|
| 1–10 students | 1 VM, all containers on single host |
| 10–30 students | 2–3 VMs, distribute containers across hosts |
| 30–60 students | 4–6 VMs + load balancer (HAProxy / NGINX upstream) |
| 60+ students | Kubernetes cluster with pod-per-student |

For Kubernetes-based deployment, see [`k8s/README.md`](../k8s/README.md).
