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
