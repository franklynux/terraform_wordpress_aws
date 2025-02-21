# Advanced WordPress Deployment on AWS Using Terraform

## **Table of Contents**

- [Advanced WordPress Deployment on AWS Using Terraform](#advanced-wordpress-deployment-on-aws-using-terraform)
  - [**Table of Contents**](#table-of-contents)
  - [**1. Project Overview**](#1-project-overview)
    - [**Introduction**](#introduction)
    - [**Tech Stack**](#tech-stack)
    - [**Features**](#features)
  - [**2. Introduction to Terraform**](#2-introduction-to-terraform)
    - [Terraform State and Statefiles](#terraform-state-and-statefiles)
  - [**Provider in Terraform**](#provider-in-terraform)
    - [**Terraform Modules**](#terraform-modules)
    - [**Variables and Outputs**](#variables-and-outputs)
    - [**Main Terraform Files**](#main-terraform-files)
    - [**Terraform `.tfvars` Files**](#terraform-tfvars-files)
  - [**3. Prerequisites**](#3-prerequisites)
    - [**Environment Setup**](#environment-setup)
    - [**Resource Requirements**](#resource-requirements)
  - [**4. Infrastructure Architecture**](#4-infrastructure-architecture)
    - [**Diagram**](#diagram)
  - [**5. Deployment Steps**](#5-deployment-steps)
    - [**5.1 Setting Up Terraform**](#51-setting-up-terraform)
    - [**5.2 Setting Up the Terraform Project Directory**](#52-setting-up-the-terraform-project-directory)
    - [**5.3 Deployment Steps for Each Module**](#53-deployment-steps-for-each-module)
    - [Installation Scripts for user-data configuration](#installation-scripts-for-user-data-configuration)
    - [**5.4 Documentation for Terraform Scripts**](#54-documentation-for-terraform-scripts)
    - [**5.5 Verify AWS Resources**](#55-verify-aws-resources)
    - [**5.5.1 Post Deployment Steps**](#551-post-deployment-steps)
    - [**5.6 Simulating Traffic for Auto Scaling**](#56-simulating-traffic-for-auto-scaling)
    - [**5.7 Terraform Commands for Setup and Deployment**](#57-terraform-commands-for-setup-and-deployment)
  - [**6. Monitoring and Logging**](#6-monitoring-and-logging)
  - [**7. Security Considerations**](#7-security-considerations)
  - [**8. Troubleshooting**](#8-troubleshooting)
  - [**9. Additional Enhancements**](#9-additional-enhancements)
  - [**10. Cleanup**](#10-cleanup)
  - [**11. Conclusion**](#11-conclusion)
  - [**12. Contributing**](#12-contributing)
  - [Getting Help](#getting-help)

## **1. Project Overview**

### **Introduction**

This project demonstrates how to deploy a scalable, fault-tolerant WordPress application on AWS using Terraform. The deployment follows industry best practices, ensuring a secure, optimized, and highly available setup.

### **Tech Stack**

- **Infrastructure as Code**: Terraform
- **Cloud Provider**: AWS (EC2, RDS, ALB, S3, IAM, CloudWatch, EFS)
- **Application**: WordPress

### **Features**

- Highly available and scalable architecture.
- Secure setup with IAM roles and least privilege.
- Automated deployment and configuration.
- Health monitoring and logging.

---

## **2. Introduction to Terraform**

Terraform is an open-source Infrastructure as Code (IaC) tool that allows you to define and provision infrastructure using a declarative configuration language. It enables you to manage cloud resources efficiently and consistently, making it easier to automate infrastructure deployment and management.

### Terraform State and Statefiles

Terraform maintains a state file that acts as a source of truth for your infrastructure. This state file tracks the current state of your resources, allowing Terraform to manage and update them effectively.

When you run commands like `terraform apply`, `terraform plan`, or `terraform destroy`, Terraform uses the state file to determine what changes need to be made to your infrastructure. The state file is crucial for understanding the relationships between resources and ensuring that your infrastructure is consistent with your configuration files.

By default, Terraform stores the state file locally, but it can also be configured to use remote backends (like S3 or Terraform Cloud) for better collaboration and state management.

## **Provider in Terraform**

A provider in Terraform is responsible for managing the lifeccycle of a resource. Providers are plugins that terraform uses to interact with different infrastructure platforms or services. They define a set of resources and data sources that terraform can manage.

```
provider "aws" {
  region = "us-west-2"
}
```

### **Terraform Modules**

Modules are containers for multiple resources that are used together. A module can be thought of as a package of Terraform configurations that can be reused across different projects. By organizing your configurations into modules, you can promote code reuse and maintainability.

### **Variables and Outputs**

- **Variables**: Variables allow you to parameterize your Terraform configurations. They enable you to define values that can be reused throughout your configuration files, making it easier to manage and customize your infrastructure.
- **Outputs**: Outputs are used to extract information from your Terraform configurations. They allow you to display values after the infrastructure has been created, making it easier to reference important information such as resource IDs or endpoints.

### **Main Terraform Files**

- **main.tf**: This file contains the primary configuration for the infrastructure, defining the resources to be created and their relationships. An AWS provider and an EC2 instance are created in this example.

  ```
  provider "aws" {
  region = "us-west-2"
  }
  resource "aws_instance" "example"{
    ami  =  "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
  }
  ```

- **variables.tf**: This file defines the input variables for the Terraform configuration, allowing for parameterization and customization of the deployment.

  ```
  variable "example_var"{
    type = string
    default = "example_value"
  }
  ```

- **outputs.tf**: This file specifies the outputs of the Terraform configuration, providing useful information after the infrastructure is created, such as resource IDs and endpoints.

  ```
  output "example_output" {
    value = aws_instance.example.id
    }
  ```

### **Terraform `.tfvars` Files**

`.tfvars` files are used to define variable values in a separate file, allowing you to manage configurations more easily. By using `.tfvars` files, you can keep sensitive information and environment-specific settings out of your main configuration files.

---

## **3. Prerequisites**

### **Environment Setup**

- **Installed Tools**: Ensure the following tools are installed:
  - Terraform
  - AWS CLI
  - SSH client
- **AWS Account**: An AWS account with access keys configured.
- **Knowledge**: Basic understanding of Terraform and AWS services.

### **Resource Requirements**

- **Domain Name**: Required if using Route 53 for DNS.
- **SSL Certificate**: Optional, for HTTPS setup.
- **IAM Permissions**: Ensure sufficient IAM permissions to create resources.
**Note:** No custom domain name was used for this project, so  no use for Route 53 and HTTPS configuraton.

---

## **4. Infrastructure Architecture**

### **Diagram**

![AWS Architecture](./images/Terraform%20Architecture%20Diagram.png)

*Figure:* AWS Architectural diagram showing components.

---

## **5. Deployment Steps**

### **5.1 Setting Up Terraform**

1. **Install Terraform**:
   - Download Terraform from the [official website](https://www.terraform.io/downloads.html).
   - Follow the installation instructions for your operating system.

2. **Configure AWS CLI**:
   - Install the AWS CLI and configure it with your AWS credentials:

     ```bash
     aws configure
     ```

   - Enter your AWS Access Key, Secret Key, region, and output format.

      ![aws config](./images/AWS%20configure.png)

3. **Directory Structure**:

   ```plaintext
   ├── backend.tf
   ├── main.tf
   ├── outputs.tf
   ├── variables.tf
   ├── modules/
   │   ├── alb/
   │   ├── asg/
   │   ├── dynamodb/
   │   ├── efs/
   │   ├── networking/
   │   ├── rds/
   │   ├── s3/
   │   └── vpc/
   ```

4. **Backend Configuration**:
   - Use S3 and DynamoDB for Terraform state management.

5. **Variables and Outputs**:
   - Define reusable variables in `variables.tf`.
   - Provide meaningful outputs in `outputs.tf`.

### **5.2 Setting Up the Terraform Project Directory**

1. **Create the Main Project Directory**:

   ```bash
   mkdir terraform_wordpress_aws
   cd terraform_wordpress_aws
   ```

   ![main project directory](./images/project%20directory%20set.png)
   ![main project directory](./images/project%20directory%20set%201.png)

2. **Create Subdirectories for Modules**:

    **Linux Systems:**

   ```bash
   mkdir -p modules/alb modules/asg modules/dynamodb modules/efs modules/networking modules/rds modules/s3 modules/vpc modules/wp-server
   ```

   **Windows Systems:**

   ```bash
   New-Item -ItemType Directory -Force -Path modules/alb, modules/asg, modules/dynamodb, modules/efs, modules/networking, modules/rds, modules/s3, modules/vpc, modules/wp-server
   ```

   ![project subdirectories](./images/project%20subdirectory%20set.png)

   ![project subdirectories](./images/project%20directory%20set%201.png)

3. **Create Required Terraform Files**:
   - Create the following files in the root directory:
     - `backend.tf`
     - `main.tf`
     - `outputs.tf`
     - `variables.tf`
     - `terraform.tfvars`

      ![terraform root files](./images/root%20files%20creaed.png)

4. **Initialize Terraform**:
   - Run the following command to initialize the Terraform working directory:

     ```bash
     terraform init
     ```

      ![terraform init](./images/terraform%20init.png)

### **5.3 Deployment Steps for Each Module**

- **ALB (Application Load Balancer)**:
  1. Ensure the ALB module is configured in `main.tf`.
  2. Verify security group settings to allow HTTP/HTTPS traffic.
  3. Check the health check path to ensure it matches your application.

  **main.tf:**
  ![ALB module config](./images/alb%20main%20script.png)

  **outputs.tf:**
  ![ALB module config](./images/alb%20outputs.png)

  **variables.tf:**
  ![ALB module config](./images/alb%20variables.png)

- **ASG (Auto Scaling Group)**:
  1. Configure the ASG module in `main.tf` to define desired capacity and scaling policies.
  2. Ensure the launch template is set up correctly with the necessary AMI and instance type.

    **main.tf:**
    ![ASG module config](./images/asg%20main%20script.png)

    **outputs.tf:**
    ![ASG module config](./images/asg%20output.png)

    **variables.tf:**
    ![ASG module config](./images/asg%20variables.png)

  ### Installation Scripts for user-data configuration

    ***Bastion Host Script (`bastion.sh`)***

    The `bastion.sh` script is responsible for setting up the Bastion host. It performs the following actions:

  - Updates the package list to ensure the latest information on available packages.
  - Installs the Apache2 web server.
  - Starts the Apache2 service to begin serving web pages.
  - Enables the Apache2 service to start automatically on system boot.
  - Outputs a simple HTML message to the default web page.

    ![Bastion Script Screenshot](./images/bastion%20script.png)

  ***WordPress Installation Script (`wordpress.sh`)***

    The `wordpress.sh` script handles the installation of WordPress. It includes several key steps:

  - Logging messages for tracking the installation process.
  - Installing required packages, including Apache and PHP.
  - Fetching the RDS endpoint from AWS SSM Parameter Store.
  - Setting up the MySQL database.
  - Downloading and configuring WordPress.
  - Updating the `wp-config.php` file with database settings.
  - Configuring Apache and setting permissions.
  - Creating a health check script to verify database connectivity.

    ![WordPress Script Screenshot](./images/wordpress%20script.png)  

- **DynamoDB**:
  1. Define the DynamoDB table in the `dynamodb` module.
  2. Set up read/write capacity units based on your application needs.

  **main.tf:**
  ![dynamodb module config](./images/dynamodb%20main.png)

- **EFS (Elastic File System)**:
  1. Configure the EFS module to create a file system.
  2. Ensure mount targets are set up in the appropriate subnets.

  **main.tf:**
  ![EFS module config](./images/efs%20main%20script.png)

  **outputs.tf:**
  ![EFS module config](./images/efs%20outputs.png)

  **variables.tf:**
  ![EFS module config](./images/efs%20variables.png)

- **Networking**:
  1. Verify the VPC and subnet configurations in the networking module.
  2. Ensure route tables are correctly associated with the subnets.

  **main.tf:**
  ![networking module config](./images/networking%20main%20script.png)

  **outputs.tf:**
  ![networking module config](./images/networking%20outputs%20script.png)

  **variables.tf:**
  ![networking module config](./images/networking%20variables%20script.png)

- **RDS (Relational Database Service)**:
  1. Configure the RDS module with the desired database engine and instance type.
  2. Ensure security groups allow access from the application servers.

  **main.tf:**
  ![RDS module config](./images/rds%20main%20script.png)

  **outputs.tf:**
  ![RDS module config](./images/rds%20outputs.png)

  **variables.tf:**
  ![RDS module config](./images/rds%20variables.png)

- **S3 (Simple Storage Service)**:
  1. Define the S3 bucket in the S3 module.
  2. Set up bucket policies and versioning as needed.

  **main.tf:**
  ![S3 module config](./images/s3%20main%20script.png)

  **variables.tf:**
  ![S3 module config](./images/s3%20variables.png)

- **VPC (Virtual Private Cloud)**:
  1. Ensure the VPC module is configured with the correct CIDR block.
  2. Verify that subnets are created in the appropriate availability zones.

  **main.tf:**
  ![VPC module config](./images/vpc%20main%20script.png)

  **outputs.tf:**
  ![VPC module config](./images/vpc%20outputs.png)

- **WP Server (WordPress Server)**:
  1. Configure the WP server module to deploy the WordPress application.
  2. Ensure that the server has access to the RDS instance and EFS.

### **5.4 Documentation for Terraform Scripts**

***Detailed comments*** have been added to the Terraform scripts to explain the purpose of each resource, module, and configuration.

### **5.5 Verify AWS Resources**

After deploying the infrastructure using Terraform, you can verify that the following resources were created successfully in the AWS Management Console:

1. **Application Load Balancer (ALB)**:
   - Navigate to the EC2 Dashboard > Load Balancers.
   - Check for the ALB and ensure it is in the "active" state.

    ![ALB created](./images/ALB%20Created.png)

1. **Target Group**:
   - In the EC2 Dashboard, go to Target Groups.
   - Verify that the target group is listed and healthy.

    ![Target group created](./images/TG%20created%20&%20healthy.png)

2. **EC2 Instances**:
   - Go to the EC2 Dashboard > Instances.
   - Ensure that the expected EC2 instances are running.

    ![EC2 instances running](./images/Instances%20created%20and%20running.png)

3. **Auto Scaling Group (ASG)**:
   - Navigate to the EC2 Dashboard > Auto Scaling Groups.
   - Confirm that the ASG is created and has the desired number of instances.

    ![ASG created](./images/ASG%20Created.png)

4. **Elastic File System (EFS)**:
   - Go to the EFS Dashboard.
   - Verify that the EFS file system is created and available.

    ![EFS created](./images/EFS%20created.png)

5. **Relational Database Service (RDS)**:
   - Navigate to the RDS Dashboard.
   - Check that the RDS instance is available and running.

    ![RDS created](./images/RDS%20created.png)

6. **NAT Gateways**:
   - Go to the VPC Dashboard > NAT Gateways.
   - Ensure that the NAT Gateways are created and available.

    ![NAT GW created](./images/NAT%20GW%20Created.png)

7. **Virtual Private Cloud (VPC)**:
   - Navigate to the VPC Dashboard.
   - Verify that the VPC is created with the expected CIDR block.

    ![VPC created](./images/VPC%20created.png)

8. **Security Groups**:
   - Go to the EC2 Dashboard > Security Groups.
   - Ensure that the security groups are created with the correct rules.

    ![Security groups created](./images/Security%20Groups%20Created.png)

9. **Subnets & Route Tables**:
    - Navigate to the VPC Dashboard > Subnets and Route Tables.
    - Verify that the subnets and route tables are created and associated correctly.

      ![Subnets & Route Tables created](./images/VPC,%20Subnets%20&%20Route%20tables%20created.png)

10. **SSM Role**:
    - Go to the IAM Dashboard > Roles.
    - Ensure that the SSM role is created and has the necessary permissions.

    ![SSM Role created](./images/SSM%20Role%20for%20wordpress%20created.png)

11. **S3 Buckets**:
    - Navigate to the S3 Dashboard.
    - Verify that the S3 buckets for ALB access logs and Terraform statefile are created and listed.

    ![S3 buckets created](./images/S3%20buckets%20Created.png)

12. **DynamoDB Lock Table**:
    - Go to the DynamoDB Dashboard.
    - Ensure that the lock table is created and available.

### **5.5.1 Post Deployment Steps**

- **Access WordPress**: Use the ALB endpoint to access WordPress.
  ![ALB dns name](./images/ALB%20DNS%20name.png)

  ![wordpress initial page](./images/Wordpress%20admin.png)

- **Complete Installation**: Follow the on-screen instructions to set up the WordPress admin account.

  ![wordpress install page](./images/wordpress%20insall.png)

  ![wordpress click install](./images/wordpress%20(click)%20insall.png)

  ![wordpress installed succesfully](./images/Wordpress%20insall%20successful.png)

- **Verify Database Connectivity**: Confirm that WordPress is connected to the RDS instance. This can be verified using the URL:  `http://<alb-dns-name>/health.php`

![wordpress connected to DB success](./images/wordpress%20database%20connection%20success.png)

### **5.6 Simulating Traffic for Auto Scaling**

**Note**: This installation is being performed on an Ubuntu t2.micro EC2 instance within the same VPC as the WordPress application.

To trigger the auto-scaling policies and simulate traffic, follow these steps:

1. **Install Siege**:
   - For Linux:

     ```bash
     sudo apt-get update
     sudo apt-get install siege -y
     ```

     ![siege install](./images/siege%20installed.png)

   - For Windows:
     - Download the Siege installer from the [official Siege website](https://www.joedog.org/siege-home/).
     - Follow the installation instructions provided.

2. **Run Siege to Simulate Traffic**:
   - Execute the following command to simulate traffic to the ALB endpoint:

     ```bash
     siege -c 100 -t 5m http://<alb-dns-name>/
     ```

     ![siege run](./images/siege%20running.png)

   - This command simulates 100 concurrent users for 5 minutes.

3. **Monitor Auto Scaling Actions**:
   - Check the AWS Management Console under EC2 > Auto Scaling Groups to observe the scaling actions.

    **ASG Scale down:**
   - ![Scale Up Screenshot](./images/ASG%20high%20alarm%20scale%20up%20max.png)

     ![Scale Up Screenshot](./images/ASG%20scale%20up%20success.png)
    **ASG Scale down:**
   - ![Scale Down Screenshot](./images/ASG%20scale%20down%20(init).png)
   ![Scale Down Screenshot](./images/ASG%20scale%20down%20successful.png)

### **5.7 Terraform Commands for Setup and Deployment**

1. **`terraform init`**: Initializes the Terraform working directory.

    ![terraform init](./images/terraform%20init.png)

2. **`terraform validate`**: Validates the configuration syntax.

    ![terraform validate](./images/terraform%20validate.png)

3. **`terraform plan`**: Creates an execution plan for changes.

    ![terraform plan](./images/terraform%20plan.png)

4. **`terraform apply`**: Applies changes to reach the desired state. Optionally, use the `-auto-approve` flag to skip the prompt to confirm the apply action.

    ![terraform apply](./images/terraform%20apply%201.png)
    ![terraform apply](./images/terraform%20apply%202.png)

1. **`terraform destroy`**: Destroys all resources managed by Terraform. Add the `auto-approve` flag to skip the confirmation prompt, this is optional.

    ![terraform destroy](./images/terraform%20destroy.png)
    ![terraform destroy complete](./images/terraform%20destroy%20complete.png)

---

## **6. Monitoring and Logging**

- Use CloudWatch for metrics and logs.
![CloudWatch metrics & logs](./images/CW%20metrics.png)
- Set up alarms for resource utilization.
- Enable access logs for ALB and S3.

---

## **7. Security Considerations**

- Use HTTPS with ACM for secure connections.
- Rotate IAM credentials regularly.
- Restrict SSH access to known IP addresses.

---

## **8. Troubleshooting**

- **Issue**: ALB health check failures.
  - **Solution**: Verify security group rules and health check path.
- **Issue**: Database connection errors.
  - **Solution**: Check RDS security groups and subnet configurations.

---

## **9. Additional Enhancements**

- Implement CI/CD pipelines.
- Configure multi-region disaster recovery.

---

## **10. Cleanup**

1. Run `terraform destroy` to remove all resources.
2. Empty S3 buckets before deletion if `force_destroy` is not enabled.

---

## **11. Conclusion**

This project demonstrates a comprehensive approach to deploying WordPress on AWS using Terraform. Continuous improvement and feedback are encouraged.

---

## **12. Contributing**

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m 'Add YourFeature'`
4. Push to the branch: `git push origin feature/YourFeature`
5. Open a pull request

---

## Getting Help

If you encounter any issues or have questions, please open an issue in the GitHub repository or contact me for assistance.
