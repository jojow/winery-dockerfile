FROM jolokia/tomcat-7.0

MAINTAINER Johannes Wettinger, http://github.com/jojow

# Specify branch and revision of winery
ENV WINERY_BRANCH master
ENV WINERY_REV HEAD

ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/opt/apache-maven-3.2.1/bin/

# Add PPA repository to get latest version of node.js
RUN add-apt-repository ppa:chris-lea/node.js

# Install and configure dependencies
RUN apt-get update && apt-get install -y git nodejs && apt-get clean
RUN wget http://artfiles.org/apache.org/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.tar.gz && \
        tar -zxf apache-maven-3.2.1-bin.tar.gz && \
        cp -R apache-maven-3.2.1 /opt
RUN npm install -g bower

# Get winery sources
WORKDIR /opt
RUN git clone --recursive git://git.eclipse.org/gitroot/winery/org.eclipse.winery.git -b ${WINERY_BRANCH}
WORKDIR /opt/org.eclipse.winery
RUN git checkout ${WINERY_REV} && git reset --hard

# Build models using maven
WORKDIR /opt/org.eclipse.winery/org.eclipse.winery.model.csar.toscametafile
RUN mvn install
WORKDIR /opt/org.eclipse.winery/org.eclipse.winery.model.selfservice
RUN mvn install
WORKDIR /opt/org.eclipse.winery/org.eclipse.winery.model.tosca
RUN mvn install

# Build winery using maven
WORKDIR /opt/org.eclipse.winery
RUN mvn clean package

# Drop winery into tomcat
RUN cp /opt/org.eclipse.winery/org.eclipse.winery.repository/target/winery.war /opt/tomcat/webapps/
RUN cp /opt/org.eclipse.winery/org.eclipse.winery.topologymodeler/target/winery-topologymodeler.war /opt/tomcat/webapps/
