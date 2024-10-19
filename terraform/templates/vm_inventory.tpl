all:
  vars:
    ansible_connection: ssh
    ansible_user: ${admin_username}
    ansible_ssh_private_key_file: ${ssh_private_key_file}
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
  children:
    vms:
      hosts:
        ${name}:
          ansible_host: ${ip}
          ansible_port: 22
          ansible_python_interpreter: /usr/bin/python
          local_private_ip: ${local_private_ip}
          local_public_ip: ${local_public_ip}
          local_subnet: ${local_subnet}
          remote_private_ip: ${remote_private_ip}
          remote_public_ip_tunel1: ${remote_public_ip_tunel1}
          remote_public_ip_tunel2: ${remote_public_ip_tunel2}
          remote_subnet: ${remote_subnet}
          phase_one_authentication_algorithm: ${phase_one_authentication_algorithm}
          phase_one_dh_group: ${phase_one_dh_group}
          phase_one_encryption_algorithm: ${phase_one_encryption_algorithm}
          phase_one_lifetime: ${phase_one_lifetime}
          phase_two_authentication_algorithm: ${phase_two_authentication_algorithm}
          phase_two_dh_group: ${phase_two_dh_group}
          phase_two_encryption_algorithm: ${phase_two_encryption_algorithm}
          phase_two_lifetime: ${phase_two_lifetime}
          phase_two_pfs_enabled: ${phase_two_pfs_enabled}
          ipsec_shared_secret: ${ipsec_shared_secret}



