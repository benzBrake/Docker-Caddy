# Docker-Caddy
A Docker image for Caddy. This image includes `http.cache,http.filter,http.nobots,http.ratelimit,http.realip,tls.dns.cloudflare` plugins.

Plugins can be configured via the `CADDY_PLUGIN` build arg.

# License
[Anti-996 License](LICENSE)

 - The purpose of this license is to prevent anti-labour-law companies from using the software or codes under the license, and force those companies to weigh their way of working
 - See a [full list of projects](awesomelist/projects.md) under Anti-996 License
 - It is an idea of @xushunke: [Design A Software License Of Labor Protection -- Anti 996 License](https://github.com/996icu/996.ICU/pull/15642)
 - This version of Anti-996 License is drafted by [Katt Gu, J.D, University of Illinois, College of Law](https://scholar.google.com.sg/citations?user=PTcpQwcAAAAJ&hl=en&oi=ao); advised by [Suji Yan](https://www.linkedin.com/in/tedkoyan/), CEO of [Dimension](https://www.dimension.im).  
 - This draft is adapted from the MIT license. For more detailed explanation, please see [Wiki](https://github.com/kattgu7/996-License-Draft/wiki). This license is designed to be compatible with all major open source licenses.  
 - For law professionals or anyone who is willing to contribute to future version directly, please go to [Anti-996-License-1.0](https://github.com/kattgu7/996-License-Draft). Thank you.


# Usage
## 1.Run without any settings.
```
$ docker run -d -p 80:80 benzbrake/caddy
```
Point your browser to `http://127.0.0.1:80`.
## 2.Saving Certificates
Save certificates on host machine to prevent regeneration every time container starts.
```
$ docker run -d -v /data/caddy:/data/caddy -v /etc/Caddyfile:/etc/Caddyfile -p 80:80 -p 443:443 benzbrake/caddy
```
Here, `$HOME/.caddy` is the location inside the container where caddy will save certificates.

Additionally, you can use an environment variable to define the exact location caddy should save generated certificates:
```
$ docker run -d -e "CADDYPATH=/etc/caddy" -v /data/caddy:/etc/caddy -p 80:80 -p 443:443 benzbrake/caddy
```
Above, we utilize the CADDYPATH environment variable to define a different location inside the container for certificates to be stored. This is probably the safest option as it ensures any future docker image changes don't interfere with your ability to save certificates!
## 3.Custom license
If you purchased a commercial license, you must set your account ID and API key in build args:
```
docker build --build-arg \
    CADDY_ACCOUNT_ID=... \
    CADDY_API_KEY=... \
    CADDY_LICENSE=commercial \
    github.com/benzbrake/Docker-Caddy.git
```
## 4.Custom plugins
```
docker build --build-arg \
	"CADDY_PLUGIN=http.cache,http.filter,http.nobots,http.ratelimit,http.realip" \
    github.com/benzbrake/Docker-Caddy.git
```
## 6.php

`:php` variant of this image bundles PHP-FPM alongside essential php extensions.
Default php running user is set to 1000:1000

### add thirdparty php extensions
Add thirdparty php extensions to php in container. Put your extensions to `/data/php-extensions` and run container like:
```
$ docker run -d -v /data/php-extensions:/www/php-extensions -v /data/web:/www/wwwroot -v /data/vhosts:/www/config -p 80:80 -p 443:443 benzbrake/caddy:php
```

## 6.Builder
Builder is copy from [abiosoft/caddy-docker](https://github.com/abiosoft/caddy-docker).
# Feedback

If you have any problems with or questions about this image, please contact me through a GitHub [issue](https://github.com/benzBrake/Docker-Caddy/issues "issue").

