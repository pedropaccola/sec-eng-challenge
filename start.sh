#!/bin/bash

usage() {
    {
    echo "NAME"
    echo -e "\t$(basename ${0}) - run application locally"
    echo
    echo "SYNOPSYS"
    echo -e "\t$(basename ${0}) OPTIONS..."
    echo 
    echo "OPTIONS"
    echo -e "\t -l: execute locally"
    echo -e "\t -d: build and run docker image locally"
    echo -e "\t -m: start minikube and deploy the application"
    echo -e "\t -r: remove docker/minikube resources"
    echo -e "\t -k: remove minikube kubernetes image"
    echo
    }
}

if [[ "${#}" -lt 1 ]]
then
    usage
    exit 1
fi

while getopts ldrmkh OPTION
do
  case ${OPTION} in
    l) LOCALLY='true' ;;
    d) DOCKERIZED='true';;
    r) DOCKER_REMOVE='true' ;;
    m) MINIKUBERIZED='true' ;;
    k) KUBERNETIMAGE='true' ;;
    h) HELP='true' ;;
    ?) usage ;;
  esac
done

shift "$(( OPTIND -1 ))"

if [[ "${HELP}" = 'true' ]]
then
  usage
  exit 0
fi

if [[ "${LOCALLY}" = 'true' ]]
then
  npm start
  exit 0
fi

if [[ "${DOCKERIZED}" = 'true' ]]
then
  docker rmi -f rmi pedropaccola/sec-eng-challenge:1.0 &> /dev/null
  docker build -f ./Dockerfile -t pedropaccola/sec-eng-challenge:1.0 .
  docker run --name eng-challenge -p 3000:3000 -d pedropaccola/sec-eng-challenge 1> /dev/null
  if [[ "${?}" -eq 0 ]]
  then
    echo "Container is running"
  fi
  exit 0
fi

if [[ "${DOCKER_REMOVE}" = 'true' ]]
then
  docker stop sec-eng-challenge 2> /dev/null
  kubectl delete service node-service.yaml 2> /dev/null
  kubectl delete deployment node-deployment.yaml 2> /dev/null
  kubectl delete ingress node-ingress.yaml 2> /dev/null
  minikube stop 2> /dev/null
  docker rm sec-eng-challenge
  docker rmi -f pedropaccola/sec-eng-challenge:1.0
  exit 0
fi

if [[ "${MINIKUBERIZED}" = 'true' ]]
then
  docker rmi -f pedropaccola/sec-eng-challenge &> /dev/null
  docker build -f ./Dockerfile -t pedropaccola/sec-eng-challenge:1.0 .
  minikube start
  minikube addons enable ingress
  kubectl apply -f node-deployment.yaml -f node-service.yaml -f node-ingress.yaml
  sleep 10
  #minikube service sec-eng-challenge-service
  exit 0
fi

if [[ "${KUBERNETIMAGE}" = 'true' ]]
then
  docker rmi -f gcr.io/k8s-minikube/kicbase &> /dev/null
  exit 0
fi
