FROM debian:bookworm AS dep
LABEL author="tecwds"

WORKDIR /source

### 依赖清单
ARG MAIN_DEPENDENCY="git gcc make libpcre3-dev zlib1g-dev libssl-dev"

### 构建选项
ARG BUILD_WITH_OPTIONS="
    --with-select_module
    --with-poll_module
    --with-threads
    --with-file-aio
    --with-http_ssl_module
    --with-http_v2_module
    --with-http_v3_module
    --with-http_realip_module
    --with-http_addition_module
    --with-http_xslt_module
    --with-http_xslt_module=dynamic
    --with-http_image_filter_module
    --with-http_image_filter_module=dynamic
    --with-http_geoip_module
    --with-http_geoip_module=dynamic
    --with-http_sub_module
    --with-http_dav_module
    --with-http_flv_module
    --with-http_mp4_module
    --with-http_gunzip_module
    --with-http_gzip_static_module
    --with-http_auth_request_module
    --with-http_random_index_module
    --with-http_secure_link_module
    --with-http_degradation_module
    --with-http_slice_module
    --with-http_stub_status_module
    --with-http_perl_module
    --with-http_perl_module=dynamic
    --with-perl_modules_path=PATH
    --with-perl=PATH
    --with-mail
    --with-mail=dynamic
    --with-mail_ssl_module
    --with-stream
    --with-stream=dynamic
    --with-stream_ssl_module
    --with-stream_realip_module
    --with-stream_geoip_module
    --with-stream_geoip_module=dynamic
    --with-stream_ssl_preread_module
    --with-google_perftools_module
    --with-cpp_test_module
    --with-compat
    --with-cc=PATH
    --with-cpp=PATH
    --with-cc-opt=OPTIONS
    --with-ld-opt=OPTIONS
    --with-cpu-opt=CPU
    --without-pcre
    --with-pcre
    --with-pcre=DIR
    --with-pcre-opt=OPTIONS
    --with-pcre-jit
    --without-pcre2
    --with-zlib=DIR
    --with-zlib-opt=OPTIONS
    --with-zlib-asm=CPU
    --with-libatomic
    --with-libatomic=DIR
    --with-openssl=DIR
    --with-openssl-opt=OPTIONS
    --with-debug
"

### 默认不适用 without 构建选项
ARG BUILD_WITHOUT_ENABLE=false
ARG BUILD_WITHOUT_OPTIONS="
    --without-select_module
    --without-poll_module
    --without-quic_bpf_module
    --without-http_charset_module
    --without-http_gzip_module
    --without-http_ssi_module
    --without-http_userid_module
    --without-http_access_module
    --without-http_auth_basic_module
    --without-http_mirror_module
    --without-http_autoindex_module
    --without-http_geo_module
    --without-http_map_module
    --without-http_split_clients_module
    --without-http_referer_module
    --without-http_rewrite_module
    --without-http_proxy_module
    --without-http_fastcgi_module
    --without-http_uwsgi_module
    --without-http_scgi_module
    --without-http_grpc_module
    --without-http_memcached_module
    --without-http_limit_conn_module
    --without-http_limit_req_module
    --without-http_empty_gif_module
    --without-http_browser_module
    --without-http_upstream_hash_module
    --without-http_upstream_ip_hash_module
    --without-http_upstream_least_conn_module
    --without-http_upstream_random_module
    --without-http_upstream_keepalive_module
    --without-http_upstream_zone_module
    --without-http
    --without-http-cache
    --without-mail_pop3_module
    --without-mail_imap_module
    --without-mail_smtp_module
    --without-stream_limit_conn_module
    --without-stream_access_module
    --without-stream_geo_module
    --without-stream_map_module
    --without-stream_split_clients_module
    --without-stream_return_module
    --without-stream_pass_module
    --without-stream_set_module
    --without-stream_upstream_hash_module
    --without-stream_upstream_least_conn_module
    --without-stream_upstream_random_module
    --without-stream_upstream_zone_module
    --without-pcre
    --without-pcre2
"

### 其他构建选项
ARG BUILD_OTHER_OPTIONS="
    --prefix=PATH
    --sbin-path=PATH
    --modules-path=PATH
    --conf-path=PATH
    --error-log-path=PATH
    --pid-path=PATH
    --lock-path=PATH
    --user=USER
    --group=GROUP
    --build=NAME
    --builddir=DIR
    --http-log-path=PATH
    --http-client-body-temp-path=PATH
    --http-proxy-temp-path=PATH
    --http-fastcgi-temp-path=PATH
    --http-uwsgi-temp-path=PATH
    --http-scgi-temp-path=PATH
    --add-module=PATH
    --add-dynamic-module=PATH
"

ARG USE_DEFAULT_BUILD=false



### ================================================================ ###

### nginx 仓库代码
ARG NGINX_URL="https://github.com/nginx/nginx.git"

### 前置准备
RUN apt update && apt install -y $MAIN_DEPENDENCY

### 克隆仓库
RUN git clone $NGINX_URL .

### 找到最新的 release tag 并切换到这个分支
# 鉴于仓库中只有 release 命名的 tag,因此可以使用以下操作获得最新分支
RUN git tag --sort="v:refname" | tail -n1 | xargs git checkout -b

### 开始构建
RUN