# Introduction To Terraform And Packer

## Packer

* Hashicorp tool to create machine images (Amazon Machine Images [AMI] in this context), that can be spun up with all the relevant programs and configurations installed
		* Used an Ansible script to provision within the Packer file (in json format)
* It works by spinning up an instance (EC2 in this context), running the Ansible playbook, create an image from this and then delete the instance that was previously created

## Terraform

## TODO
- [*] Explain what packer is and used for
- [ ] Explain the `app_packer.json` file
- [ ] Explanation of what terraform is and used for
	- [ ] Compare with Ansible
- [ ] Create a Terraform file to spin up EC2 instances
	- [ ] Iterate by putting up both EC2 instances (for DB and App)
