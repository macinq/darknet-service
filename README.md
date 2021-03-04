# darknet_service

Use [darknet](https://pjreddie.com/darknet/yolo/) object detection from an API:

```shell
docker build -t darknet .
# foreground docker process
docker run --gpus all --rm -p 0.0.0.0:3000:3000 --name running-darknet darknet
# background docker process
docker run --gpus all -d --rm -p 0.0.0.0:3000:3000 --name running-darknet darknet
```

You can request the service with curl like:

```shell
curl -F "photo=@my_photo.jpg" localhost:3000/yolo
curl -F "photo=@my_photo.jpg" localhost:3000/yolo-tiny-3l
```

Read more about darknet <https://pjreddie.com/darknet/yolo/>