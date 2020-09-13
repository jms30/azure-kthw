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
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Waterloo",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Ontario"
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
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Waterloo",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Ontario"
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

EXTERNAL_IP=(52.138.19.72 52.237.12.227 40.85.228.40)

for instance in {1..3}; do
cat > worker-${instance}-csr.json <<EOF
{
  "CN": "system:node:worker-${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Waterloo",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Ontario"
    }
  ]
}
EOF



/usr/local/bin/cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=worker-${instance},${EXTERNAL_IP[${instance}-1]},10.0.0.2${instance} \
  -profile=kubernetes \
  worker-${instance}-csr.json | /usr/local/bin/cfssljson -bare worker-${instance}
done

#################################################################################################################


###################################### KUBE CONTROLLER MANAGER FILE ##############################################

cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Waterloo",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "Ontario"
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
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Waterloo",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Ontario"
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
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Waterloo",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "Ontario"
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

KUBERNETES_PUBLIC_ADDRESS=20.39.141.250

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Waterloo",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Ontario"
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
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Waterloo",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Ontario"
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
