## Terraform Multi-Environment AWS EC2 Deployment

This project demonstrates how to manage multiple environments (dev, staging, prod) for an AWS EC2 instance using Terraform. The goal is to avoid code duplication by using a single Terraform configuration with **workspaces** and **dynamic resource configuration** using the `lookup` function. This approach ensures that each environment has its own isolated state file and dynamically selects configurations based on the workspace.


### Directory Structure

```
└── saiabhiramjaini-multi-environment-aws-ec2-with-terraform/
    ├── backend.tf
    ├── main.tf
    ├── provider.tf
    ├── variables.tf
    └── modules/
        ├── backend/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── ec2_instance/
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
```


### Scenario

You have a single Terraform configuration (`main.tf`) that defines an AWS EC2 instance. However, the instance type and other configurations differ across environments:

- **Dev**: Use `t2.micro` instances.
- **Staging**: Use `t2.medium` instances.
- **Prod**: Use `t2.xlarge` instances.

In this setup, there will be a **single `terraform.tfstate` file** shared across all environments.


### The Problem with a Single State File

Using a single state file across multiple environments can lead to significant issues:

1. **Conflicts and Overwrites**:  
   Changes made to one environment can unintentionally overwrite the infrastructure of another environment. For example, if you apply changes for the `dev` environment, it might overwrite the state of the `prod` environment, leading to unintended modifications or deletions.

2. **Inconsistencies**:  
   The state file will not accurately reflect the state of any specific environment. This can lead to deployment errors, resource mismanagement, and unpredictable behavior. For instance, if the state file is shared, Terraform might incorrectly assume the state of resources in one environment based on changes made in another.

3. **Lack of Isolation**:  
   Without isolation, debugging and troubleshooting become challenging. If something goes wrong in one environment, it becomes harder to identify the root cause because the state file is shared across all environments.

To avoid these issues, it's essential to use a dedicated state file for each environment.


### Solution: Terraform Workspaces

Terraform workspaces provide a built-in mechanism to manage multiple environments with separate state files while using a single Terraform configuration. Workspaces allow you to isolate the state of each environment, ensuring that changes in one environment do not affect another.

### Step 1: Define Map Variables

Define map variables in your `variables.tf` file to store environment-specific configurations:

```hcl
variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = map(string)
  default = {
    dev     = "t2.micro"
    staging = "t2.medium"
    prod    = "t2.xlarge"
  }
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = map(string)
  default = {
    dev     = "ami-0abcd1234efgh5678"  # Example AMI for dev
    staging = "ami-0efgh5678ijkl9012"  # Example AMI for staging
    prod    = "ami-0ijkl9012mnop3456"  # Example AMI for prod
  }
}
```

---

### Step 2: Use `lookup` in Your Configuration

In your `main.tf` file, use the `lookup` function to dynamically select the appropriate value from the map based on the current workspace:

```hcl
provider "aws" {
  region = "ap-south-1"
}

module "ec2_instance" {
  source = "./modules/ec2_instance"

  ami_value         = lookup(var.ami_id, terraform.workspace, "ami-default")
  instance_type_value = lookup(var.instance_type, terraform.workspace, "t2.micro")
  subnet_id_value   = var.subnet_id_value
  key_name_value    = var.key_name_value
}
```


### How Workspaces Solve the Problem

1. **Isolated State Files**:  
   Each workspace has its own state file, stored separately. This ensures that changes in one environment (e.g., `dev`) do not interfere with another environment (e.g., `prod`).

2. **Dynamic Configuration**:  
   You can use the `terraform.workspace` variable to dynamically adjust configurations based on the workspace. For example, you can select different instance types or AMIs for different environments.

3. **Simplified Management**:  
   Workspaces eliminate the need for duplicating Terraform code or maintaining separate configurations for each environment. You can manage all environments from a single codebase.

4. **Consistency and Predictability**:  
   With separate state files, Terraform can accurately track the state of resources in each environment, reducing the risk of errors and inconsistencies.


### How to Use Workspaces

#### Step 1: Create Workspaces
Create separate workspaces for each environment:
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

#### Step 2: Switch Workspaces
Switch to the desired workspace before running Terraform commands:
```bash
terraform workspace select dev    # Switch to the dev workspace
terraform workspace select staging # Switch to the staging workspace
terraform workspace select prod   # Switch to the prod workspace
```

#### Step 3: Apply Configuration
Apply the Terraform configuration for the selected workspace:
```bash
terraform apply
```


### Example Workflow

