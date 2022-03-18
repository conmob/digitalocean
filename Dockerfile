ARG DIGITALOCEAN_VERSION="1.71.1"
FROM digitalocean/doctl:${DIGITALOCEAN_VERSION} AS binary

FROM amazonlinux:2 AS installer

ARG KUBECTL_VERSION="1.22.3"
ARG HELM_VERSION="3.7.2"
ARG TERRAFORM_VERSION="1.1.2"

RUN yum update -y \
&& yum install -y curl unzip

ENV KUBECTL_VERSION ${KUBECTL_VERSION}
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o kubectl \
&& mv kubectl /usr/local/bin/kubectl \
&& chmod +x /usr/local/bin/kubectl

ENV HELM_VERSION ${HELM_VERSION}
RUN curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.zip -o helm.zip \
&& unzip helm.zip \
&& mv linux-amd64/helm /usr/local/bin/helm \
&& chmod +x /usr/local/bin/helm

ENV TERRAFORM_VERSION ${TERRAFORM_VERSION}
RUN curl -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
&& unzip terraform.zip \
&& mv terraform /usr/local/bin/terraform \
&& chmod +x /usr/local/bin/terraform

FROM amazonlinux:2 AS runtime
COPY --from=binary /app/doctl /usr/local/bin/doctl
COPY --from=installer /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=installer /usr/local/bin/helm /usr/local/bin/helm
COPY --from=installer /usr/local/bin/terraform /usr/local/bin/terraform

RUN yum update -y \
&& yum install -y curl git jq less groff \
&& yum clean all
