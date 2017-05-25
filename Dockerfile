# DOCKER-VERSION 1.12.3

FROM genomehubs/easy-import:latest
MAINTAINER Sujai Kumar / Lepbase contact@lepbase.org

ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive

USER root
RUN cpanm Parallel::ForkManager

RUN apt-get install -y -q g++ default-jre

WORKDIR /root
RUN wget http://mafft.cbrc.jp/alignment/software/mafft-7.222-without-extensions-src.tgz 2>/dev/null
RUN tar xzf mafft-7.222-without-extensions-src.tgz

RUN wget --no-check-certificate https://www.bioinf.uni-leipzig.de/Software/noisy/Noisy-1.5.12.tar.gz 2>/dev/null
RUN tar xzf Noisy-1.5.12.tar.gz

RUN wget https://github.com/stamatak/standard-RAxML/archive/v8.2.10.tar.gz 2>/dev/null
RUN tar xzf v8.2.10.tar.gz

WORKDIR /root/mafft-7.222-without-extensions/core
RUN make && make install

WORKDIR /root/Noisy-1.5.12
RUN ./configure && make && make install

WORKDIR /root/standard-RAxML-8.2.10
RUN make -f Makefile.SSE3.PTHREADS.gcc
RUN rm *.o
RUN cp raxmlHPC* /usr/local/bin

WORKDIR /
RUN wget http://goby.compbio.cs.cmu.edu/Notung/Notung-2.9.zip 2>/dev/null
RUN unzip Notung-2.9.zip
RUN chmod -R a+rx /Notung-2.9

WORKDIR /ensembl/easy-import
USER eguser
ARG  cachebuster=0b7a248ca
RUN  git pull origin develop && git submodule update --recursive

COPY startup.sh /import/

ENV PATH $PATH:/root/mafft-7.222-without-extensions/binaries

CMD /import/startup.sh $FLAGS
