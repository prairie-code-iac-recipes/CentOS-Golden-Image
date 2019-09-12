# CentOS Golden Image
## Purpose
The purpose of this project is to create a common CentOS image and publish it to both AWS and vSphere.

## Branching Model
### Overview
Basic building blocks like this project can follow a simple branching model since they produce intermediate deliverables that will serve as ingredients for more complex projects.  The only caveat to this is that they MUST support versioning and be careful NOT to DESTROY resources that dependent projects are already utilizing.
### Detail
1. Modifications are made to feature branches created from the master branch.
2. Feature branches are merged directly into master via pull-request.
3. Master will build a new image and publish it to both AWS and vSphere.

## Pipeline
### All Branches
1. The centos.json Packer file will be validated whenever any branch is updated.
### Master Branch
1. The CentOS kickstart template is updated with variable-driven username, password, and role information.
2. A Docker container running NGINX is launched to serve-up the resulting CentOS kickstart file with the dynamically-assigned container ID and port captured for later use.
3. An environment variable is set for the HTTP port assigned to the Docker container hosting the CentOS kickstart file.
4. The SSH public key to be assigned to the image is pulled from a CI/CD variable, decoded, and written to a temporary file.
5. An environment variable pointing to the temporary file containing the SSH public key is set.
6. A Packer Build is run for the centos.json.
7. Once completed, the aforementioned container ID is used to stop the Docker container hosting the CentOS kickstart file.

## Packer
## Inputs
| Variable | Description |
| -------- | ----------- |
| AWS_ACCESS_KEY | The access key used by the Amazon Import post processor to communicate with AWS. |
| AWS_BUCKET | The name of the S3 bucket where the OVA file will be copied to by the Amazon Import post processor for import. This bucket must exist when the post-processor is run. |
| AWS_REGION | The name of the region in which the Amazon Import post processor is to upload the OVA file to S3 and create the AMI. |
| AWS_SECRET_KEY | The secret key used by the Amazon Import post processor to communicate with AWS. |
| DVS_PORT_GROUP_ID | The vSphere-assigned unique identifier for the virtual switch port that the virtual machine will be connected during the build process. |
| DVS_SWITCH_ID | The vSphere-assigned unique identifier for the virtual switch that the virtual machine will be connected during the build process. |
| ESX_DATASTORE | The path to the vSphere datastore where the resulting VM will be stored when it is built on the remote machine. |
| ESX_HOST | The name of the remote ESX host where the virtual machine will be built. |
| ESX_PASSWORD | The password for the SSH user that will access the remote ESX host during build and provisioning. |
| ESX_USERNAME | The username for the SSH user that will access the remote ESX host during build and provisioning. |
| HTTP_IP | This is the IP address of the HTTP server that is serving the kickstart file required by CentOS. |
| HTTP_PORT | This is the port of the HTTP server that is serving the kickstart file required by CentOS. |
| ISO_CHECKSUM | This is used by Packer to validate the CentOS ISO downloaded from the specified ISO_URL. |
| ISO_CHECKSUM_TYPE | This is used by Packer to validate the CentOS ISO downloaded from the specified ISO_URL. |
| ISO_URL | Packer will attempt to download the CentOS ISO from the location specified by this variable. |
| TEMPLATE_CPU_COUNT | The number of cpus to use when building the VM. |
| TEMPLATE_DESCRIPTION | The description used by the Amazon Import post processor to set for the resulting imported AMI. |
| TEMPLATE_DISK_KB | The size of the hard disk for the VM in megabytes. The builder uses expandable, not fixed-size virtual hard disks, so the actual file representing the disk will not use the full size unless it is full. |
| TEMPLATE_MEMORY_KB | The amount of memory to use when building the VM in megabytes. |
| TEMPLATE_NAME | This is the name of the VMX file for the new virtual machine, without the file extension. It is also uses as the name of the ami within the AWS console.|
| TEMPLATE_PASSWORD | A plaintext password to use to authenticate to the new virtual machine with SSH. |
| TEMPLATE_PUBLIC_KEY_FILE | Path to the SSH public key file to be copied to ~/.ssh/authorized_keys file in the new virtual machine for the user specified by the TEMPLATE_USERNAME variable. |
| TEMPLATE_USERNAME | The username to connect to SSH with. |
| TEMPLATE_USERGROUP | A new primary group to be created for the user specified by the TEMPLATE_USERNAME variable. |
| VCENTER_DATACENTER | The vSphere Datacenter where the new virtual machine was provisioned. This is used by the vSphere Template post processor. |
| VCENTER_HOST | The name of the vCenter host where the new virtual machine was provisioned. This is used by the vSphere Template post processor. |
| VCENTER_PASSWORD | Password to use to authenticate to the vSphere endpoint. |
| VCENTER_USERNAME | The username to use to authenticate to the vSphere endpoint. |

## Processing
1. Packer downloads and validates the specified CentOS ISO.
2. Packer uploads the validated CentOS ISO to the specified remote ESX host.
3. Packer launches a new virtual machine on the specified remote ESX host and mounts the aforementioned ISO.
4. Packer sends the key sequence required for CentOS to perform initial setup using the kickstart file hosted on the previously-launched Docker container.
5. Packer runs a shell provisioner to update the CA certificates on the image.
6. Packer runs a shell provisioner to install VM tools.
7. Packer runs a shell provisioner to lock-down the root user and disable SSH via password.
8. Packer runs a post processor to tag the image as a vSphere template.
9. Packer runs a post processor to upload the image to AWS FOR AMI conversion.

*Note: Under the hood, Packer's vmware-iso builder uses SSH and the command line to connect to VMWare to build and customize virtual machines. In the future they plan to change the builder to use the vSphere API instead.  The vSphere Template post processor already does this, which is why is requires the vCenter host name.

## Outputs
Not Applicable
