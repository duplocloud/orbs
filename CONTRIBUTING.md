# Contributing

Follow these steps to be proper.

## Build 

```bash
circleci orb pack src > orb.yml
```

## Docker Images  

The docker image is built with buildx, make sure that is enabled. Then simply run the following command to build the image.
  
```bash
docker buildx bake
```
