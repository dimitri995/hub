FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder

# Move to working directory (/build).
WORKDIR /build

# Copy and download dependency using go mod.
COPY go.mod go.sum ./
RUN go mod download

# Copy the code into the container.
COPY . .

# Set necessary environmet variables needed for our image and build the API server.
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags="-s -w" -o hub .

FROM alpine:3.14

RUN mkdir app
# Copy binary and config files from /build to root folder of scratch container.
#COPY --from=builder ["/build/apiserver", "/build/.env", "/"]
COPY --from=builder ["/build/hub", "/app"]
COPY --from=builder ["/build/internal/views", "/app/internal/views"]
COPY --from=builder ["/build/internal/public", "/app/internal/public"]

# Export necessary port.
WORKDIR /app
EXPOSE 8000

# Command to run when starting the container.
ENTRYPOINT ["./hub"]
