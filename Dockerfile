FROM python:3.11.9-bullseye as builder

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt


# development
FROM builder as development

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

ARG USER_NAME
ARG USER_UID
ARG USER_GID

# Create the user
RUN groupadd --gid $USER_GID $USER_NAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USER_NAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME \
    && chmod 0440 /etc/sudoers.d/$USER_NAME

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

COPY requirements.development.txt /app/requirements.development.txt
WORKDIR /app

RUN pip install --no-cache-dir -r requirements.development.txt

USER $USER_NAME


# deploy
FROM python:3.11 as deploy

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

# AWS Lambdaランタイムインターフェースエミュレータのinstall
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/v1.18/aws-lambda-rie /usr/bin/aws-lambda-rie
COPY entry.sh "/entry.sh"
RUN chmod 755 /usr/bin/aws-lambda-rie /entry.sh

ARG APP_DIR="/var/task/"
WORKDIR ${APP_DIR}
COPY ./ ${APP_DIR}
ENV PYTHONPATH "${PYTHONPATH}:./:/usr/local/lib/python3.11/site-packages"

RUN pip install awslambdaric

RUN dvc pull outputs/2024-04-28/07-11-42/models/model.onnx.dvc

# Download the tokenizer required and saves it in the cache.
ENV TRANSFORMERS_CACHE=outputs/2024-04-28/07-11-42/models \
    TRANSFORMERS_VERBOSITY=error
RUN python lambda_handler.py

RUN chmod -R 755 outputs/2024-04-28/07-11-42/models

ENTRYPOINT [ "/bin/bash", "/entry.sh" ]
CMD ["local_lambda.handler"]
