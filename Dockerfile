FROM buildpack-deps:jessie

# get darknet weights
RUN wget http://pjreddie.com/media/files/yolo.weights
RUN wget http://pjreddie.com/media/files/tiny-yolo-voc.weights
RUN wget http://pjreddie.com/media/files/yolo-voc.weights

RUN git clone https://github.com/pjreddie/darknet
COPY darknet_patch.txt /darknet/
WORKDIR /darknet

# change the default print format to allow me to interface it
RUN git apply darknet_patch.txt
RUN make

# install node and use the lts version
RUN curl -L https://git.io/n-install | bash -s -- -y lts
COPY /server/* /darknet/
# install npm deps
RUN bash -c 'source /root/.bashrc; npm install'

EXPOSE 3000

ENTRYPOINT /root/n/bin/node server.js