# AWS Ops for Insight
Collection of Terraform and Ansible scripts for easy AWS operations

# Set up your Linux User on the Shared Control Machine

## Logging into the Control Machine
Log into your user on the Controlling Machine provided by Insight, which you should be able to do with a command using the following command: 

    ssh -i <path/to/your/pem.key> <first_name>-<last_initial>@ops.insightdata.com
    
For example, assuming your PEM key is in your `.ssh` directory, you can log in with:

    ssh -i ~/.ssh/control.pem david-d@ops.insightdata.com

Alternatively, I added the following to my `.ssh/config`:

    Host dd-contol
        HostName ops.insightdata.com
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
In past sessions, someone gets hacked and Bitcoin miners go crazy burning through AWS resources. To ensure that simple mistakes don’t cost you tremendously, you'll set up guardrails with a network that can only contain a fixed number of nodes. If you need more instances later, we can help you expand your network. 

AWS uses software-defined network to offer a small network that is secure from others called a Virtual Private Cloud (VPC). We'll use Terraform to set up a simple and small "sandbox VPC" where you can build your infrastructure safely.

Move into the `terraform` directory of the repo you cloned:

    cd aws-ops-insight/terraform
    
Then initialize Terraform and apply the configuration we've set up in the `.tf` files within that directory:

    terraform init
    terraform apply
    
Terraform will ask your name (enter whatever you want) and IAM keypair (enter the exact name of your key, **without the `.pem` extension**). Then it will show you it's plan to create, modify, or destroy resources to get to the correct configuration you specified. After saying `yes` to the prompt, and waiting a few moments (the NAT gateways can take a minute or two), you should see a successful message like this: 

    Apply complete! Resources: 18 added, 0 changed, 0 destroyed.

    Outputs:

    cluster_size = 4

Terraform is designed to be idempotent, so you can always run the `terraform apply` command multiple times, without any issues. It's also smart about only changing what it absolutely needs to change. For example if you ran the apply command again, but use a different name, it will only rename a few resources rather than tearing down everything and spinning up more.

If all went well, you have the following resources added:

- VPC sandbox with all the necessary networking
- Security Group, with all ports open to and from any IP
- 4 node cluster, with 1 "master" and 3 workers

**Don't** destroy your infra now, but if you ever want to tear down your infrastructure, you can always do that with the command:

    terraform destroy
    
### Setting Terraform Variables
You probably don't want to enter your name everytime you run the apply command (and you can't automate that), so let's set the variable. You could set the variable from the command line with something like:

    terraform apply -var 'fellow_name=david'
    
or by setting an environment variable that starts with `TF_VAR_` like:

    export TF_VAR_fellow_name=david
    
(but don't forget to source your `.profile`). Note that Terraform treats your AWS credentials specially - they don't need the `TF_VAR` prefix to be detected.

Finally, you can set variables in the file `terraform.tfvars`. Go into the file and uncomment the lines with variables (but use your name and key pair, of course):

    # name of the Fellow (swap for your name)
    fellow_name="david"

    # name of your key pair (already created in AWS)
    keypair_name="david-IAM-keypair"

For security, **YOU SHOULD NEVER PUT YOUR AWS CREDENTIALS IN A FILE THAT COULD BE COMMITTED TO GITHUB**, so you can use environment variables for your credentials. For other types of variables, you should use the method that's most convenient (e.g. files are easy to share with others, but the command line could be easier when prototyping).

# Configuring Technologies with Ansible

With all our resources provisioned, we'll start configuring machines with the scripts in the `ansible` directory. Change to it with:

    cd ../ansible

In order for your control machine to SSH into your nodes via Ansible, it will need your PEM key stored on it. You can add it with a `scp` command like the following (**which should be ran from your local machine, not the control machine**):

    scp -i ~/.ssh/control.pem ~/.ssh/david-IAM-keypair.pem david-d@ops.insightdata.com:~/.ssh/
    
or if you've set up your `.ssh/config` file as described above, it would be something like:

    scp ~/.ssh/david-IAM-keypair.pem dd-control:~/.ssh/

You'll also need to configure the `ansible.cfg` file to reflect your key pair name and location on the control machine. This also assumes that this repo is cloned into your home directory. The relevant lines of the `ansible.cfg` are:

    [defaults]
    host_key_checking = False
    **ansible_ssh_private_key_file = ~/.ssh/david-IAM-keypair.pem**
    ansible_user = ubuntu
    log_path = ~/ansible.log
    **roles_path = ~/aws-ops-insight/ansible/roles**
    ....

Next, you should install the `boto` library 

    pip install boto
    
    
