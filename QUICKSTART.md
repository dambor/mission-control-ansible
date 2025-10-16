# Quick Start - 3 Steps

## Step 1: Setup (2 minutes)

```bash
./setup.sh
```

## Step 2: Configure (3 minutes)

Download bundle to `files/` directory, then edit variables:

```bash
vi vars.yml
```

Update these required fields:
- `user_email` - Your admin email
- `admin_password` - Your admin password  
- `ibm_registry_secret` - JWT token from IBM

## Step 3: Install (10 minutes)

```bash
ansible-playbook install.yml
```

Done! The playbook will display your Mission Control URL at the end.

## Access Mission Control

```bash
# Get URL
oc get route mission-control-mission-control-embedded-ui -n cpd-operators -o jsonpath='{.spec.host}'

# Open in browser
https://<route-hostname>
```

Login with your configured email and password.

## Troubleshooting

### Check installation
```bash
# Check pods
oc get pods -n cpd-operators -l app.kubernetes.io/instance=mission-control

# View logs
oc logs -n cpd-operators -l app.kubernetes.io/instance=mission-control --tail=50
```

### Common issues

**Bundle not found**: Place the `.tar.gz` file in `files/` directory

**OpenShift not connected**: Run `oc login` first

**Pods not starting**: Check logs with command above

## That's It!

This simple installer just installs Mission Control - no other lifecycle operations included.
