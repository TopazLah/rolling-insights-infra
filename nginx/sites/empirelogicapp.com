server {
    listen 80;
    listen [::]:80;
    server_name empirelogicapp.com www.empirelogicapp.com;
    return 301 https://empirelogicapp.com$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name empirelogicapp.com;

    ssl_certificate     /etc/letsencrypt/live/empirelogicapp.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/empirelogicapp.com/privkey.pem;

    access_log /var/log/nginx/empirelogicapp.access.log;
    error_log  /var/log/nginx/empirelogicapp.error.log;

    location / {
        root /var/www/html;
        index index.html index.htm;
        try_files $uri $uri/ =403;
    }

    location = /health {
        proxy_pass http://127.0.0.1:5080/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:5080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    include snippets/bridge.conf;
    include snippets/watcher-alias.conf;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name www.empirelogicapp.com;

    ssl_certificate     /etc/letsencrypt/live/empirelogicapp.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/empirelogicapp.com/privkey.pem;

    return 301 https://empirelogicapp.com$request_uri;
}
