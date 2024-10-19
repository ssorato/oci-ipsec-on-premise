
# OCI IpSec on-premise

Connect OCI with on-premise ( an Azure VM ) using IpSec VPN

[Example: Setting Up a Proof of Concept Site-to-Site VPN](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/settingupIPsec.htm#example_poc)

[CPE Configuration](https://docs.oracle.com/en-us/iaas/Content/Network/Reference/libreswanCPE.htm#config)

## Terraform

```bash
$ export TF_VAR_tenancy_ocid="<tenancy ocid>"
$ export TF_VAR_user_ocid="<user ocid>"
$ export TF_VAR_oci_private_key_path="<user ssh private key>"
$ export TF_VAR_oci_key_fingerprint="<user ssh private key fingerprint>"
$ export TF_VAR_oci_compartment_ocid = "<OCI compartment id>"

$ export ARM_CLIENT_ID="<azure service principal client id>"
$ export ARM_CLIENT_SECRET="<azure service principal client id>"
$ export ARM_SUBSCRIPTION_ID="<azure subscription id>"
$ export ARM_TENANT_ID="<azure tenant id>"

$ export TF_VAR_ipsec_shared_secret  = "<IpSec shared secret>"

$ cd terraform
$ terraform init
$ terraform validate
$ terraform plan
$ terraform apply
$ cd ..
```

## Ansible

```bash
$ cd ansible
$ ansible-playbook -i ansible/inventories main.yaml
$ cd ..
```

## Cleanup

```bash
$ cd terraform
$ terraform destroy
$ cd ..
```

## TODO

How to map OCI VPN config parameters to Libreswan VPN config parameters ? `AES_256_CBC` to `aes_cbc256-sha2_256` 
