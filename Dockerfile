FROM buildpack-deps:jessie

# get darknet weights
RUN wget https://pjreddie.com/media/files/yolov3.weights
RUN wget https://pjreddie.com/media/files/yolov3-tiny.weights

RUN git clone https://github.com/rowellpica/darknet
WORKDIR /darknet
RUN git checkout darknet-service
RUN make

# install node and use the lts version
RUN curl -L https://git.io/n-install | bash -s -- -y lts
COPY /server/* /darknet/
# install npm deps
RUN bash -c 'source /root/.bashrc; npm install'

EXPOSE 3000

ENTRYPOINT /root/n/bin/node server.js
