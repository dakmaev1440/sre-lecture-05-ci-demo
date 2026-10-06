FROM golang:1.25-alpine AS build
WORKDIR /src
COPY go.mod ./
COPY cmd ./cmd
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/server ./cmd/server

FROM alpine:3.22
RUN adduser -D -H -u 10001 appuser
COPY --from=build /out/server /server
USER 10001
EXPOSE 8080
ENTRYPOINT ["/server"]
