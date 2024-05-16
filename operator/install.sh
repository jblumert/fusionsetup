#!/bin/bash
oc apply -f operator.yaml
oc get operator isf-operator.ibm-spectrum-fusion-ns

oc apply -f  fusion_cr.yaml
