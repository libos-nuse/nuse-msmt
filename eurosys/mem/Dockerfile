FROM alpine:latest

RUN apk add nginx make gcc musl-dev gdb python3

COPY nginx.conf /root/
COPY hello.c /root/
COPY hello /root/hello.runu
WORKDIR /root

RUN gcc hello.c -o hello
