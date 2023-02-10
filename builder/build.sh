#!/bin/bash

set -e
cd $(dirname $0)

REMOTE_TAG=${REMOTE_TAG:-"v4.0.5"}

# Clone 
if [[ ! -d chirpstack-gateway-bridge ]]; then
    git clone https://github.com/chirpstack/chirpstack-gateway-bridge.git chirpstack-gateway-bridge
fi

# Chack out tag
cd chirpstack-gateway-bridge
git checkout ${REMOTE_TAG}

# Apply patches
if [ -f ../GLS_CSGB_${REMOTE_TAG}.1.patch ]; then
    echo "Applying GLS_CSGB_${REMOTE_TAG}.1.patch ..."
    git apply ../GLS_CSGB_${REMOTE_TAG}.1.patch

fi

# Build
echo "Start building GLS ChirpStac Gateway bridge Docker image..."

make dev-requirements
make