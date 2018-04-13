# peg-up
Collection of Terraform and Ansible scripts for easy AWS operations

## Logging into the Control Machine
Log into your user on the Controlling Machine provided by Insight. This machine is pre-installed with Terraform and Ansible, and is designed to allow you to spin up the necessary infrastructure with minimal setup.

Once you're logged in, clone this repo:

    git clone https://github.com/InsightDataScience/peg-up/

## AWS credentials for your personal user
Add your AWS credentials to your `.profile` using your editor of choice. Of course, your credentials will be different, but you should have something like this in your `.profile`:

    export AWS_ACCESS_KEY_ID=ABCDE1F2G3HIJKLMNOP  
    export AWS_SECRET_ACCESS_KEY=1abc2d34e/f5ghJKlmnopqSr678stUV/WXYZa12

**WARNING: DO NOT COMMIT YOUR AWS CREDENTIALS TO GITHUB!** AWS and bots are constantly searching Github for these credentials, and you will either have your account hacked, or your credentials revoked by AWS.
