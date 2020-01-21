#!/bin/bash
mkdir /mnt/efs
service sshd start
yum install -y amazon-efs-utils
mount -t efs ${efs_id}:/ /mnt/efs
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
mount -l
touch /mnt/efs/${timestamp()}
