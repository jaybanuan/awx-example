#!/bin/bash

ORGANIZATION_ID=$(awx organization get -f jq --filter '.id' Default)

awx project create \
    --name awx-example-project \
    --organization "${ORGANIZATION_ID}" \
    --scm_type git \
    --scm_url https://github.com/jaybanuan/awx-example.git \
    --wait \
    --monitor

awx inventory create \
    --name web-server-inventory \
    --organization "${ORGANIZATION_ID}"

awx inventory_source create \
    --name web-server-inventory-source \
    --inventory $(awx inventory get -f jq --filter '.id' web-server-inventory) \
    --source scm \
    --source_project $(awx project get -f jq --filter '.id' awx-example-project) \
    --source_path inventories/web-server.yml

awx inventory_source update \
    --wait \
    --monitor \
    web-server-inventory-source

awx credential create \
    --name web-server-credential \
    --credential_type Machine \
    --organization "${ORGANIZATION_ID}" \
    --inputs '{"password": "root", "username": "root"}'

awx job_template create \
    --name web-server-job-template \
    --job_type run \
    --inventory $(awx inventory get -f jq --filter '.id' web-server-inventory) \
    --project $(awx project get -f jq --filter '.id' awx-example-project) \
    --playbook playbooks/web_server.yml

awx job_template associate \
    --credential web-server-credential \
    $(awx job_template get -f jq --filter '.id' web-server-job-template)
