#!/bin/bash

awx project create \
    --name awx-example-project \
    --organization Default \
    --scm_type git \
    --scm_url https://github.com/jaybanuan/awx-example.git \
    --wait

awx inventory create \
    --name web-server-inventory \
    --organization Default

awx inventory_source create \
    --name web-server-inventory-source \
    --inventory web-server-inventory \
    --source scm \
    --source_project awx-example-project \
    --source_path inventories/web-server.yml

awx inventory_source update \
    --wait \
    web-server-inventory-source

awx credential create \
    --name web-server-credential \
    --organization Default \
    --credential_type Machine \
    --inputs '{"password": "root", "username": "root"}'

awx job_template create \
    --name web-server-job-template \
    --job_type run \
    --inventory web-server-inventory \
    --project awx-example-project \
    --playbook playbooks/web_server.yml

awx job_template associate \
    --credential web-server-credential \
    web-server-job-template
