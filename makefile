
install_template:
	@echo "[+] Initialize the git project"
	rm -fr .git
	@echo "[+] Remove the origin remote reference"
	git remote remove origin
	@echo "[+] Create initial commit"
	git init --quiet --initial-branch=main
	git add .
	git commit -am "feat: first commit"
	@echo "[+] Create a copy of .env dotfile"
	cp .env.example .env
	@echo "[+] Generate nginx http configuration (but can be modified later)"
	make generate_http_conf
	@echo "[+] Commit generated nginx configuration"
	git add nginx-conf/nginx.conf
	git commit -m "feat: generate http nginx configuration"

start:
	docker compose up -d --build

down:
	docker compose down

configure:
	docker compose -f docker-compose.yml -f wp-auto-config.yml run --rm wp-auto-config

autoinstall: start
	docker compose -f docker-compose.yml -f wp-auto-config.yml run --rm wp-auto-config

reset: clean

destroy: clean
	@echo "💥 Removing related folders/files, docker containers, networks and volumes"
	docker compose rm --all --volumes

generate_http_conf:
	orbit run generate_nginx_http_conf

generate_https_conf:
	orbit run generate_nginx_https_conf