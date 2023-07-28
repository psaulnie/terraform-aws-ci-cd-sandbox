# Implementing an AWS instance with Terraform

## Export AWS credential

First it is needed to add the AWS access credential on the system:

```bash
export AWS_ACCESS_KEY_ID={key_id}
export AWS_SECRET_ACCESS_KEY={secret_key_id}
```

To get access key, it can be created in the security credential tab of the AWS dashboard.

## Configuration file

```yaml
terraform { # Terraform settings
  required_providers { # what Terraform will use to provision the infrastructure
    aws = { # custom block
      source  = "hashicorp/aws" # optional hostname, namespace and the provider type (usually taken from the Terraform Registry
      version = "~> 4.16" # version of the source
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" { # Configuration of the specified provider
  region  = "us-west-2" # Region wanted for the server AWS, here's Oregon
}

# Definition of components of the infrastructure, might be physical of virtual like an EC2 instance
resource "aws_instance" "app_server" { # "aws_instance" and "app_server" form an unique ID: "aws_instance.app_server"
  ami           = "ami-830c94e3" # AMI* ID of an Ubuntu image
  instance_type = "t2.micro" # "t2.micro" qualifies for free tier

  tags = { # Tag to define the instance name
    Name = "ExampleAppServerInstance"
  }
}

# *AMI: Amazon Machine Image, master image for the creation of virtual servers (EC2 instances)
```

## Initialize the directory

```bash
$ terraform init
```

It will download the aws provider and install the folder `.terraform` . It will also install a `.terraform.lock.hcl` specifying the exact provider version used, it’s useful to update the provider

## Format and validate the configuration

To stick with a consistent formatting in config files, `terraform fmt` and `terraform validate` helps to correctly format the files.

## Create infrastructure

```bash
$ terraform apply
```

## Inspect State

```bash
$ terraform show
# aws_instance.app_server:
resource "aws_instance" "app_server" {
    ami                                  = "ami-830c94e3"
    arn                                  = "arn:aws:ec2:us-west-2:147728998385:instance/i-0a02808771ddc977d"
    associate_public_ip_address          = true
    availability_zone                    = "us-west-2a"
    cpu_core_count                       = 1
    cpu_threads_per_core                 = 1
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    id                                   = "i-0a02808771ddc977d"
    instance_initiated_shutdown_behavior = "stop"
    instance_state                       = "running"
    instance_type                        = "t2.micro"
    ipv6_address_count                   = 0
    ipv6_addresses                       = []
    monitoring                           = false
    placement_partition_number           = 0
    primary_network_interface_id         = "eni-0eccd057cde83bd7f"
    private_dns                          = "ip-172-31-30-106.us-west-2.compute.internal"
    private_ip                           = "172.31.30.106"
    public_dns                           = "ec2-54-185-5-224.us-west-2.compute.amazonaws.com"
    public_ip                            = "54.185.5.224"
    secondary_private_ips                = []
    security_groups                      = [
        "default",
    ]
    source_dest_check                    = true
    subnet_id                            = "subnet-083d2675c8deaf2ed"
    tags                                 = {
        "Name" = "TerraformUbuntuInstance"
    }
    tags_all                             = {
        "Name" = "TerraformUbuntuInstance"
    }
    tenancy                              = "default"
    user_data_replace_on_change          = false
    vpc_security_group_ids               = [
        "sg-0e03f5f7f4a3c76fa",
    ]

    capacity_reservation_specification {
        capacity_reservation_preference = "open"
    }

    cpu_options {
        core_count       = 1
        threads_per_core = 1
    }

    credit_specification {
        cpu_credits = "standard"
    }

    enclave_options {
        enabled = false
    }

    maintenance_options {
        auto_recovery = "default"
    }

    metadata_options {
        http_endpoint               = "enabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "optional"
        instance_metadata_tags      = "disabled"
    }

    private_dns_name_options {
        enable_resource_name_dns_a_record    = false
        enable_resource_name_dns_aaaa_record = false
        hostname_type                        = "ip-name"
    }

    root_block_device {
        delete_on_termination = true
        device_name           = "/dev/sda1"
        encrypted             = false
        iops                  = 0
        tags                  = {}
        throughput            = 0
        volume_id             = "vol-0cec564b66dbefae1"
        volume_size           = 8
        volume_type           = "standard"
    }
}
```
# Access the created EC2 instance

## Create a key pair

In the console EC2 dashboard:

1. Go to Key pairs
2. Create key pair button
3. Add name and click create key pair
4. The key pair is now created and downloaded
5. Add this lines in the `main.tf` file:
    
    ```bash
    resource "aws_instance" "app_server" {
      ami           = "ami-007ec828a062d87a5"
      instance_type = "t2.micro"
      key_name      = "tf-key-pair" # Created key pair
    
      tags = {
        Name = "TerraformUbuntuInstance"
      }
    }
    
    resource "aws_default_vpc" "default" { # Create a default VPC
       tags = {
         Name = "Default VPC"
       }
    }
    
    resource "aws_default_security_group" "default" {
       vpc_id      = "${aws_default_vpc.default.id}" # Use the create VPC
     ingress { # Incoming connection
         # TLS incoming authorized port: 22 and from any ip
         from_port   = 22
         to_port     = 22
         protocol    = "tcp"
         cidr_blocks     = ["0.0.0.0/0"]
       }
     egress { # send data to any ip
         from_port       = 0
         to_port         = 0
         protocol        = "-1"
         cidr_blocks     = ["0.0.0.0/0"]
       }
     }
    ```
    

## Connect using SSH

```bash
$ ssh -i my_ec2_private_key.pem {username}@{public dns}
```

# Delete the instance

```
$ terraform destroy
```

# Next things to do

- Create key pair with the instance using Terraform
- Connect through SSH
- Activate EC2 instance connect
