# --- Local preview of the built site -------------------------------------
# Serves the `site` derivation behind nginx with the same
# `try_files $uri $uri.html` fallback GitHub Pages uses, so pretty URLs
# like /about resolve to about.html -- which a dumb static server won't
# do. This is what `nix build` produces, exactly as it will deploy.
{ pkgs, site }:
let
  previewConf = pkgs.writeText "nginx-preview.conf" ''
    daemon off;
    error_log stderr info;
    pid /tmp/aumitleon-preview/nginx.pid;
    events {}
    http {
      include ${pkgs.nginx}/conf/mime.types;
      default_type application/octet-stream;
      access_log /dev/stdout;
      client_body_temp_path /tmp/aumitleon-preview/client;
      proxy_temp_path /tmp/aumitleon-preview/proxy;
      fastcgi_temp_path /tmp/aumitleon-preview/fastcgi;
      uwsgi_temp_path /tmp/aumitleon-preview/uwsgi;
      scgi_temp_path /tmp/aumitleon-preview/scgi;
      server {
        listen 8080;
        server_name localhost;
        root ${site};
        location / {
          try_files $uri $uri.html $uri/index.html =404;
        }
      }
    }
  '';
in
pkgs.writeShellScriptBin "preview" ''
  set -e
  mkdir -p /tmp/aumitleon-preview
  echo "🌍 Serving the Nix build at http://127.0.0.1:8080  (Ctrl-C to stop)"
  exec ${pkgs.nginx}/bin/nginx -c ${previewConf} -e /tmp/aumitleon-preview/error.log
''
