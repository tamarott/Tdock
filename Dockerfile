FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

## Install basic packages and useful utilities
## ===========================================
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y  && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:neovim-ppa/stable && \
    apt-get update -y && \
    apt-get install -y \
        build-essential \
        bzip2 \
        ca-certificates \
        locales \
        fonts-liberation \
        man \
        cmake \
        sudo \
        openssh-server \
        python2.7 \
        python2.7-dev \
        python-pip \
        python \
        python-dev \
        python-pip \
        pylint \
        sshfs \
        wget \
        curl \
        rsync \
        ssh \
        bc \
        nano \
        vim \
        emacs \
        git \
        tig \
        tmux \
        zsh \
        unzip \
        htop \
        tree \
        silversearcher-ag \
        ctags \
        cscope \
        jq \
        libblas-dev \
        liblapack-dev \
        gfortran \
        libfreetype6-dev \
        libpng-dev \
        ffmpeg \
        python-qt4 \
        #python3-pyqt5 \
        imagemagick \
        inkscape \
        jed \
        libsm6 \
        libxext-dev \
        libxrender1 \
        lmodern \
        netcat \
        pandoc \
        texlive-fonts-extra \
        texlive-fonts-recommended \
        texlive-generic-recommended \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-xetex \
        graphviz \
        libncurses5-dev \
        libncursesw5-dev \
        && \
    apt-get install -y neovim && \
    pip install pynvim==0.3.2 && \
    apt-get clean

    ## ToDo: increase memory limit to 10GB in: /etc/ImageMagick-6/policy.xml

## Install nvtop
## =============
RUN git clone https://github.com/Syllo/nvtop.git /tmp/nvtop && \
    mkdir /tmp/nvtop/build && \
    cd /tmp/nvtop/build && \
    cmake .. || : && \
    make || : && \
    make install || : && \
    cd / && \
    rm -r /tmp/nvtop

## Set locale
## ==========
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

## SSH server
## ==========
RUN mkdir /var/run/sshd && \
    sed 's/^#\?PasswordAuthentication .*$/PasswordAuthentication yes/g' -i /etc/ssh/sshd_config && \
    sed 's/^#\?Port .*$/Port 9022/g' -i /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

## VSCode
## ======
RUN cd /tmp && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt-get install apt-transport-https && \
    apt-get update && \
    apt-get install -y code && \
    rm microsoft.gpg

## Install pycharm
## ===============
#ARG PYCHARM_SOURCE="https://download.jetbrains.com/python/pycharm-community-2018.3.3.tar.gz"
#RUN mkdir /opt/pycharm && \
#    cd /opt/pycharm && \
#    curl -L $PYCHARM_SOURCE -o installer.tgz && \
#    tar --strip-components=1 -xzf installer.tgz && \
#    rm installer.tgz && \
#    /usr/bin/python2 /opt/pycharm/helpers/pydev/setup_cython.py build_ext --inplace && \
#    /usr/bin/python3 /opt/pycharm/helpers/pydev/setup_cython.py build_ext --inplace
#COPY ./resources/pycharm.bin /usr/local/bin/pycharm

## Setup app folder
## ================
RUN mkdir /app && \
    chmod 777 /app

## Setup python environment
## ========================
#RUN pip3 install pip==21.0.1 && \
RUN pip install pip==21.0.1 && \
    hash -r pip && \
	#pip3 install -U \
	pip install -U \
        virtualenv==20.0.10 \
        ipython==7.13.0 \
        numpy==1.16.4 \
        scipy==1.2.1 \
		librosa==0.4.3 \
		h5py==2.9.0 \
        matplotlib==3.2.0 \
        PyQt5==5.14.1 \
        seaborn==0.10.0 \
        plotly==4.5.3 \
        dash==1.9.1 \
        bokeh==2.0.0 \
        ggplot==0.11.5 \
        altair==4.0.1 \
        pandas==1.0.1 \
        pyyaml==5.3 \
        protobuf==3.11.3 \
        ipdb==0.13.2 \
        flake8==3.7.9 \
        cython==0.29.15 \
        sympy==1.5.1 \
        nose==1.3.7 \
        sphinx==1.8.1 \
        tqdm==4.43.0 \
        opencv-contrib-python==4.2.0.32 \
        scikit-image==0.16.2 \
        scikit-learn==0.22.2 \
        imageio==2.8.0 \
        torchvision==0.4.0 \
        torchviz==0.0.1 \
        Pillow==6.1 \
        torchsummary==1.5.1 \
        tensorflow-gpu==1.13.1 \
        tensorboardX==2.0 \
		keras==1.2.1 \
        jupyter==1.0.0 \
        jupyterthemes==0.20.0 \
        jupyter_contrib_nbextensions==0.5.1 \
        jupyterlab==2.0.1 \
        ipywidgets==7.5.1 \
        visdom==0.1.8.9 \
        line_profiler==3.0.2 \
        && \
        rm -r /root/.cache/pip
