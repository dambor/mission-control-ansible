#!/bin/bash
# Quick investigation and fix for Mission Control pods

NAMESPACE="cpd-operators"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     DataStax Mission Control - Quick Fix                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Function to check pod
check_pod() {
    local POD=$1
    echo "Checking pod: $POD"
    
    STATUS=$(oc get pod $POD -n $NAMESPACE -o jsonpath='{.status.phase}' 2>/dev/null)
    echo "  Status: $STATUS"
    
    if [ "$STATUS" != "Running" ] && [ "$STATUS" != "Succeeded" ]; then
        echo "  🔍 Investigating..."
        
        # Check container status
        oc get pod $POD -n $NAMESPACE -o jsonpath='{range .status.containerStatuses[*]}  Container: {.name}{"\n"}  State: {.state}{"\n"}  Ready: {.ready}{"\n"}{end}' 2>/dev/null
        
        # Check for image pull issues
        IMAGE_PULL=$(oc get pod $POD -n $NAMESPACE -o jsonpath='{.status.containerStatuses[*].state.waiting.reason}' 2>/dev/null | grep -i "imagepull")
        if [ ! -z "$IMAGE_PULL" ]; then
            echo "  ❌ Image Pull Error detected"
            echo "     Checking image pull secrets..."
            oc get pod $POD -n $NAMESPACE -o jsonpath='{.spec.imagePullSecrets}' 2>/dev/null
        fi
        
        # Get last 10 lines of logs
        echo "  📋 Recent logs:"
        oc logs $POD -n $NAMESPACE --tail=10 2>&1 | sed 's/^/     /'
        
        # Get events
        echo "  📅 Recent events:"
        oc get events -n $NAMESPACE --field-selector involvedObject.name=$POD --sort-by='.lastTimestamp' | tail -3 | sed 's/^/     /'
    else
        echo "  ✅ Pod is healthy"
    fi
    echo ""
}

echo "=== Current Pod Status ==="
oc get pods -n $NAMESPACE -l app.kubernetes.io/instance=mission-control
echo ""

echo "=== Checking Each Pod ==="
PODS=$(oc get pods -n $NAMESPACE -l app.kubernetes.io/instance=mission-control -o jsonpath='{.items[*].metadata.name}')

for POD in $PODS; do
    check_pod $POD
done

echo "=== Common Issues & Fixes ==="
echo ""

# Check for ImagePullBackOff
IMAGEPULL_PODS=$(oc get pods -n $NAMESPACE -l app.kubernetes.io/instance=mission-control -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[*].state.waiting.reason}{"\n"}{end}' | grep -i imagepull | awk '{print $1}')

if [ ! -z "$IMAGEPULL_PODS" ]; then
    echo "❌ Issue: Image Pull Errors"
    echo "   Pods affected: $IMAGEPULL_PODS"
    echo ""
    echo "   Possible causes:"
    echo "   1. Network issues accessing image registry"
    echo "   2. Missing or invalid image pull secrets"
    echo "   3. Wrong image names in Helm chart"
    echo ""
    echo "   Fix options:"
    echo "   Option 1: Check cluster can access external registries"
    echo "     oc run test --image=busybox --rm -it -- wget -O- https://registry.example.com"
    echo ""
    echo "   Option 2: Add image pull secrets if using private registry"
    echo "     oc create secret docker-registry my-secret --docker-server=..."
    echo "     oc secrets link default my-secret --for=pull -n $NAMESPACE"
    echo ""
fi

# Check for CrashLoopBackOff
CRASH_PODS=$(oc get pods -n $NAMESPACE -l app.kubernetes.io/instance=mission-control --no-headers | grep "CrashLoopBackOff" | awk '{print $1}')

if [ ! -z "$CRASH_PODS" ]; then
    echo "❌ Issue: Pods Crashing"
    echo "   Pods affected: $CRASH_PODS"
    echo ""
    for POD in $CRASH_PODS; do
        echo "   Logs from $POD:"
        oc logs $POD -n $NAMESPACE --tail=20 | sed 's/^/     /'
        echo ""
    done
    echo "   Fix: Check logs above for error messages"
    echo ""
fi

# Check for Pending pods
PENDING_PODS=$(oc get pods -n $NAMESPACE -l app.kubernetes.io/instance=mission-control --no-headers | grep "Pending" | awk '{print $1}')

if [ ! -z "$PENDING_PODS" ]; then
    echo "❌ Issue: Pods Stuck in Pending"
    echo "   Pods affected: $PENDING_PODS"
    echo ""
    echo "   Checking resources..."
    for POD in $PENDING_PODS; do
        oc describe pod $POD -n $NAMESPACE | grep -A 5 "Events:" | sed 's/^/     /'
    done
    echo ""
    echo "   Possible causes:"
    echo "   1. Insufficient cluster resources"
    echo "   2. Node selectors or affinity rules not matching"
    echo "   3. PVC issues"
    echo ""
fi

echo "=== Job Pods (Expected to Complete) ==="
oc get pods -n $NAMESPACE -l app.kubernetes.io/instance=mission-control --no-headers | grep -E "(Completed|job-|patcher)" || echo "No job pods found"
echo ""

echo "=== Helm Release Status ==="
helm status mission-control -n $NAMESPACE 2>&1 | head -20
echo ""

echo "=== Quick Fixes ==="
echo ""
echo "1. Restart failed pods:"
echo "   oc delete pod -n $NAMESPACE -l app.kubernetes.io/instance=mission-control --field-selector=status.phase!=Running,status.phase!=Succeeded"
echo ""
echo "2. Check Helm values:"
echo "   helm get values mission-control -n $NAMESPACE"
echo ""
echo "3. View all events:"
echo "   oc get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -20"
echo ""
echo "4. Full reinstall (if needed):"
echo "   helm uninstall mission-control -n $NAMESPACE"
echo "   ansible-playbook install-improved.yml"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     For detailed investigation, run:                      ║"
echo "║     bash troubleshoot.sh                                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
