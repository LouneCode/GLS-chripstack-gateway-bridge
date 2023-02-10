ARG REMOTE_TAG=v4.0.5
ARG PROJECT_PATH=chirpstack-gateway-bridge 
ARG CGO_ENABLED=0
ARG GO_EXTRA_BUILD_ARGS="-a -installsuffix cgo"

FROM golang:1.19.3-alpine AS development

ARG REMOTE_TAG
ARG PROJECT_PATH
ARG CGO_ENABLED=0
ARG GO_EXTRA_BUILD_ARGS

RUN apk add --no-cache ca-certificates make git bash

WORKDIR /app

# Checkout and compile remote code
COPY builder/* ./
RUN chmod +x *.sh

# Compile GLS ShirpStack bridege gateway
#
# Clone chirpstack gateway bridge repositoty.
# Patch code.
# Run make dev-requirements make and make commands. 
RUN PATH=${PATH}:/app/${PROJECT_PATH} && \
    CGO_ENABLED=${CGO_ENABLED} && \
    GO_EXTRA_BUILD_ARGS=${GO_EXTRA_BUILD_ARGS} && \ 
    REMOTE_TAG=${REMOTE_TAG} && \
    ./build.sh

#RUN make dev-requirements
#RUN make

FROM alpine:3.17.0 AS production

RUN apk --no-cache add ca-certificates sudo bash && \
    echo "nonprivuser ALL=(ALL) NOPASSWD:ALL /bin/su" >> /etc/sudoers && \
    addgroup -S nonprivuser && adduser -S nonprivuser -G nonprivuser && \
    chown -R nonprivuser:nonprivuser /home/nonprivuser && \
    sed -i 's|LANG=C.UTF-8|LANG=en_US.UTF-8|' /etc/profile.d/locale.sh  && \
    rm -rf /var/cache/apk/*

# Work dir for GLS ChripStack gateway bridge
WORKDIR /app    

COPY --from=development /app/chirpstack-gateway-bridge/build/chirpstack-gateway-bridge /app/gls-chirpstack-gateway-bridge

# Set nonpriv user env
RUN chmod +x /app/gls-chirpstack-gateway-bridge && \
    chown -R nonprivuser /app

USER nonprivuser

ENTRYPOINT ["/app/gls-chirpstack-gateway-bridge"]