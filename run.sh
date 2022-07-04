#!/bin/bash

ANSIBLE_HOST_PATTERN_MISMATCH=error ansible-playbook -i hosts project/playbook.yml
