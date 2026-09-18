FROM teddysun/xray:latest

# Générer un certificat auto-signé valable 10 ans
RUN apk add --no-cache openssl && \
    openssl req -x509 -newkey rsa:4096 -keyout /etc/xray/key.pem -out /etc/xray/cert.pem -days 3650 -nodes -subj "/CN=localhost"

COPY config.json /etc/xray/config.json
EXPOSE 8080
CMD ["xray", "run", "-config", "/etc/xray/config.json"]
