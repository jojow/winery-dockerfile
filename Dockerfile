FROM dockerfile/ubuntu

MAINTAINER Johannes Wettinger, http://github.com/jojow

# Specify branch and revision of winery
ENV WINERY_BRANCH master
ENV WINERY_REV HEAD

ENV MAVEN_VERSION 3.2.2
ENV TOMCAT_VERSION 7.0.54

ENV DEBIAN_FRONTEND noninteractive
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:/opt/apache-maven-${MAVEN_VERSION}/bin/:${CATALINA_HOME}/bin

# Add PPA repository to get latest version of node.js
RUN add-apt-repository ppa:chris-lea/node.js

# Install and configure dependencies
RUN apt-get update && apt-get install -y git nodejs openjdk-7-jdk && apt-get clean
RUN wget http://artfiles.org/apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
        tar -zxf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
        cp -R apache-maven-${MAVEN_VERSION} /opt
RUN npm install -g bower

# Install tomcat (inspired by jolokia/tomcat-7.0)
RUN wget http://archive.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/catalina.tar.gz && \
        tar -zxf /tmp/catalina.tar.gz -C /opt && \
        ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
        rm /tmp/catalina.tar.gz

# Remove unneeded stuff
RUN rm -rf /opt/tomcat/webapps/examples && rm -rf /opt/tomcat/webapps/docs

# Replace 'random' with 'urandom' for quicker startups
RUN rm /dev/random && ln -s /dev/urandom /dev/random

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

CMD [ "/opt/tomcat/bin/catalina.sh", "run" ]
