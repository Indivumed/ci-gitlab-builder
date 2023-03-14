FROM ubuntu:22.04
ENV TZ=UTC
RUN apt update \
  && apt install --assume-yes  \
    python3-dev python3-pip rustc libffi-dev openssl vim unzip \
    curl wget bash git sqlite jq cargo parallel docker docker-compose \
  && echo "source /etc/profile" >> ~/.bashrc \
RUN pip3 install --upgrade pip
# install docker-compose and AWS tools
# FIXME: awsebcli is having pretty outdated dependencies to docker-compose, requests and awscli
COPY requirements.txt .
RUN pip3 install -r requirements.txt
# install aws cli v2
RUN curl --silent --fail --location --output aws-cli-v2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
  && unzip -nq aws-cli-v2.zip -d aws-cli-v2 \
  && ./aws-cli-v2/aws/install \
  && rm -rf aws-cli-v2-zip aws-cli-v2 \
  && echo "complete -C '/usr/bin/aws_completer' aws" >> ~/.bashrc \
  && /usr/local/bin/aws --version
# install aws-iam-authenticator
RUN curl --silent --location --output /usr/local/bin/aws-iam-authenticator \
    https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator \
   && chmod +x /usr/local/bin/aws-iam-authenticator \
   && aws-iam-authenticator version
# install kubectl
RUN curl --tlsv1.3 --ssl-reqd --silent --location --output /usr/local/bin/kubectl \
     https://storage.googleapis.com/kubernetes-release/release/v1.23.7/bin/linux/amd64/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  && kubectl version --client=true \
  && echo "source <(kubectl completion bash) \nalias k=kubectl \ncomplete -F __start_kubectl k" >> ~/.bashrc
# install kustomize
RUN kustomize_version="v4.5.4" \
  && curl --location \
    "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${kustomize_version}/kustomize_${kustomize_version}_linux_amd64.tar.gz" \
    | tar --no-same-owner --extract --gzip \
  && install --target-directory=/usr/local/bin kustomize \
  && rm kustomize
# install gomplate
RUN curl --silent --location --output /usr/local/bin/gomplate \
    https://github.com/hairyhenderson/gomplate/releases/download/v3.8.0/gomplate_linux-amd64 \
   && chmod +x /usr/local/bin/gomplate \
   && gomplate --version
# install argo cli
RUN curl --silent --location \
      https://github.com/argoproj/argo-workflows/releases/download/v3.4.5/argo-linux-amd64.gz \
    | gzip -d > argo \
  && install --target-directory=/usr/local/bin argo \
  && rm argo
