#!/usr/bin/env bash

####################################### CONFIGURATION PARAMETERS #######################################

COUNTRY_CODE="CA"
LOCATION="Waterloo"
ORG="CA"
ORG_UNIT="Kubernetes The Hard Way"
STATE="Ontario"
KEY_ALGO="rsa"
KEY_SIZE=2048
WORKER_EXTERNAL_IP=(8.8.8.8)                ####### PROVIDE YOUR WORKER'S EXTERNAL IP HERE.
KUBERNETES_PUBLIC_ADDRESS=8.8.8.8           ####### PROVIDE YOUR AZURE LOAD BALANCER (SITTING IN FRONT OF CONTROLLERS) IP ADDRESS

#####################################################  KUBERNETES CA   #############################################

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "${KEY_ALGO}",
    "size": ${KEY_SIZE}
  },
  "names": [
    {
      "C": "${COUNTRY_CODE}",
      "L": "${LOCATION}",
      "O": "Kubernetes",
      "OU": "${ORG}",
      "ST": "${STATE}"
    }
  ]
}
EOF

/usr/local/bin/cfssl gencert -initca ca-csr.json | /usr/local/bin/cfssljson -bare ca


#################################################################################################################


############################################## ADMIN FILE ####################################################

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "${KEY_ALGO}",
    "size": ${KEY_SIZE}
  },
  "names": [
    {
      "C": "${COUNTRY_CODE}",
      "L": "${LOCATION}",
      "O": "system:masters",
      "OU": "${ORG_UNIT}",
      "ST": "${STATE}"
    }
  ]
}
EOF

/usr/local/bin/cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | /usr/local/bin/cfssljson -bare admin


#################################################################################################################


##################################################  WORKER INSTANCES #################################################

for instance in {1..3}; do
cat > worker-${instance}-csr.json <<EOF
{
  "CN": "system:node:worker-${instance}",
  "key": {
    "algo": "${KEY_ALGO}",
    "size": ${KEY_SIZE}
  },
  "names": [
    {
      "C": "${COUNTRY_CODE}",
      "L": "${LOCATION}",
      "O": "system:nodes",
      "OU": "${ORG_UNIT}",
      "ST": "${STATE}"
    }
  ]
}
EOF

/usr/local/bin/cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=worker-${instance},${WORKER_EXTERNAL_IP[${instance}-1]},10.0.0.2${instance} \
  -profile=kubernetes \
  worker-${instance}-csr.json | /usr/local/bin/cfssljson -bare worker-${instance}
done


#################################################################################################################


###################################### KUBE CONTROLLER MANAGER FILE ##############################################

cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "${KEY_ALGO}",
    "size": ${KEY_SIZE}
  },
  "names": [
    {
      "C": "${COUNTRY_CODE}",
      "L": "${LOCATION}",
      "O": "system:kube-controller-manager",
      "OU": "${ORG_UNIT}",
      "ST": "${STATE}"
    }
  ]
}
EOF

/usr/local/bin/cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | /usr/local/bin/cfssljson -bare kube-controller-manager


#################################################################################################################


############################################### KUBE PROXY FILE   ##########################################

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "${KEY_ALGO}",
    "size": ${KEY_SIZE}
  },
  "names": [
    {
      "C": "${COUNTRY_CODE}",
      "L": "${LOCATION}",
      "O": "system:node-proxier",
      "OU": "${ORG_UNIT}",
      "ST": "${STATE}"
    }
  ]
}
EOF

/usr/local/bin/cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | /usr/local/bin/cfssljson -bare kube-proxy


#################################################################################################################


##########################################  KUBE SCHEDULER FILE #################################################

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "${KEY_ALGO}",
    "size": ${KEY_SIZE}
  },
  "names": [
    {
      "C": "${COUNTRY_CODE}",
      "L": "${LOCATION}",
      "O": "system:kube-scheduler",
      "OU": "${ORG_UNIT}",
      "ST": "${STATE}"
    }
  ]
}
EOF

/usr/local/bin/cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | /usr/local/bin/cfssljson -bare kube-scheduler


#################################################################################################################



############################################# API SERVER FILE  ##############################################

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "${KEY_ALGO}",
    "size": ${KEY_SIZE}
  },
  "names": [
    {
      "C": "${COUNTRY_CODE}",
      "L": "${LOCATION}",
      "O": "Kubernetes",
      "OU": "${ORG_UNIT}",
      "ST": "${STATE}"
    }
  ]
}
EOF

/usr/local/bin/cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.0.0.11,10.0.0.12,10.0.0.13,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | /usr/local/bin/cfssljson -bare kubernetes


#################################################################################################################



############################################## SERVICE ACCOUNT FILE ############################################

cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "${KEY_ALGO}",
    "size": ${KEY_SIZE}
  },
  "names": [
    {
      "C": "${COUNTRY_CODE}",
      "L": "${LOCATION}",
      "O": "Kubernetes",
      "OU": "${ORG_UNIT}",
      "ST": "${STATE}"
    }
  ]
}
EOF

/usr/local/bin/cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | /usr/local/bin/cfssljson -bare service-account


#################################################################################################################
