# AWS Ops for Insight
Collection of Terraform and Ansible scripts for easy AWS operations

# Set up your Linux User on the Shared Control Machine

## Logging into the Control Machine
Log into your user on the Controlling Machine provided by Insight, which you should be able to do with a command using the following command: 

    ssh -i <path/to/your/pem.key> <first_name>-<last_initial>@54.69.222.167
    
For example, assuming your PEM key is in your `.ssh` directory, you can log in with:

    ssh -i ~/.ssh/control.pem david-d@54.69.222.167

Alternatively, I added the following to my `.ssh/config`:

    Host dd-contol
        HostName 54.69.222.167
        User david-d
        Port 22
        IdentityFile ~/.ssh/control.pem
        
and then log in using the command `ssh dd-control` for my convenience.

## Clone this repo

This machine is pre-installed with Terraform and Ansible, and is designed to allow you to spin up the necessary infrastructure with minimal setup. However, you still need to download the latest scripts from this repo:

    git clone https://github.com/InsightDataScience/aws-ops-insight.git

## AWS credentials for your personal user
Your Linux user has a `.profile` file in your home directory where you can configure your control machine. Add your AWS credentials to your `.profile` using your editor of choice (e.g. with a command like `nano ~/.profile` or `vim ~/.profile`). Of course, your credentials will be different, but you should have something like this in your `.profile`:

    export AWS_ACCESS_KEY_ID=ABCDE1F2G3HIJKLMNOP  
    export AWS_SECRET_ACCESS_KEY=1abc2d34e/f5ghJKlmnopqSr678stUV/WXYZa12

**WARNING: DO NOT COMMIT YOUR AWS CREDENTIALS TO GITHUB!** AWS and bots are constantly searching Github for these credentials, and you will either have your account hacked, or your credentials revoked by AWS.

Whenever you change your `.profile`, don't forget to source it with the command:

    . ~/.profile
    
# Setting up your AWS Environment

We'll start by using Terraform to "provision" resources on your AWS account. Terraform is an industry-standard open source technology for Provisioning hardware, whether on any popular cloud provider (e.g. AWS, GCP), or in-house data centers. Terraform is written in Go, and is designed to quickly and easily create and destroy infrastructure of hundreds of resources in parallel. 

Terraform also has a great community of open source modules available in the [Terraform Registry](https://registry.terraform.io/). We'll be using several of the pre-built AWS modules now.

## Setting up your Virtual Private Cloud (VPC)
In past sessions, someone gets hacked and Bitcoin miners go crazy burning through AWS resources. To ensure that simple mistakes don’t cost you tremendously, you'll set up guardrails with a network that can only contain a fixed number of nodes. If you need more instances later, your PD can expand your network. 

AWS uses software-defined network to offer a small network that is secure from others called a Virtual Private Cloud (VPC). We'll use Terraform to set up a simple and small "sandbox VPC" where you can build your infrastructure safely.

Move into the `terraform/networking` directory of the repo you cloned:

    cd terraform/networking
    
Then initialize Terraform and apply the configuration we've set up in the `.tf` files within that directory:

    terraform init
    terraform apply
    
Terraform will ask your name (enter whatever you want), show you it's plan to create, modify, or destroy resources to get to the correct configuration you specified. After saying `yes` to the prompt, and waiting a few moments, you should see a successful message like this: 

    Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

    Outputs:

    database_subnets = []
    nat_public_ips = [
        52.36.7.200
    ]
    private_subnets = [
        subnet-69f74f10
    ]
    public_subnets = [
        subnet-b2f44ccb
    ]
    redshift_subnets = []
    vpc_id = vpc-3e4d1047

Terraform is designed to be idempotent, so you can always run the `terraform apply` command multiple times, without any issues. It's also smart about only changing what it absolutely needs to change. For example if you ran the apply command again, but use a different name, it will only rename a few resources rather than tearing down everything and spinning up more.

If you ever want to tear down your infrastructure, you can always do that with the command:

    terraform destroy
    