ENV MPLBACKEND=Agg

## Import matplotlib the first time to build the font cache.
## ---------------------------------------------------------
#RUN python3 -c "import matplotlib.pyplot" && \
RUN python -c "import matplotlib.pyplot" && \
    cp -r /root/.cache /etc/skel/

## Setup Jupyter
## -------------
RUN pip install six==1.11 && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter contrib nbextension install --system && \
    jupyter nbextensions_configurator enable && \
    jupyter serverextension enable --py jupyterlab --system && \
    pip install RISE && \
    jupyter-nbextension install rise --py --sys-prefix --system && \
    cp -r /root/.jupyter /etc/skel/

## Install Orca (for exporting Plotly figures to images)
## =====================================================
RUN apt install -y xvfb libgconf2-4 && \
    wget https://github.com/plotly/orca/releases/download/v1.1.1/orca-1.1.1-x86_64.AppImage -P /tmp && \
    chmod 777 /tmp/orca-1.1.1-x86_64.AppImage && \
    cd /tmp && \
    ./orca-1.1.1-x86_64.AppImage --appimage-extract && \
    mv /tmp/squashfs-root /opt/squashfs-root && \
    chmod -R 777 /opt/squashfs-root && \
    printf '#!/bin/bash \nxvfb-run --auto-servernum --server-args "-screen 0 640x480x24" /opt/squashfs-root/app/orca "$@"' > /usr/bin/orca && \
    chmod 777 /usr/bin/orca && \
    rm -r /tmp/orca-1.1.1-x86_64.AppImage

## Create virtual environment
## ==========================
RUN cd /app/ && \
    virtualenv --system-site-packages dockvenv && \
    #grep -rlnw --null /usr/local/bin/ -e '#!/usr/bin/python3' | xargs -0r cp -t /app/dockvenv/bin/ && \
    grep -rlnw --null /usr/local/bin/ -e '#!/usr/bin/python' | xargs -0r cp -t /app/dockvenv/bin/ && \
    #sed -i "s/#"'!'"\/usr\/bin\/python3/#"'!'"\/usr\/bin\/env python/g" /app/dockvenv/bin/* && \
    sed -i "s/#"'!'"\/usr\/bin\/python/#"'!'"\/usr\/bin\/env python/g" /app/dockvenv/bin/* && \
    mv /app/dockvenv /root/ && \
    ln -sfT /root/dockvenv /app/dockvenv && \
    cp -rp /root/dockvenv /etc/skel/ && \
    sed -i "s/^\(PATH=\"\)\(.*\)$/\1\/app\/dockvenv\/bin\/:\2/g" /etc/environment
ENV PATH=/app/dockvenv/bin:$PATH
    # virtualenv dockvenv && \

## Node.js
## =======
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g grunt-cli

## Install dumb-init
## =================
RUN cd /tmp && \
    wget -O dumb-init.deb https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64.deb && \
    dpkg -i dumb-init.deb && \
    rm dumb-init.deb

## Create container config file
## ============================
RUN mkdir /tmp/dock_config && \
    chmod a+wrx /tmp/dock_config

## Copy scripts
## ============
RUN mkdir /app/bin && \
    chmod a=u -R /app/bin && \
    sed -i "s/^\(PATH=\"\)\(.*\)$/\1\/app\/bin\/:\2/g" /etc/environment
ENV PATH="/app/bin:$PATH"
COPY /resources/switch_user_run.sh /app/bin/switch_user_run
COPY /resources/default_notebook.sh /app/bin/default_notebook
COPY /resources/default_jupyterlab.sh /app/bin/default_jupyterlab
COPY /resources/run_server.sh /app/bin/run_server
COPY /resources/run_in_detached_tmux.sh /app/bin/run_in_detached_tmux

RUN touch /etc/skel/.sudo_as_admin_successful

## Create dockuser user
## ====================
ARG DOCKUSER_UID=4283
ARG DOCKUSER_GID=4283
RUN groupadd -g $DOCKUSER_GID dockuser && \
    useradd --system --create-home --home /home/dockuser --shell /bin/bash -G sudo -g dockuser -u $DOCKUSER_UID dockuser && \
    mkdir /tmp/runtime-dockuser && \
    chown dockuser:dockuser /tmp/runtime-dockuser && \
    echo "dockuser ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/dockuser

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

WORKDIR /root
ENTRYPOINT ["/usr/bin/dumb-init", "--", "switch_user_run"]
