#!/bin/bash
source_cluster=$1
destination_cluster=$2
namespace=$3
object_type=$4
dry_run=$5
kubectl config use-context "$source_cluster" >/dev/null
for object in $(kubectl get --no-headers=true "$object_type" -o name -n "$namespace" | awk -F "/" '{print $2}')
do
while true; do
    read -r -p "Do you wish to copy ""$object_type"" -  ""$object"" in namespace ""$namespace"" ? " yn
    case $yn in
        [Yy]* ) 
            kubectl config use-context "$source_cluster" >/dev/null
            kubectl get "$object_type" "$object" -n  "$namespace" -o yaml > /tmp/kube_copy_"$object_type"_"$object"_"$namespace".yaml 
            kubectl config use-context "$destination_cluster" >/dev/null
            validate=$(kubectl apply -f /tmp/kube_copy_"$object_type"_"$object"_"$namespace".yaml  -n "$namespace" --dry-run=server 2>&1 >/dev/null)
            if echo "$validate" | ggrep -q "NotFound"; then
                echo "namespace doesn't exist in destination. creating it now."
                kubectl create namespace "$namespace"
            fi
            echo "creating $object_type $object in $namespace"

            if ! kubectl get "$object_type" "$object" -n "$namespace" --no-headers=true 2>/dev/null ; then
            kubectl apply -f /tmp/kube_copy_"$object_type"_"$object"_"$namespace".yaml   -n "$namespace" --dry-run="$dry_run"
            else
            read -r -p "$object_type $object in $namespace already exists in target cluster, do you want to recreate ? " yn
            case $yn in
            [Yy]* ) 
                kubectl config use-context "$source_cluster" >/dev/null
                kubectl apply -f /tmp/kube_copy_"$object_type"_"$object"_"$namespace".yaml   -n "$namespace" --dry-run="$dry_run"
                break;;
            [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
            esac
            fi
            kubectl apply -f /tmp/kube_copy_"$object_type"_"$object"_"$namespace".yaml   -n "$namespace" --dry-run="$dry_run"
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
done
exit
