# AWS Ops for Insight
Collection of Terraform (0.12.x) and Ansible scripts for easy AWS operations.

## Clone this repo into the home directory to your local machine

This repo is pre-installed with Terraform and Ansible, and is designed to allow you to spin up the necessary infrastructure with minimal setup. However, you still need to change to the home directory (abbreviated `~` in bash) and download the latest scripts from this repo:
    
    cd ~
    git clone https://github.com/InsightDataScience/aws-ops-insight.git

## AWS credentials for your IAM user (not the root account)
Your Linux user has a `.profile` file in your home directory where you can configure your local machine. The AWS credentials for your IAM user should be placed in the `.profile` using your editor of choice (e.g. with a command like `nano ~/.profile` or `vim ~/.profile`). Of course, your credentials will be different, but you should have something like this in your `.profile`:

    export AWS_ACCESS_KEY_ID=ABCDE1F2G3HIJKLMNOP  
    export AWS_SECRET_ACCESS_KEY=1abc2d34e/f5ghJKlmnopqSr678stUV/WXYZa12

**WARNING: DO NOT COMMIT YOUR AWS CREDENTIALS TO GITHUB!** AWS and bots are constantly searching Github for these credentials, and you will either have your account hacked, or your credentials revoked by AWS.

Whenever you change your `.profile`, don't forget to source it with the command (note the `.` at the beginning of the command):

    . ~/.profile
    
# Setting up your AWS Environment

We'll start by using Terraform to "provision" resources on your AWS account. Terraform is an industry-standard open source technology for provisioning hardware, whether on any popular cloud providers (e.g. AWS, GCP, Azure), or in-house data centers. Terraform is written in Go, and is designed to quickly and easily create and destroy infrastructure of hundreds of resources in parallel. 

