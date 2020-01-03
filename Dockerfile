################################################################################
# Based on https://github.com/jagregory/pandoc-docker
################################################################################
FROM haskell:8.0

ENV USER root
ENV HOME /root
MAINTAINER Julio Delgado Mangas <julio.delgadomangas@gmail.com>

# install emacs24
RUN apt-get update -y \
    && apt-get install curl wget git emacs24 -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install emacs configuration and required packages
COPY emacs.d ${HOME}/.emacs.d
RUN emacs --batch -l ${HOME}/.emacs.d/init.el

# Install gitconfig
COPY gitconfig ${HOME}/.gitconfig

# install latex packages
RUN apt-get update -y \
    && apt-get install -y -o Acquire::Retries=10 --no-install-recommends \
    texlive-latex-base \
    texlive-xetex latex-xcolor \
    texlive-math-extra \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-bibtex-extra \
    fontconfig \
    lmodern \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*    

# will ease up the update process
# updating this env variable will trigger the automatic build of the Docker image
ENV PANDOC_VERSION "1.19.2.1"

# install pandoc
RUN cabal update && cabal install pandoc-${PANDOC_VERSION}

WORKDIR /source

ENTRYPOINT ["/root/.cabal/bin/pandoc"]

CMD ["--help"]