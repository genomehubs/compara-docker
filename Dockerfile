# DOCKER-VERSION 1.12.3

FROM genomehubs/easy-import:19.05
MAINTAINER Richard Challis / Lepbase contact@lepbase.org

ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive

USER root
RUN cpanm Parallel::ForkManager

RUN apt-get update && apt-get install -y -q g++ default-jre

WORKDIR /root
#RUN wget https://mafft.cbrc.jp/alignment/software/mafft-7.427-without-extensions-src.tgz 2>/dev/null
#RUN tar xzf mafft-7.427-without-extensions-src.tgz

#RUN wget --no-check-certificate https://www.bioinf.uni-leipzig.de/Software/noisy/Noisy-1.5.12.tar.gz 2>/dev/null
#RUN tar xzf Noisy-1.5.12.tar.gz

#RUN wget https://www.micans.org/mcl/src/mcl-14-137.tar.gz 2>/dev/null \
#    && tar xzf mcl-14-137.tar.gz

#WORKDIR /root/mcl-14-137
#RUN ./configure --prefix=/usr/local 

#WORKDIR /root/mcl-14-137/src/mcl
#RUN make && make install

RUN apt-get update && apt-get -y install fasttree iqtree mcl

WORKDIR /root
RUN wget https://gite.lirmm.fr/atgc/FastME/raw/master/tarball/fastme-2.1.6.1.tar.gz 2>/dev/null \
    && tar xzf fastme-2.1.6.1.tar.gz

WORKDIR fastme-2.1.6.1
RUN ./configure && make && make install

WORKDIR /root
RUN wget http://github.com/bbuchfink/diamond/releases/download/v0.9.24/diamond-linux64.tar.gz 2>/dev/null \
    && tar xzf diamond-linux64.tar.gz \
    && mv diamond /usr/local/bin/

RUN wget https://mafft.cbrc.jp/alignment/software/mafft-7.427-without-extensions-src.tgz 2>/dev/null
RUN tar xzf mafft-7.427-without-extensions-src.tgz

WORKDIR /root/mafft-7.427-without-extensions/core
RUN make && make install

WORKDIR /root
RUN wget https://github.com/stamatak/standard-RAxML/archive/v8.2.12.tar.gz 2>/dev/null
RUN tar xzf v8.2.12.tar.gz

WORKDIR /root
RUN wget https://github.com/davidemms/OrthoFinder/releases/download/2.3.3/OrthoFinder-2.3.3.tar.gz 2>/dev/null \
    && tar xzf OrthoFinder-2.3.3.tar.gz \
    && mv OrthoFinder-2.3.3/orthofinder /usr/local/bin \
    && mv OrthoFinder-2.3.3/config.json /usr/local/bin

RUN wget --no-check-certificate https://www.bioinf.uni-leipzig.de/Software/noisy/Noisy-1.5.12.tar.gz 2>/dev/null \
    && tar xzf Noisy-1.5.12.tar.gz 
WORKDIR /root/Noisy-1.5.12
RUN ./configure && make && make install

WORKDIR /root/standard-RAxML-8.2.12
RUN make -f Makefile.SSE3.PTHREADS.gcc
RUN rm *.o
RUN cp raxmlHPC* /usr/local/bin/

WORKDIR /root
RUN wget https://github.com/soedinglab/MMseqs2/releases/download/9-d36de/MMseqs2-Linux-AVX2.tar.gz 2>/dev/null \
    && tar xzf MMseqs2-Linux-AVX2.tar.gz \
    && mv mmseqs2/bin/mmseqs /usr/local/bin/

#WORKDIR /
#RUN wget http://goby.compbio.cs.cmu.edu/Notung/Notung-2.9.zip 2>/dev/null
#RUN unzip Notung-2.9.zip
#RUN chmod -R a+rx /Notung-2.9

RUN wget https://github.com/scapella/trimal/archive/v1.4.1.tar.gz 2>/dev/null \
    && tar xzf v1.4.1.tar.gz

WORKDIR /root/trimal-1.4.1/source

RUN make && mv *al /usr/local/bin/

WORKDIR /root

RUN wget https://github.com/amkozlov/raxml-ng/releases/download/0.9.0/raxml-ng_v0.9.0_linux_x86_64.zip 2>/dev/null \
    && unzip raxml-ng_v0.9.0_linux_x86_64.zip

RUN mv raxml-ng /usr/local/bin

#RUN wget https://www.hiv.lanl.gov/repository/aids-db/PROGS/Snap/Snap.tar.gz 2>/dev/null \
#    && tar xzf Snap.tar.gz

#RUN ls Snap

#RUN mv Snap /Snap

#RUN chmod -R 755 /Snap

#RUN cpanm IPC::Run3

#WORKDIR /root

RUN git clone https://github.com/veg/hyphy.git

RUN apt-get update && apt-get install -y gcc libcurl4 libc6 libomp-dev

RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.2/cmake-3.15.2.tar.gz 2>/dev/null \
    && tar -xzf cmake-3.15.2.tar.gz

WORKDIR /root/cmake-3.15.2

RUN ./bootstrap && make -j4 && make install

WORKDIR /root/hyphy

RUN cmake . && make install

COPY ./config.json /usr/local/bin/config.json

WORKDIR /ensembl/easy-import
USER eguser
ARG  cachebuster=0b7a2f8ca
RUN  git pull origin 19.05 && git submodule update --recursive

COPY startup.sh /import/
USER root
RUN chmod 777 /import/startup.sh
USER eguser

CMD /import/startup.sh $FLAGS
