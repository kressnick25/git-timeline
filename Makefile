name = git-timeline

build:
	docker build --tag $(name) .

run:
	docker rm --force $(name) && docker run --name $(name) -p 4567:4567 $(name)

all: build run

clean:
	docker rm $(name)
	docker rmi $(name)