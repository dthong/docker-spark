FROM sequenceiq/hadoop-docker:2.7.1
MAINTAINER SequenceIQ

# support for Hadoop 2.7.0
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-2.0.2-bin-hadoop2.7.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-2.0.2-bin-hadoop2.7 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-2.0.2-bin-hadoop2.7/jars /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin
# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

# install R
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum -y install R

# install Python 2.7 and packages
#RUN yum install centos-release-scl \
  #&& yum-config-manager --enable rhel-server-rhscl-7-rpms \
  #&& yum install python27 \
  #&& scl enable python27 bash \
  #&& pip install --upgrade pip

# install anaconda packages
RUN curl -s https://repo.continuum.io/archive/Anaconda2-4.2.0-Linux-x86_64.sh -o anaconda.sh
RUN chmod a+x anaconda.sh
RUN ./anaconda.sh -b
RUN /root/anaconda2/bin/conda install -y -q ipython notebook
RUN /root/anaconda2/bin/python -m nltk.downloader all

# install python packages
RUN pip install google-apputils
RUN pip install python-gflags
RUN pip install arrow
RUN pip install gensim
RUN pip install ftfy

#Environment vaiables for Spark to use Anaconda Python and iPython notebook
ENV PYSPARK_PYTHON /root/anaconda2/bin/python
ENV PYSPARK_DRIVER_PYTHON /root/anaconda2/bin/ipython
ENV PYSPARK_DRIVER_PYTHON_OPTS "notebook --no-browser --port=8888 --ip='*'"


ENTRYPOINT ["/etc/bootstrap.sh"]
