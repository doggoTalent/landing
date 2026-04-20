FROM alpine:latest
RUN apk add --no-cache python3
COPY . /www
WORKDIR /www
EXPOSE 8000
CMD ["python3", "-m", "http.server", "8000"]
