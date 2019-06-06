#!/bin/bash

set -ex
set -o pipefail
set +o xtrace

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m'

check_needed_applications_are_installed() {

    if ! command -v docker > /dev/null; then
        printf "💀${RED}   You must install docker on your system before setup can continue$ ${NO_COLOR} \n"
        printf "ℹ️   On macOS🍎 you can 'brew cask install docker'\n"
        exit -1
    fi

    if ! command -v kubectl > /dev/null; then
        printf "💀${RED}   You must install kubectl on your system before setup can continue$ ${NO_COLOR} \n"
        printf "ℹ️   On macOS🍎 you can 'brew install kubectl'\n"
        exit -1
    fi

    if ! command -v minikube > /dev/null; then
        printf "💀${RED}   You must install minikube on your system before setup can continue$ ${NO_COLOR} \n"
        printf "On macOS🍎 you can 'rm $(which minikube) && curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.1.0/minikube-darwin-amd64 && chmod +x minikube && cp minikube /usr/local/bin/'\n"
        printf "️️minikube uses virtualbox for virtualization, if you haven't set it up to use other virtualization software, you'll need to install it"
        printf "you can install vbox here 'https://www.virtualbox.org/wiki/Downloads'"
        exit -1
    fi

}

start_minikube() {
    minikube start;
}

start_python_application() {
    PARENT_DIRECTORY="kube-definitions/python-app/"

    printf "🐍 ${GREEN} creating the python application! ${NO_COLOR} \n"
    printf "${GREEN} its namespace...! ${NO_COLOR} \n"
    if ! kubectl get namespace python-app; then
      kubectl create -f "${PARENT_DIRECTORY}namespace.yml"
    fi

    printf "${GREEN} its service... ${NO_COLOR} \n"
    if ! kubectl get svc safeboda --namespace=python-app; then
      kubectl create -f "${PARENT_DIRECTORY}service.yml"
    fi

    printf "${GREEN} and finally its deployment... ${NO_COLOR} \n"
    if ! kubectl get deploy safeboda --namespace=python-app; then
      kubectl create -f "${PARENT_DIRECTORY}deployment.yml"
    fi

}

create_logging_namespace() {
    PARENT_DIRECTORY="kube-definitions/elk/"

    printf "${GREEN} its namespace... ${NO_COLOR} \n"
    if ! kubectl get namespace safeboda-logging; then
      kubectl create -f "${PARENT_DIRECTORY}namespace.yml"
    fi
}

create_elasticsearch_kube_resources() {

    PARENT_DIRECTORY="kube-definitions/elk/elastic-search/"
    
    printf "${GREEN} its elasticsearch service... ${NO_COLOR} \n"
    if ! kubectl get svc elasticsearch --namespace=safeboda-logging; then
      kubectl create -f "${PARENT_DIRECTORY}service.yml"
    fi

    printf "${GREEN} its elasticsearch deployment... ${NO_COLOR} \n"
    if ! kubectl get deploy es-cluster --namespace=safeboda-logging; then
      kubectl create -f "${PARENT_DIRECTORY}deployment.yml"
    fi

}

create_kibana_kube_resources() {
    
    PARENT_DIRECTORY="kube-definitions/elk/kibana/"
    
    printf "${GREEN} its kibana service... ${NO_COLOR} \n"
    if ! kubectl get svc kibana --namespace=safeboda-logging; then
      kubectl create -f "${PARENT_DIRECTORY}service.yml"
    fi

    printf "${GREEN} its kibana deployment... ${NO_COLOR} \n"
    if ! kubectl get deploy kibana --namespace=safeboda-logging; then
      kubectl create -f "${PARENT_DIRECTORY}deployment.yml"
    fi

}

create_fluentd_kube_resources() {
    PARENT_DIRECTORY="kube-definitions/elk/fluentd/"

    printf "${GREEN} and finally the fluentd pods to relay logs to elasticsearch... ${NO_COLOR} \n"
    if ! kubectl get sa fluentd --namespace=python-app; then
      kubectl create -f "${PARENT_DIRECTORY}service_account.yml"
    fi

    if ! kubectl get clusterroles fluentd --namespace=python-app; then
      kubectl create -f "${PARENT_DIRECTORY}cluster_role.yml"
    fi

    if ! kubectl get clusterrolebindings fluentd --namespace=python-app; then
      kubectl create -f "${PARENT_DIRECTORY}cluster_role_binding.yml"
    fi
    
    if ! kubectl get ds fluentd --namespace=python-app; then
      kubectl create -f "${PARENT_DIRECTORY}daemon_set.yml"
    fi

}

create_logging_kube_resources() {

    printf "📊 ${GREEN} creating elk logging resources...! ${NO_COLOR} \n"

    create_logging_namespace
    create_elasticsearch_kube_resources
    create_kibana_kube_resources
    create_fluentd_kube_resources
}

user_prompt_to_see_services() {

    printf "\n"
    printf "\n"
    printf "🚀 🚀 🚀 🚀 ${GREEN} THE SERVICES APPEAR READY! ${NO_COLOR} 🚀 🚀 🚀 🚀 \n"
    printf "${GREEN} you will be able to access the kibana dashboard here. ${NO_COLOR} \n"
    printf "${GREEN} some manual setup of indexes is required but the barebones dash can be seen here ${NO_COLOR} \n"
    printf "💻 ${GREEN} http://$(kubectl get svc --namespace=safeboda-logging | grep kibana | awk '{print $3}'):5601 ${NO_COLOR}\n \n"

    printf "${GREEN} you will be able to access the kibana dashboard here. ${NO_COLOR} \n"
    printf "${GREEN} some manual setup of indexes is required but the barebones dash can be seen here ${NO_COLOR} \n"
    printf "💻 ${GREEN} http://$(kubectl get svc --namespace=python-app | grep safeboda | awk '{print $3}'):80 ${NO_COLOR}\n \n"

    printf "${YELLOW} please enter your password to allow minikube make the services available to you ${NO_COLOR} \n"
}

main() {
    echo "starting Asante's python application"

    check_needed_applications_are_installed
    start_minikube
    start_python_application
    create_logging_kube_resources
    user_prompt_to_see_services
    minikube tunnel

}

main "$@"