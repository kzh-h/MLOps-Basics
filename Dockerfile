ARG IMAGE_NAME
ARG USER_NAME
ARG USER_UID
ARG USER_GID

FROM ${IMAGE_NAME}

ARG USER_NAME=${USER_NAME}
ARG USER_UID=${USER_UID}
ARG USER_GID=${USER_GID}

# Create the user
RUN groupadd --gid $USER_GID $USER_NAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USER_NAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME \
    && chmod 0440 /etc/sudoers.d/$USER_NAME

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

COPY ./ /app
WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt

USER $USER_NAME