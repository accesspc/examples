FROM alpine:latest

RUN apk update --no-cache
RUN apk upgrade --no-cache --available

RUN apk add --no-cache curl gnupg python3
RUN apk add --no-cache openssh zip

COPY ./run.sh /run.sh

RUN chmod +x /run.sh

RUN apk add --no-cache python3 py3-pip
RUN pip3 install -r /requirements.txt
COPY ./requirements.txt /requirements.txt

CMD /run.sh
