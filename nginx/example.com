server {
        listen 3200 ssl;
        server_name www.example.com;
        if ($http_host != www.example.com:3200) {
                rewrite (^.*$) http://$host;
        }
        ssl_certificate /etc/nginx/certs/example.com.crt;
        ssl_certificate_key /etc/nginx/certs/example.com.key;
        ssl_protocols   TLSv1.2;
        location / {
                proxy_pass http://localhost:3400;
        }
}
