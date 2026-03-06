# VLaaS — GPU Setup Guide (NVIDIA / MIG)

## Prerequisites

- NVIDIA GPU installed on the OpenStack host VM (via PCI passthrough or bare metal)
- Ubuntu 20.04 / 22.04

---

## 1. Install NVIDIA Driver

```bash
sudo apt-get update
sudo apt-get install -y ubuntu-drivers-common
sudo ubuntu-drivers autoinstall
sudo reboot
```

Verify:
```bash
nvidia-smi
```

---

## 2. Install NVIDIA Container Toolkit

```bash
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

Verify:
```bash
sudo docker run --rm --runtime nvidia nvidia/cuda:11.0-base nvidia-smi
```

---

## 3. NVIDIA MIG (Multi-Instance GPU)

MIG allows a single GPU to be partitioned into multiple isolated slices — ideal for giving each student a dedicated GPU slice.

### Enable MIG mode

```bash
sudo nvidia-smi -mig 1
sudo reboot
```

### List available MIG profiles

```bash
sudo nvidia-smi mig -lgip
```

### Create MIG instances (example: 7× 1g.10gb slices on A100)

```bash
sudo nvidia-smi mig -cgi 1g.10gb -C
sudo nvidia-smi mig -lgi   # list instances
```

### Get MIG device UUID for a container

```bash
nvidia-smi -L
# Example output:
# MIG-GPU-abc123.../0/0   UUID: MIG-32df5096-2c2e-5d5f-a97c-cf45e7f8272b
```

### Launch container with specific MIG slice

```bash
sudo docker run -d -p 7001:8080 \
  --runtime nvidia \
  --env NVIDIA_VISIBLE_DEVICES="MIG-32df5096-2c2e-5d5f-a97c-cf45e7f8272b" \
  -v "/home/student1/workspace:/workspace" \
  --env WORKSPACE_AUTH_USER=student1 \
  --env WORKSPACE_AUTH_PASSWORD=student1@123 \
  --env VNC_PW=student1@123 \
  mltooling/ml-workspace-gpu:0.13.2
```

---

## 4. Batch MIG Provisioning

The `provision-users.sh` script handles multi-user GPU provisioning when `NVIDIA_VISIBLE_DEVICES=all`. For MIG-specific assignments, modify the script to assign individual MIG UUIDs per student.

---

## Notes

- MIG is supported on NVIDIA A100, A30, H100 GPUs
- For older GPUs (GTX/RTX consumer series), use `NVIDIA_VISIBLE_DEVICES=all` with resource limits
- Monitor GPU usage: `nvidia-smi dmon` or `watch -n1 nvidia-smi`
