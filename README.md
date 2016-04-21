# Dockerfile for Winery

----

### IMPORTANT: This Dockerfile is not actively maintained. Please consider using https://github.com/jojow/opentosca-dockerfiles

----

Use this Dockerfile to run the latest version of [Winery](http://www.eclipse.org/proposals/soa.winery):

    docker run -p 8080:8080 -d johannesw/winery

Then access

    http://<DOCKERHOST>:8080/winery

using your favorite Web browser. If you run Docker locally, `<DOCKERHOST>` is `localhost`. If you use Boot2docker (e.g., on Windows or Mac OS X), `<DOCKERHOST>` is `192.168.59.103`.

## Build fresh image from Dockerfile

If you prefer to build a fresh image from the Dockerfile:

    docker build -t johannesw/winery github.com/jojow/winery-dockerfile
