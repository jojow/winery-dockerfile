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
RUN git clone --recursive git://git.eclipse.org/gitroot/winery/org.eclipse.winery.git -b ${WINERY_BRANCH}
RUN cd org.eclipse.winery && git checkout ${WINERY_REV} && git reset --hard

# Build models using maven
RUN cd org.eclipse.winery/org.eclipse.winery.model.csar.toscametafile && mvn install
RUN cd org.eclipse.winery/org.eclipse.winery.model.selfservice && mvn install
RUN cd org.eclipse.winery/org.eclipse.winery.model.tosca && mvn install

# Build winery using maven
RUN cd org.eclipse.winery && mvn clean package

# Drop winery into tomcat
RUN cp org.eclipse.winery/org.eclipse.winery.repository/target/winery.war /opt/tomcat/webapps/
RUN cp org.eclipse.winery/org.eclipse.winery.topologymodeler/target/winery-topologymodeler.war /opt/tomcat/webapps/
