#!/bin/bash
# 1. login
cpd-cli manage login-to-ocp \
--username=${OCP_USERNAME} \
--password=${OCP_PASSWORD} \
--server=${OCP_URL}

# 2. Install Cert and Licenses
cpd-cli manage apply-cluster-components \
--release=${VERSION} \
--license_acceptance=true \
--cert_manager_ns=${PROJECT_CERT_MANAGER} \
--licensing_ns=${PROJECT_LICENSE_SERVICE}

# 3. Optional: Install the scheduling service. 
cpd-cli manage apply-scheduler \
--release=${VERSION} \
--license_acceptance=true \
--scheduler_ns=${PROJECT_SCHEDULING_SERVICE}

# 4. Run the cpd-cli manage authorize-instance-topology command to apply the required permissions to the projects.
cpd-cli manage authorize-instance-topology \
--cpd_operator_ns=${PROJECT_CPD_INST_OPERATORS} \
--cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS}

# 5. Run the cpd-cli manage setup-instance-topology command to install IBM Cloud Pak foundational services and create the ConfigMap.
cpd-cli manage setup-instance-topology \
--release=${VERSION} \
--block_storage_class=ocs-storagecluster-ceph-rbd \
--cpd_operator_ns=${PROJECT_CPD_INST_OPERATORS} \
--cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS} \
--license_acceptance=true

# 6. set components to be installed
export COMPONENTS=cpd_platform,watsonx_data

# 7. Install Cloud Pak for data platform operator and service operator
cpd-cli manage apply-olm \
--release=${VERSION} \
--cpd_operator_ns=${PROJECT_CPD_INST_OPERATORS} \
--components=${COMPONENTS}

# 8. Install the operands in the operands project for the instance.
cpd-cli manage apply-cr \
--release=${VERSION} \
--cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS} \
--components=${COMPONENTS} \
--block_storage_class=${STG_CLASS_BLOCK} \
--file_storage_class=${STG_CLASS_FILE} \
--license_acceptance=true

# 9. Apply the entitlement for watsonx.data on Red Hat OpenShift.
cpd-cli manage apply-entitlement \
--cpd_instance_ns=cpd-inst-operands \
--entitlement=watsonx-data \
--production=true \
--preview=false
