# Backout / שחזור מהיר – EmpireLogic (Production)

## קבצים מרכזיים
- **Nginx**
  - /etc/nginx/sites-available/empirelogicapp.com
  - /etc/nginx/snippets/watcher-alias.conf
- **systemd (API)**
  - /etc/systemd/system/rollinginsights-api.service
- **env (מחוץ לריפו)**
  - /srv/apps/empirelogic/env/api.env   ← קיימת תבנית: `env/api.env.template`

## שחזור Nginx (על השרת)
sudo cp ~/infra-sync/nginx/sites/empirelogicapp.com /etc/nginx/sites-available/empirelogicapp.com
sudo cp ~/infra-sync/nginx/snippets/watcher-alias.conf /etc/nginx/snippets/watcher-alias.conf
sudo nginx -t && sudo systemctl reload nginx

## שחזור systemd (על השרת)
sudo cp ~/infra-sync/systemd/rollinginsights-api.service /etc/systemd/system/rollinginsights-api.service
sudo systemctl daemon-reload
sudo systemctl restart rollinginsights-api.service
sudo systemctl status rollinginsights-api.service --no-pager -l

## יצירת env חדש לפי התבנית (על השרת)
sudo install -d -m 755 /srv/apps/empirelogic/env
sudo cp ~/infra-sync/env/api.env.template /srv/apps/empirelogic/env/api.env
sudo chmod 600 /srv/apps/empirelogic/env/api.env
sudo chown deploy:deploy /srv/apps/empirelogic/env/api.env
# ערוך את /srv/apps/empirelogic/env/api.env ושבץ סודות (Password, JwtSettings__SecretKey, ...)

## בדיקות מהירות
curl -sS -i http://127.0.0.1:5080/api/health | sed -n '1,15p'
curl -sS -i https://empirelogicapp.com/api/health | sed -n '1,15p'
