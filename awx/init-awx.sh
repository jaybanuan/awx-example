#!/bin/bash

ORGANIZATION_NAME=Default
ORGANIZATION_ID=$(awx organization get -f jq --filter '.id' "${ORGANIZATION_NAME}")


create_project() {
    local PROJECT_NAME=$1
    local SCM_URL=$2

    awx project create \
        --wait \
        --monitor \
        --name "${PROJECT_NAME}" \
        --scm_type git \
        --scm_url "${SCM_URL}"
}


create_inventory() {
    local INVENTORY_NAME=$1

    awx inventory create \
        --name "${INVENTORY_NAME}" \
        --organization "${ORGANIZATION_ID}"
}


create_inventory_source() {
    local INVENTORY_SOURCE_NAME="$1"
    local INVENTORY_ID=$(awx inventory get -f jq --filter '.id' "$2")
    local PROJECT_ID=$(awx project get -f jq --filter '.id' "$3")
    local SOURCE_PATH="$4"

    awx inventory_source create \
        --name "${INVENTORY_SOURCE_NAME}" \
        --inventory "${INVENTORY_ID}" \
        --source scm \
        --source_project "${PROJECT_ID}" \
        --source_path "${SOURCE_PATH}"
}


update_inventory_source() {
    local INVENTORY_SOURCE_NAME="$1"

    awx inventory_source update \
        --wait \
        --monitor \
        "${INVENTORY_SOURCE_NAME}"
}


create_credential() {
    local NAME="$1"
    local CREDENTIAL_TYPE="$2"
    local INPUTS="$3"

    awx credential create \
        --name "${NAME}" \
        --credential_type "${CREDENTIAL_TYPE}" \
        --organization "${ORGANIZATION_ID}" \
        --inputs "${INPUTS}"
}


create_job_template() {
    local NAME="$1"
    local INVENTORY_ID=$(awx inventory get -f jq --filter '.id' "$2")
    local PROJECT_ID=$(awx project get -f jq --filter '.id' "$3")
    local PLAYBOOK="$4"

    awx job_template create \
        --name "${NAME}" \
        --job_type run \
        --inventory "${INVENTORY_ID}" \
        --project "${PROJECT_ID}" \
        --playbook "${PLAYBOOK}"
}

associate_job_template() {
    local JOB_TEMPLATE_ID=$(awx job_template get -f jq --filter '.id' "$1")
    local CREDENTIAL="$2"

    awx job_template associate \
        --credential "${CREDENTIAL}" \
        "${JOB_TEMPLATE_ID}"
}


test -n "${CONTROLLER_HOST}" || {
    echo "CONTROLLER_HOST must be specified." >&2
    exit 1
}


test -n "${CONTROLLER_OAUTH_TOKEN}" || {
    echo "CONTROLLER_OAUTH_TOKEN must be specified." >&2
    exit 1
}


create_project awx-example-project https://github.com/jaybanuan/awx-example.git
create_inventory web-server-inventory
create_inventory_source web-server-inventory-source web-server-inventory awx-example-project inventories/web-server.yml
update_inventory_source web-server-inventory-source
create_credential web-server-credential Machine '{"password": "root", "username": "root"}'
create_job_template web-server-job-template web-server-inventory awx-example-project playbooks/web_server.yml
associate_job_template web-server-job-template web-server-credential