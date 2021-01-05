# Introduction To Terraform And Packer

## Packer

* Hashicorp tool to create machine images (Amazon Machine Images [AMI] in this context), that can be spun up with all the relevant programs and configurations installed
		* Used an Ansible script to provision within the Packer file (in json format)
* It works by spinning up an instance (EC2 in this context), running the Ansible playbook, create an image from this and then delete the instance that was previously created

### Security

* One usually doesn't want to put the AWS access and secret keys within the packer file, as this is not particularly secure. What one can do instead is export them to bash environment variables by doing the following commands:
```
echo "export AWS_ACCESS_KEY=<key_here>" > ~/.bashrc
echo "export AWS_SECRET_KEY=<key_here>" > ~/.bashrc
source ~/.bashrc
```
* The `env` part within the following lines within the `app_packer.json` file make it read from the bash environment variables:
```
		      "aws_access_key": "{{ env `AWS_ACCESS_KEY` }}",
		      "aws_secret_key": "{{ env `AWS_SECRET_KEY` }}"
```

## Terraform

* Can take the AMI (using AWS access and secret keys) and create an EC2 etc from this

## TODO
- [x] Explain what packer is and used for
- [x] Explain AWS_ACCESS_KEY and AWS_SECRET_KEY in bash environment variables, instead of in the file
- [ ] Explain the `app_packer.json` file
- [ ] Explanation of what terraform is and used for
	- [ ] Compare with Ansible
- [ ] Create a Terraform file to spin up EC2 instances
	- [ ] Iterate by putting up both EC2 instances (for DB and App)
