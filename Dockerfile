# Start by building the application.
FROM golang:1.19-alpine as build

WORKDIR /go/src/app
COPY . .

RUN go mod download
RUN GOOS=linux go build -o /go/bin/app.bin cmd/main.go

RUN adduser -S -u 1001 appuser

# Now copy it into our base image.
FROM gcr.io/distroless/base-debian11:debug

# Copy dependencies
COPY --from=build /bin/sh /bin/sh
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

COPY --from=build /go/bin/app.bin /

USER appuser

ENV APP_HOST="0.0.0.0"
ENV APP_PORT=9000
ENV DB_URL="postgres://user:pass@localhost:5432/app"

ENTRYPOINT /app.bin -dbUrl ${DB_URL} -host ${APP_HOST} -port ${APP_PORT}
