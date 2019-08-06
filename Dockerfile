FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y wget curl git build-essential tcl pkg-config
# get darknet weights
# RUN wget https://pjreddie.com/media/files/yolov3.weights
RUN curl -L -o yolov3.weights https://www.dropbox.com/s/h4zq99f5kqk76rr/yolov3.weights?dl=1
# RUN wget https://pjreddie.com/media/files/yolov3-tiny.weights
RUN curl -L -o yolov3-tiny.weights https://www.dropbox.com/s/dk47iwpn14e7cov/yolov3-tiny.weights?dl=1

RUN git clone https://github.com/rowellpica/darknet
WORKDIR /darknet
RUN git checkout darknet-service
RUN make

# install node and use the lts version
RUN curl -L https://git.io/n-install | bash -s -- -y lts
COPY /server/* /darknet/
# install npm deps
RUN bash -c 'export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"; npm install'

EXPOSE 3000

ENTRYPOINT /root/n/bin/node server.js