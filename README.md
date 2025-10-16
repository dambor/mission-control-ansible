# DataStax Mission Control - Simple Install

One Ansible playbook to install DataStax Mission Control on OpenShift.

## Quick Start

### 1. Prerequisites

- OpenShift CLI (`oc`) installed and logged in
- Helm 3+ installed
- `htpasswd` utility installed
- Ansible 2.9+ installed

### 2. Download DataStax Bundle

Download from:
- https://w3.ibm.com/w3publisher/software-downloads
- https://ibm.box.com/s/mwtcjzkf9qw72k2jjkx530zozmydb9cx

Place the file here:
```bash
# Create files directory
mkdir -p files

# Move downloaded bundle
mv ~/Downloads/mission-control-embedded-v1.14.0.tar.gz files/
```

### 3. Configure Variables

Edit `vars.yml` with your settings:

```bash
vi vars.yml
```

Required variables:
- `user_email` - Admin email
- `admin_password` - Admin password
- `ibm_registry_secret` - JWT token from IBM
- `datastax_bundle_file` - Bundle filename

### 4. Install

```bash
ansible-playbook install.yml
```

That's it! The playbook will:
- Create namespaces
- Configure Security Context Constraints
- Deploy Mission Control via Helm
- Setup RBAC for watsonx.data
- Create OpenShift route

### 5. Access Mission Control

Get your URL:
```bash
oc get route mission-control-mission-control-embedded-ui -n cpd-operators -o jsonpath='{.spec.host}'
```

Open in browser: `https://<route-hostname>`

Login with your configured email and password.

## Customization

Edit `vars.yml` to change:
- Namespace names
- DataStax version
- Working directory
- Resource limits

## Troubleshooting

### Check pods
```bash
oc get pods -n cpd-operators -l app.kubernetes.io/instance=mission-control
```

### View logs
```bash
oc logs -n cpd-operators -l app.kubernetes.io/instance=mission-control
```

### Check Helm release
```bash
helm list -n cpd-operators
```

## Requirements

Install Ansible collections:
```bash
ansible-galaxy collection install kubernetes.core community.general
```

Install Python packages:
```bash
pip install kubernetes openshift
```
