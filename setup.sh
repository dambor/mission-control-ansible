#!/bin/bash
# Quick setup script for DataStax Mission Control installation

set -e

echo "=========================================="
echo "DataStax Mission Control - Setup"
echo "=========================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v oc &> /dev/null; then
    echo "❌ OpenShift CLI (oc) not found"
    echo "   Install from: https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html"
    exit 1
fi
echo "✓ OpenShift CLI found"

if ! command -v helm &> /dev/null; then
    echo "❌ Helm not found"
    echo "   Install from: https://helm.sh/docs/intro/install/"
    exit 1
fi
echo "✓ Helm found"

if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible not found"
    echo "   Install with: pip install ansible"
    exit 1
fi
echo "✓ Ansible found"

if ! command -v htpasswd &> /dev/null; then
    echo "⚠ htpasswd not found (needed for password hashing)"
    echo "   Install apache2-utils (Debian/Ubuntu) or httpd-tools (RHEL/CentOS)"
fi

echo ""
echo "Installing Ansible collections..."
ansible-galaxy collection install kubernetes.core community.general

echo ""
echo "Installing Python packages..."
pip install kubernetes openshift --quiet

echo ""
echo "Creating directories..."
mkdir -p files

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Download DataStax bundle to files/ directory"
echo "2. Edit vars.yml with your settings"
echo "3. Run: ansible-playbook install.yml"
echo ""
