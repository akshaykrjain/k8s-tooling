# Copy Objects from one k8s cluster to another

This script can help bulk moving k8s resources from one cluster to another cluster.

how to use - 

`bash script.sh source_cluster_name destination_cluster_name namespace object_type dry-run-type`

e.g.

`bash script.sh dev_cluster staging_cluster backend configmap none`

