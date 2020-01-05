################################################################################
# Based on https://github.com/jagregory/pandoc-docker
################################################################################
FROM haskell:8

ENV USER root
ENV HOME /root
MAINTAINER Julio Delgado Mangas <julio.delgadomangas@gmail.com>

# install emacs25
RUN apt-get update -y \
    && apt-get install curl wget git emacs25 xzdec -y \
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
    texlive-generic-recommended \
    texlive-math-extra \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-bibtex-extra \
    fontconfig \
    lmodern \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN tlmgr init-usertree \
    && tlmgr install titling fancyhdr marginnote ulem xstring oberdiek geometry fontspec

# will ease up the update process
# updating this env variable will trigger the automatic build of the Docker image
ENV PANDOC_VERSION "2.9.1"

# install pandoc
RUN cabal update && cabal install pandoc-${PANDOC_VERSION} --minimize-conflict-set

WORKDIR /source

ENTRYPOINT ["/root/.cabal/bin/pandoc"]

CMD ["--help"]