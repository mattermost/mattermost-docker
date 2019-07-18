
.PHONY: shellcheck build-db build-app build-app-enterprise build-app-team test-enterprise test-team

shellcheck:
	find . -path "*.sh" -type f -print -exec shellcheck {} +

build-db:
	docker build -t mattermost-prod-db db

build-app: build-app-enterprise build-app-team

build-app-enterprise:
	docker build -t mattermost-prod-app --build-arg MM_VERSION=$(MM_VERSION) app

build-app-team:
	docker build -t mattermost-prod-app-team --build-arg edition=team --build-arg MM_VERSION=$(MM_VERSION) app

test-enterprise:
	docker run -d --name db -e POSTGRES_USER=mmuser -e POSTGRES_PASSWORD=mmuser_password -e POSTGRES_DB=mattermost mattermost-prod-db \
	&& sleep 5 \
	&& docker run -d --link db -p 80:8000 --name app -e MM__DB_USERNAME=mmuser -e MM_DB_PASSWORD=mmuser_password -e MM_DB_HOST=db -e PUID=2000 -e PGID=2000 mattermost-prod-app"
test-team:
	docker run -d --name db -e POSTGRES_USER=mmuser -e POSTGRES_PASSWORD=mmuser_password -e POSTGRES_DB=mattermost mattermost-prod-db \
	&& sleep 5 \
	&& docker run -d --link db -p 80:8000 --name app -e MM__DB_USERNAME=mmuser -e MM_DB_PASSWORD=mmuser_password -e MM_DB_HOST=db -e PUID=2000 -e PGID=2000 mattermost-prod-app-team"