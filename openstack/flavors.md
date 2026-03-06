# Recommended OpenStack Flavors for VLaaS

## General Lab VMs (noVNC / Desktop Environments)

| Flavor     | vCPUs | RAM    | Disk   | Max Concurrent Containers |
|------------|-------|--------|--------|--------------------------|
| m1.medium  | 2     | 4 GB   | 40 GB  | 2–3                      |
| m1.large   | 4     | 8 GB   | 80 GB  | 4–6                      |
| m1.xlarge  | 8     | 16 GB  | 100 GB | 8–12                     |
| m1.xxlarge | 16    | 32 GB  | 200 GB | 15–25                    |

## GPU / ML Workspace VMs

| Flavor       | vCPUs | RAM   | GPU          | Notes                     |
|--------------|-------|-------|--------------|---------------------------|
| gpu.small    | 4     | 16 GB | 1× NVIDIA    | 1–2 ML workspace users    |
| gpu.large    | 8     | 32 GB | 1× NVIDIA    | 4–6 ML workspace users    |
| gpu.mig      | 8     | 32 GB | NVIDIA MIG   | 7+ isolated GPU slices    |

## Exam Mode Recommendations

- **Per student:** 1 vCPU, 1–2 GB RAM is typically sufficient for IDE/DB labs
- **Shared host VM:** 1 container per student; 30 students → `m1.xxlarge` or two `m1.xlarge` VMs
- Use **CPU pinning** in Nova for consistent performance during exams

## Notes

- VNC/noVNC containers are lightweight; most desktop environments use ~200–500 MB RAM idle
- Jupyter and RStudio can spike to 1–2 GB per user under load
- ML GPU workspaces require a minimum of 4 GB RAM per user
