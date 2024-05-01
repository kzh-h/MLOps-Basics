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
FROM python:3.11.9-slim-bullseye as deploy

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

COPY ./ /app
WORKDIR /app

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

# HACK
RUN python -m dvc pull outputs/2024-04-28/07-11-42/models/best-checkpoint.ckpt.dvc

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
