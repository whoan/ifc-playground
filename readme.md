# IFC PLayground

## Build with docker

```
docker build -t ifc:alpine-3.18 --load -f alpine.Dockerfile .
```

## Play with it

```
docker run -ti --rm -v"$path_to_files_to_play_with":/files ifc:alpine-3.18
```