Terraform also has a great community of open source modules available in the [Terraform Registry](https://registry.terraform.io/). We'll be using several of the pre-built AWS modules now.

## Setting up your Virtual Private Cloud (VPC)
In past sessions, someone gets hacked and Bitcoin miners go crazy burning through AWS resources. To ensure that simple mistakes don’t cost you tremendously, you'll set up guardrails with a network that can only contain a fixed number of nodes. If you need more instances later, we can help you expand your network. 

AWS uses software-defined network to offer a small network that is secure from others called a Virtual Private Cloud (VPC). We'll use Terraform to set up a simple and small "sandbox VPC" where you can build your infrastructure safely.

Move into the `terraform` directory of the repo you just cloned:

    cd aws-ops-insight/terraform

Edit the variables.tf file. Navigate to the variable "aws_region", input applicable AWS region.

variable "aws_region" {
  description = "AWS region to launch servers. For NY,BOS,VA use us-east-1. For SF use us-west-2"
  default     = "Insert AWS Region here"

Navigate to the variable "amis", remove the region amazon machine image (AMI) that isn't applicable.

variable "amis" {
 type = map (string)
  default = {
    "us-east-1" = "ami-0b6b1f8f449568786"
    "us-west-2" = "ami-02c8040256f30fb45"

Save and exit the variables.tf file.
    
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
- Security Group with inbound SSH connectivity from your local machine.
- 4 node cluster, with 1 "master" and 3 "workers"

### Destroying your infrastructure

**Don't** destroy your infra now, but if you ever want to tear down your infrastructure, you can always do that with the command:

    terraform destroy

If you want to destroy a subset of your infrastructure, simply change your `main.tf` file accordingly and re-run the `tf apply` to apply these changes. Terraform tracks the current state in the `terraform.tfstate` file (or a remote backend like S3 or Consul), but if you manually delete resources on the console, this can mess up your Terraform state. As a result, **we don't recommend mixing a Terraform and manual setup** - try to do everything within Terraform if possible.

### Setting Terraform Variables
You probably don't want to enter your name everytime you run the apply command (and you can't automate that), so let's set the variable. You could set the variable from the command line with something like:

    terraform apply -var 'fellow_name=Insert Name Here'
    
or by setting an environment variable that starts with `TF_VAR_` like:

    export TF_VAR_fellow_name=david
    
(but don't forget to source your `.profile` again). Note that Terraform treats your AWS credentials specially - they don't need the `TF_VAR` prefix to be detected.

Finally, you can set variables in the file `terraform.tfvars`. Go into the file and uncomment the lines with variables (but use your name and key pair, of course):

    # name of the Fellow (swap for your name)
    fellow_name="Insert Name Here"

    # name of your key pair (already created in AWS)
    keypair_name="Insert Name Here-IAM-keypair"

For security, **YOU SHOULD NEVER PUT YOUR AWS CREDENTIALS IN A FILE THAT COULD BE COMMITTED TO GITHUB**, so you can use environment variables for your credentials. For other types of variables, you should use the method that's most convenient (e.g. files are easy to share with others, but the command line could be easier when prototyping).

# Configuring Technologies with Ansible

## Setup Ansible to connect with AWS
With all our resources provisioned, we'll now use the "configuration management" tool, Ansible, to actually install and start technologies like Hadoop, Spark, etc. Ansible is also open source and popular at many startups for it's ease of use, though many larger companies use alternative tools like Puppet and Chef. 

We'll start configuring machines with the scripts in the `ansible` directory. Change to it with:

    cd ../ansible

In order for your control machine to SSH into your nodes via Ansible, it will need your PEM key stored on it. You can add it with a `scp` command like the following (**which should be ran from your local machine, not the control machine**):

    scp -i ~/.ssh/control.pem ~/.ssh/david-IAM-keypair.pem david-d@bos.insightdata.com:~
    
or if you've set up your `.ssh/config` file as described above, it would be something like (but with **your name and key**):

    scp ~/.ssh/david-IAM-keypair.pem dd-control:~

**Back on the control machine**, copy your keypair to the `.ssh` folder on your control machine, with a command similar to:

    sudo mv ~/david-IAM-keypair.pem ~/.ssh

Next, you'll need to configure the `ansible.cfg` file to reflect your key pair name and location on the control machine. This sets global configuration This also assumes that this repo is cloned into your home directory. The relevant lines of the `ansible.cfg` are:

    [defaults]
    host_key_checking = False
    private_key_file = /home/david-d/.ssh/david-IAM-keypair.pem
    ansible_user = david-d
    log_path = ~/ansible.log
    roles_path = ~/aws-ops-insight/ansible/roles
    ....

Next, install the AWS Software Development Kit (SDK) for Python, which is called `boto`. Ansible is written in Python, so this is how Ansible connects with AWS. Unfortunately, Ansible is in the middle of migrating from Python 2 to Python 3, so you'll need both the `boto` and `boto3` libraries to use all the modules.

    pip install boto boto3
    
Next, add the following additonal environment variables to your control machine's `.profile` for Ansible:

    export AWS_REGION=us-west-2
    export EC2_INI_PATH=~/aws-ops-insight/ansible/ec2.ini
    export ANSIBLE_INVENTORY=~/aws-ops-insight/ansible/ec2.py

The first sets the region to Oregon (**you should set your region to `us-east-1` if you're on the East coast**). The other  two lines are necessary to initialize and use Ansible's "Dynamic Inventory" feature. Ansible keeps an "inventory" of the host machines you're installing technologies onto, and the `ec2.py` script collects this information dynamically. This is how Ansible knows about the instances that Terraform just launched.

The `ec2.ini` is simply some initializations that we're using. For example, it ignores regions and services that most Fellows don't use (e.g. the Beijing data cente `cn-north-1`, or the AWS DNS service, Route53).

To use this, make sure that the `ec2.py` script has permission to execute (e.g. `+x`) with the `chmod` command:

    chmod +x ec2.py

Finally, you can test this by running the Ansible playbook `get-cluster-list.yml`:

    ansible-playbook get-cluster-list.yml
    
which should display the "facts" for any instances in AWS with the tag `Cluster` set to `hadoop` **(if you don't have this tag set by Terraform, go back and add it to `main.tf`, apply it now, and re-run the playbook)**. There should be a lot of information displayed with a summary at the end like:

    PLAY RECAP ****************************************************************
    localhost                  : ok=3    changed=0    unreachable=0    failed=0

  
