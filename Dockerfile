ARG PYTHON_VERSION=3.12-slim
FROM python:$PYTHON_VERSION

MAINTAINER pyLODE Developers <https://github.com/RDFLib/pyLODE/graphs/contributors>

USER root

RUN apt-get update && \
	apt-get upgrade -y --allow-downgrades --allow-remove-essential --allow-change-held-packages

# install extra requirements for pyLODE-via-server
COPY requirements.server.txt /tmp/
RUN pip3 install -r /tmp/requirements.server.txt

# copy the current directory contents
ADD . /app

WORKDIR /app

RUN sed -i 's/fh = logging.FileHandler("pylode\.log")/#fh = logging.FileHandler("pylode\.log")/' pylode/cli.py \
 && sed -i 's/fh\.setFormatter/#fh\.setFormatter/' pylode/cli.py \
 && sed -i 's/logger\.addHandler(fh)/#logger\.addHandler(fh)/' pylode/cli.py

# install pyLODE from source, ensures we always use the latest development branch
RUN python3 setup.py install

RUN mkdir -p /app/venv/bin && ln -s /usr/local/bin/python /app/venv/bin/python

RUN cd ./pylode

USER 9008

EXPOSE 8000

CMD ["gunicorn"  , "-b", "0.0.0.0:8000", "--chdir", "/app/pylode", "server:api"]