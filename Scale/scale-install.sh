export FUSION_NS="ibm-spectrum-fusion-ns"
oc -n ${FUSION_NS} patch spectrumfusion/spectrumfusion --type=merge --patch='{"spec":{"GlobalDataPlatform":{"Enable":true}}}'
