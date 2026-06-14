# prism

Prism is an ultra-fast API gateway.

## Deployment

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate credentials
- An SSH key pair (public key path required as a Terraform variable)

### AWS Deployment

All Terraform configuration lives in `deployments/aws/`.

**1. Navigate to the deployment directory**

```bash
cd deployments/aws
```

**2. Initialize Terraform**

```bash
terraform init
```

**3. Plan the deployment**

```bash
terraform plan \
  -var="public_key=~/.ssh/id_rsa.pub" \
  -var="aws_region=us-east-1"
```

**4. Apply the deployment**

```bash
terraform apply \
  -var="public_key=~/.ssh/id_rsa.pub" \
  -var="aws_region=us-east-1"
```

**5. Destroy the deployment**

```bash
terraform destroy \
  -var="public_key=~/.ssh/id_rsa.pub" \
  -var="aws_region=us-east-1"
```

#### Key Variables

| Variable | Description | Default |
|---|---|---|
| `aws_region` | AWS region for all resources | `us-east-1` |
| `name_prefix` | Prefix used for naming resources | `prism` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `public_key` | Path to SSH public key file | _(required)_ |
| `allowed_ssh_cidr` | CIDR allowed to SSH into the instance | `0.0.0.0/0` |
| `vpc_cidr` | CIDR block for the VPC | `10.10.0.0/16` |
| `public_subnet_cidr` | CIDR block for the public subnet | `10.10.1.0/24` |
| `private_subnet_cidrs` | CIDR blocks for the three private subnets | `["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]` |

## Remote Connection

Private instances have no public IP and are reachable only by jumping through the public bastion host.
The recommended method is **SSH agent forwarding with a jump host (`-J`)**, which lets you connect
to a private node in a single command without copying your private key onto the bastion.

### How it works

```
Your machine  ──SSH──▶  Bastion (public IP)  ──SSH──▶  Private node (private IP)
```

1. `-A` forwards your local SSH agent to the bastion so the private key is available for the second hop.
2. `-i "~/.ssh/ec2-key"` selects the key pair used for both the bastion and the private node.
3. `-J ec2-user@<bastion-public-ip>` instructs SSH to proxy through the bastion before opening the final connection.

### Connect to a private instance

```bash
ssh -A -i "~/.ssh/ec2-key" -J ec2-user@<public-instance-ip> ec2-user@<private-instance-ip>
```

| Part | Meaning |
|---|---|
| `-A` | Enable SSH agent forwarding |
| `-i "~/.ssh/ec2-key"` | Private key used to authenticate on both hops |
| `-J ec2-user@3.88.219.121` | Jump (proxy) through the bastion at public IP `3.88.219.121` |
| `ec2-user@10.10.13.222` | Target private instance at `10.10.13.222` |

> **Note:** Replace `3.88.219.121` with the bastion public IP shown in the `public_instance_ip` Terraform output,
> and `10.10.13.222` with the relevant private IP from the `private_instance_ips` output.
