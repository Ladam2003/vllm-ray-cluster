
This repository provides a fully automated setup for deploying a **GPU accelerated LLM (vLLM) cluster** using **Terraform** for infrastructure provisioning and **Ansible** for software deployment. Supports **OpenStack, AWS, Azure, GCP, or on-premises Linux nodes**.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)  
2. [Components](#components)  
3. [Terraform Infrastructure](#terraform-infrastructure)  
4. [Ansible Playbooks](#ansible-playbooks)  
5. [Model Deployment & Running](#model-deployment--running)  
6. [SSH & Networking](#ssh--networking)  
7. [Customizable Parameters](#customizable-parameters)  
8. [Typical Workflow](#typical-workflow)  
9. [Testing API](#testing-api)  
10. [Notes & Best Practices](#notes--best-practices)  

---

## Architecture Overview

- **Bastion Node**: Publicly accessible node; runs the **Ray head** and vLLM API server.  
- **Worker Nodes**: Private/internal network nodes; join the Ray cluster and handle distributed GPU workloads.  
- **Private Network**: For inter node communication (Ray backend, model sharing).  
- **Public Network**: Only Bastion is exposed; workers are private.  
- **Dockerized Deployment**: All dependencies and runtime run inside Docker containers.  
- **HuggingFace Hub Integration**: Models are downloaded securely using a HuggingFace token.

**Cluster Communication:**

- Ray Head listens on Bastion’s private/public IP.  
- Workers connect to Ray Head via private IP.  
- Tensor parallelism is configured based on the number of GPUs (1 per worker + head node).  

---

## Components

### Terraform (`*.tf` files)

| File | Purpose |
|------|---------|
| `instances.tf` | Creates Bastion & Worker VMs |
| `inventory.tf` | Generates Ansible inventory dynamically |
| `network.tf` | Retrieves private/external networks |
| `provider.tf` | Configures cloud providers |
| `security.tf` | Creates security groups & firewall rules |
| `ssh_config.tf` | Generates SSH config for Bastion & Workers |
| `variables.tf` | All user customizable variables |
| `outputs.tf` | Outputs Bastion & Worker IPs |

### Ansible (`playbooks/*.yml`)

| Playbook | Purpose |
|----------|---------|
| `1_setup_environment.yml` | Install Docker, NVIDIA drivers, Python, pipx, Git LFS, HuggingFace CLI |
| `2_build_vllm_image.yml` | Build `vllm-node:latest` Docker image with PyTorch, vLLM, Ray |
| `3_start_ray_cluster.yml` | Start Ray head on Bastion, workers on worker nodes |
| `4_run_model.yml` | Download model from HuggingFace and run vLLM API server |
| `5_stop_model.yml` | Stop vLLM API server gracefully |

---

## Terraform Infrastructure

- **Bastion Node**: Public IP, runs Ray head, jump host for SSH  
- **Worker Nodes**: Private IP, join Ray cluster, provide GPU resources  
- **Security**: `allowed_cidr` for internal network, `allowed_ports` for public Bastion ports  
- **SSH**: Bastion accessible via keypair; workers via ProxyJump  

---

## Ansible Playbooks

### Environment Setup (`1_setup_environment.yml`)

- Installs Docker, NVIDIA Docker runtime, CUDA drivers  
- Installs Python3, pipx, Git LFS  
- Configures HuggingFace CLI  
- Creates `/models/models` and `/models/hf-cache`

### Docker Image Build (`2_build_vllm_image.yml`)

- Builds `vllm-node:latest` Docker image with PyTorch, vLLM, Ray, Transformers, FastAPI, Uvicorn  
- Stateless image; model data mounted at `/models`

### Ray Cluster Start (`3_start_ray_cluster.yml`)

- Starts **Ray head** container on Bastion  
- Starts **Ray worker** containers on worker nodes  
- Uses host networking and GPU passthrough (`--gpus all`)  
- Tensor parallelism calculated from worker count

### Model Deployment (`4_run_model.yml`)

- Downloads model from HuggingFace to `/models/models/<model_name>`  
- Runs vLLM API server in Docker on Bastion:  
  - `tensor_parallel_size`, `gpu_memory_utilization`, `max_num_seqs`, `max_model_len` configurable  
- Logs to `/var/log/vllm.log` inside container  
- Validates process is running

### Stop Model (`5_stop_model.yml`)

- Stops running vLLM API server gracefully  
- Confirms process termination  

---

## Customizable Parameters

### Terraform Variables

| Variable | Default | Description |
|----------|---------|------------|
| `cloud_provider` | `openstack` | Choose: `openstack`, `aws`, `azure`, `gcp`, `onprem` |
| `project_prefix` | `myproject` | Prefix for resource names |
| `user_name` | `user` | Username for resource naming |
| `worker_count` | `1` | Number of worker nodes |
| `image_name` | `""` | VM image to use |
| `flavor_name` | `""` | VM type/flavor |
| `volume_size` | `50` | Root volume size (GB) |
| `private_network` | `""` | Private network name/ID |
| `external_network` | `""` | Public network name/ID |
| `allowed_cidr` | `192.168.0.0/24` | Internal traffic CIDR |
| `allowed_ports` | `[22,8000]` | Public ports to open |
| `keypair_name` | `default_sshkey` | SSH keypair name |

### Ansible Variables

| Variable | Default | Description |
|----------|---------|------------|
| `hf_token` | `YOUR_HUGGINGFACE_TOKEN` | HuggingFace API token |
| `cuda_version` | `12.1` | CUDA version in Docker container |
| `docker_version` | `latest` | Docker version |
| `model_id` | `huggingface-model/repo` | Model to download from HuggingFace |
| `tensor_parallel` | number of nodes + 1 | Tensor parallelism size |
| `api_port` | `8000` | vLLM API port on Bastion |

---

## Typical Workflow

### Infrastructure (Terraform)
| Step | Command |
| :--- | :--- |
| **Initialize** | `terraform init` |
| **Plan** | `terraform plan` |
| **Apply** | `terraform apply` |

### Deployment (Ansible)
1. Setup environment (Docker, Drivers, etc.)
ansible-playbook -i inventory.ini playbooks/1_setup_environment.yml

2. Build vLLM Docker image
ansible-playbook -i inventory.ini playbooks/2_build_vllm_image.yml

3. Start Ray cluster (Head & Workers)
ansible-playbook -i inventory.ini playbooks/3_start_ray_cluster.yml

4. Run model and API server
ansible-playbook -i inventory.ini playbooks/4_run_model.yml -e model_id="MODEL_NAME"

5. Stop model gracefully
ansible-playbook -i inventory.ini playbooks/5_stop_model.yml

### Testing API
curl -X POST "http://BASTION_IP:8000/v1/chat/completions" \
-H "Content-Type: application/json" \
-d '{
      "model": "MODEL_NAME",
      "messages":[{"role":"user","content":"Hello, test question"}]
    }' 

  
- BASTION_IP: Public IP of Bastion node
- MODEL_NAME: Model used in Ansible variable`

### Notes & Best Practices
 - GPU Requirements: At least 1 GPU per worker; higher-end recommended
 - Tensor Parallelism: Increase for multiple nodes
 - Private vs Public IPs: Bastion is public; workers are private
 - SSH: Access workers only via Bastion (ProxyJump)
 - Model Storage: /models/models for models, /models/hf-cache for cache
 - On-Premises: Set cloud_provider = "onprem" and manually provide host IPs
 - Logging: /var/log/vllm.log inside container 

