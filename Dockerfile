FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y wget curl git build-essential tcl pkg-config python3-opencv libopencv-dev 

# get darknet weights
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137
# RUN curl -L -o yolov3.weights https://www.dropbox.com/s/h4zq99f5kqk76rr/yolov3.weights?dl=1
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.conv.29
# RUN curl -L -o yolov3-tiny.weights https://www.dropbox.com/s/dk47iwpn14e7cov/yolov3-tiny.weights?dl=1

RUN git clone https://github.com/AlexeyAB/darknet.git
WORKDIR /darknet
RUN git checkout darknet-service
COPY darknet_patch.txt /darknet/
WORKDIR /darknet

# change the default print format to allow me to interface it
RUN git apply darknet_patch.txt

RUN sed -i 's/OPENCV=0/OPENCV=1/g' Makefile
RUN sed -i 's/GPU=0/GPU=1/g' Makefile
RUN sed -i 's/CUDNN=0/CUDNN=1/g' Makefile
RUN sed -i "s/ARCH= -gencode arch=compute_60,code=sm_60/ARCH= -gencode arch=compute_${compute_capability},code=sm_${compute_capability}/g" Makefile
RUN sed -i 's/CUDNN_HALF=0/CUDNN_HALF=1/' Makefile

# frames resizing
RUN sed -i 's/get_label_v3(alphabet, labelstr, (im.h\*.02))/get_label_v3(alphabet, labelstr, (im.h\*.005))/g' src/image.c
RUN sed -i 's/width = im.h \* .002/width = im.h \* .001/g' src/image.c

RUN make

# RUN cp data/obj.names data/coco.names

# install node and use the lts version
RUN curl -L https://git.io/n-install | bash -s -- -y lts
COPY /server/* /darknet/
# install npm deps
# RUN bash -c 'export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"; npm install'
RUN bash -c 'source /root/.bashrc; npm install'

EXPOSE 3000

ENTRYPOINT /root/n/bin/node server.js