.PHONY: all clean build run

all: build run

clean:
	@echo "cleaning things"
	docker kill docker-novnc-jdownloader && echo "stopped container" || /bin/true
	docker rm docker-novnc-jdownloader && echo "removed container" || /bin/true
	docker rmi t4skforce/docker-novnc-jdownloader:latest && echo "removed container image" || /bin/true

build:
	@echo "building things"
	docker build -t t4skforce/docker-novnc-jdownloader:latest .

run:
	@echo "runing things"
	docker run --name docker-novnc-jdownloader -it -p 127.0.0.1:80:80/tcp -p 127.0.0.1:443:443/tcp -e APP_USERNAME=admin -e APP_PASSWORD=admin -v ~/Downloads:/data/Downloads:rw --rm t4skforce/docker-novnc-jdownloader:latest
