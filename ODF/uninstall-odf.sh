export FUSION_NS="ibm-spectrum-fusion-ns"

oc scale deployment --replicas=0 isf-cns-operator-controller-manager -n "$FUSION_NS"

oc delete odfmanager odfmanager
oc delete odfcluster odfcluster -n "$FUSION_NS"

oc delete -n openshift-storage storagesystem --all --wait=true

#check to make sure cleanup has completed
oc get pods -n openshift-storage | grep -i cleanup

for i in $(oc get node -l cluster.ocs.openshift.io/openshift-storage= -o jsonpath='{ .items[*].metadata.name  }'); do oc debug node/${i} -- chroot /host  ls -l /var/lib/rook; done

# remove encryption
oc debug node/storage-{1-3}
chroot /host

dmsetup ls

cryptsetup luksClose --debug --verbose <OCS Device>

oc project default
oc delete project openshift-storage --wait=true --timeout=5m

export SC="ibm-spectrum-fusion-local"

oc -n openshift-local-storage delete localvolumesets.local.storage.openshift.io ibm-spectrum-fusion-local

oc get pv | grep $SC | awk '{print $1}'| xargs oc delete pv

oc delete sc $SC

[[ ! -z $SC ]] && for i in $(oc get node -l cluster.ocs.openshift.io/openshift-storage= -o jsonpath='{ .items[*].metadata.name }'); do oc debug node/${i} -- chroot /host rm -rfv /mnt/local-storage/${SC}/; done

oc delete localvolumediscovery.local.storage.openshift.io/auto-discover-devices -n openshift-local-storage

oc project default
oc delete project openshift-local-storage --wait=true --timeout=5m

oc label nodes  --all cluster.ocs.openshift.io/openshift-storage-
oc label nodes  --all topology.rook.io/rack-

oc adm taint nodes --all node.ocs.openshift.io/storage-

oc delete storageclass openshift-storage.noobaa.io --wait=true --timeout=5m

oc delete crd backingstores.noobaa.io bucketclasses.noobaa.io cephblockpools.ceph.rook.io cephclusters.ceph.rook.io cephfilesystems.ceph.rook.io cephnfses.ceph.rook.io cephobjectstores.ceph.rook.io cephobjectstoreusers.ceph.rook.io noobaas.noobaa.io ocsinitializations.ocs.openshift.io storageclusters.ocs.openshift.io cephclients.ceph.rook.io cephobjectrealms.ceph.rook.io cephobjectzonegroups.ceph.rook.io cephobjectzones.ceph.rook.io cephrbdmirrors.ceph.rook.io storagesystems.odf.openshift.io cephblockpoolradosnamespaces.ceph.rook.io cephbucketnotifications.ceph.rook.io cephbuckettopics.ceph.rook.io cephcosidrivers.ceph.rook.io cephfilesystemmirrors.ceph.rook.io cephfilesystemsubvolumegroups.ceph.rook.io csiaddonsnodes.csiaddons.openshift.io networkfences.csiaddons.openshift.io reclaimspacecronjobs.csiaddons.openshift.io reclaimspacejobs.csiaddons.openshift.io storageclassrequests.ocs.openshift.io storageconsumers.ocs.openshift.io storageprofiles.ocs.openshift.io volumereplicationclasses.replication.storage.openshift.io volumereplications.replication.storage.openshift.io --wait=true --timeout=5m
