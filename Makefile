name = git-timeline
port = 4567

build:
	docker build --tag $(name) .

run:
	docker rm --force $(name) && docker run --name $(name) -e PORT=$(port) -p $(port):$(port) $(name)

all: build run

clean:
	docker rm $(name)
	docker rmi $(name)