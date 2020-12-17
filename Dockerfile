################ Build & Dev ################
# Build stage will be used:
# - for building the application for production
# - as target for development (see devspace.yaml)
FROM nvcr.io/nvidia/cuda:11.1-base-ubuntu16.04 as build

ENV NVIDIA_DISABLE_REQUIRE="true"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=utility
ENV GOLANG_VERSION 1.15.2
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH


RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        ca-certificates \
        wget \
        git && \
    rm -rf /var/lib/apt/lists/*


RUN wget -nv -O - https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz

# Create project directory (workdir)
WORKDIR /go/src/app
# Add source code files to WORKDIR
ADD . .

RUN go get .
# Build application
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o main ./cmd/main.go
# Container start command for development
# Allows DevSpace to restart the dev container
# It is also possible to override this in devspace.yaml via images.*.cmd
CMD ["go", "run", "./cmd/main.go"]
################ Production ################
# Creates a minimal image for production using distroless base image
# More info here: https://github.com/GoogleContainerTools/distroless
FROM nvcr.io/nvidia/cuda:11.1-base-ubuntu16.04 as production

ENV NVIDIA_DISABLE_REQUIRE="true"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=utility

RUN apt-get remove -y ca-certificates libssl1.0.0 openssl || true# Copy application binary from build/dev stage to the distroless container
COPY --from=build /go/src/app/main /
# Application port (optional)
#EXPOSE 8080# Container start command for production
CMD ["/main"]