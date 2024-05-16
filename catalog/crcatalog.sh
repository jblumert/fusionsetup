#!/bin/bash

oc apply -f catalog_source.yaml -n openshift-marketplace

oc get CatalogSources ibm-operator-catalog -n openshift-marketplace
