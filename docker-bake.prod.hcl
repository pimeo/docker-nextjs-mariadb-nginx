variable "version" {
    default = "1.0"
}

group "default" {
    targets = ["runner", "webserver"]
}

target "runner" {
    context = "./next-app"
    dockerfile = "./docker/prod.dockerfile"
    tags = ["next_app/app:${version}"]
    args = {
        NODE_ENV = "production"
        NODE_VERSION = "${NODE_VERSION}"
        NGINX_VERSION = "${NGINX_VERSION}"

        NEXT_PUBLIC_APP_HOST_DOMAIN = "${NEXT_APP_HOST_DOMAIN}"
        NEXT_PUBLIC_APP_EXTERNAL_URL = "${NEXT_APP_EXTERNAL_URL}"

        NEXT_APP_HOST_HTTP_PORT = "${NEXT_APP_HOST_HTTP_PORT}"
        NEXT_APP_HOST_HTTPS_PORT = "${NEXT_APP_HOST_HTTPS_PORT}"
    }
    output = ["type=tar,dest=app.tar.gz"]
}

target "webserver" {
    context = "./next-app"
    dockerfile = "./docker/prod.dockerfile"
    tags = ["next_app/webserver:${version}"]
    args = {
        NODE_VERSION = "${NODE_VERSION}"
        NGINX_VERSION = "${NGINX_VERSION}"

        NEXT_PUBLIC_APP_HOST_DOMAIN = "${NEXT_APP_HOST_DOMAIN}"
        NEXT_PUBLIC_APP_EXTERNAL_URL = "${NEXT_APP_EXTERNAL_URL}"

        NEXT_APP_HOST_HTTP_PORT = "${NEXT_APP_HOST_HTTP_PORT}"
        NEXT_APP_HOST_HTTPS_PORT = "${NEXT_APP_HOST_HTTPS_PORT}"
    }
    output = ["type=tar,dest=nginx.tar.gz"]
}