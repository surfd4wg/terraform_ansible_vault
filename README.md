# Install HashiCorp Vault via Terraform and Ansible:

You will need to input your AWS user credentials (with a user that has privileges to make an (EC2 etc..) instance) into the `/terraform_aws/variables.tf` file.

This folder contains sub folders with /ansible that holds the playbook file you want to deploy on the server, the default playbook filename is:  vault.yml
You will need to alter the `main.tf` file in the `terraform_aws folder` if you plan to change this filename.

To initiazlize the Terraform , go into `/terraform_aws`  folder and run `terraform init` -  This will download the needed plugins Terraform uses to create an AWS instance.

Go back to the root directory of this app, containing this README.md file, and execute the install script, or run `ansible-playbook main.yml` from command line.  

This calls a playbook which refers to the `/terraform_aws` directory.
Runs the Terraform `main.tf` 
This script eventually sets up ansible folder to upload the ansible file (vault.yml) to the newly created remote server using the `ubuntu` ssh keys.
The remote server then follows the playbook that was uploaded, and installs the vault instance.

*********IMPORTANT NOTICE**************
Please consult the vault documentation on how to configure and start your vault server.
https://www.vaultproject.io/docs

Additionally, you can follow the commands in the HASHIvaultDBdemo.txt file for a complete walkthrough of HASHI Vault Transit, Encryption-as-a-Service + Dynamic DB Secrets.