0. **Set Up Remote Backend**:  
   Refer to this [repository](https://github.com/saiabhiramjaini/Terraform-Remote-State-Backend-using-S3-and-DynamoDB) for detailed instructions on configuring a remote backend using S3 and DynamoDB.

1. **Initialize Terraform**:  
   Initialize Terraform and configure the backend for the desired environment. Use the appropriate `key` for each environment's state file:  
   - For **dev**:
     ```bash
     terraform init -backend-config="key=envs/dev/terraform.tfstate"
     ```
   - For **staging**:
     ```bash
     terraform init -backend-config="key=envs/staging/terraform.tfstate"
     ```
   - For **prod**:
     ```bash
     terraform init -backend-config="key=envs/prod/terraform.tfstate"
     ```

   If you are not using a remote backend, simply run:
   ```bash
   terraform init
   ```

2. **Create and Switch to the `dev` Workspace**:  
   Create a new workspace for the `dev` environment and switch to it:
   ```bash
   terraform workspace new dev
   terraform workspace select dev
   ```

3. **Apply Configuration for the `dev` Environment**:  
   Apply the Terraform configuration for the `dev` environment:
   ```bash
   terraform apply
   ```

4. **Switch to the `staging` Workspace**:  
   Switch to the `staging` workspace:
   ```bash
   terraform workspace select staging
   ```

5. **Apply Configuration for the `staging` Environment**:  
   Apply the Terraform configuration for the `staging` environment:
   ```bash
   terraform apply
   ```

6. **Switch to the `prod` Workspace**:  
   Switch to the `prod` workspace:
   ```bash
   terraform workspace select prod
   ```

7. **Apply Configuration for the `prod` Environment**:  
   Apply the Terraform configuration for the `prod` environment:
   ```bash
   terraform apply
   ```


### Key Notes:
- Each environment (`dev`, `staging`, `prod`) will have its own state file stored in a unique path within the S3 bucket.  
- The `key` parameter in the `terraform init -backend-config` command specifies the path for the state file.  
- This ensures complete isolation of state files for each environment, preventing conflicts and maintaining consistency.  

For example:
- **dev**: `envs/dev/terraform.tfstate`
- **staging**: `envs/staging/terraform.tfstate`
- **prod**: `envs/prod/terraform.tfstate`

This workflow ensures that each environment is managed independently with its own state file, providing isolation and consistency across environments.


### Benefits of Using Workspaces

1. **Isolation**:  
   Each environment has its own state file, ensuring complete isolation.

2. **Reusability**:  
   A single Terraform configuration can be reused across multiple environments.

3. **Scalability**:  
   Adding new environments is as simple as creating a new workspace and providing the appropriate configuration.

4. **Maintainability**:  
   Managing multiple environments becomes easier and less error-prone.



## Alternative Approach: Using `.tfvars` Files

If you prefer not to use the `lookup` function, you can manage environment-specific configurations using `.tfvars` files. This approach involves creating separate `.tfvars` files for each environment and specifying them when running Terraform commands.

### Step 1: Create `.tfvars` Files

1. **dev.tfvars**:
    ```hcl
    instance_type = "t2.micro"
    ami_id        = "ami-0abcd1234efgh5678"
    ```

2. **staging.tfvars**:
    ```hcl
    instance_type = "t2.medium"
    ami_id        = "ami-0efgh5678ijkl9012"
    ```

3. **prod.tfvars**:
    ```hcl
    instance_type = "t2.xlarge"
    ami_id        = "ami-0ijkl9012mnop3456"
    ```

### Step 2: Apply Configuration with `.tfvars` Files

When applying your Terraform configuration, specify the `.tfvars` file for the desired environment using the `-var-file` flag:

- **For Dev**:
    ```bash
    terraform apply -var-file="dev.tfvars"
    ```

- **For Staging**:
    ```bash
    terraform apply -var-file="staging.tfvars"
    ```

- **For Prod**:
    ```bash
    terraform apply -var-file="prod.tfvars"
    ```

### Step-by-Step Guide to Using Workspaces with `.tfvars` Files

1. **Create Workspaces**:
    ```bash
    terraform workspace new dev
    terraform workspace new staging
    terraform workspace new prod
    ```

2. **Switch Workspaces**:
    ```bash
    terraform workspace select dev    # Switch to the dev workspace
    terraform workspace select staging # Switch to the staging workspace
    terraform workspace select prod   # Switch to the prod workspace
    ```

3. **Apply Configuration with `.tfvars` Files**:
    ```bash
    terraform apply -var-file="dev.tfvars"    # For dev workspace
    terraform apply -var-file="staging.tfvars" # For staging workspace
    terraform apply -var-file="prod.tfvars"   # For prod workspace
    ```

