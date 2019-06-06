delete_elk_kube_resources() {
    kubectl delete namespace safeboda-logging
}

delete_python_application_kube_resources() {
    kubectl delete namespace python-app
}

main() {
    echo "cleaning up namespaces and all related resources"

    delete_elk_kube_resources
    delete_python_application_kube_resources

    echo "feel free to run 'minikube delete' to ensure to delete this cluster if you don't need it"
    
}

main "$@"
