#!/bin/bash

#add user
groupadd -f sclc_ops
groupadd -f scyd_ops
groupadd -f wxzx_ops
cp -f /etc/sudoers /etc/sudoers.bak
grep -q "sclc_ops" /etc/sudoers || echo "%sclc_ops ALL=(ALL) ALL" >>/etc/sudoers
grep -q "scyd_ops" /etc/sudoers || echo "%scyd_ops ALL=(ALL) ALL" >>/etc/sudoers
grep -q "wxzx_ops" /etc/sudoers || echo "%wxzx_ops ALL=(ALL) ALL" >>/etc/sudoers

id pandongdong_cmsc08 && usermod -g sclc_ops pandongdong_cmsc08 || { useradd pandongdong_cmsc08 -g sclc_ops; echo "E58H-pR2l8]IxEYg" | passwd pandongdong_cmsc08 --stdin; }
