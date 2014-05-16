# Dockerfile for Winery

Use this Dockerfile to run the latest version of [Winery](http://www.eclipse.org/proposals/soa.winery):

    docker run -p 8080:8080 -d johannesw/winery

Then access

    http://localhost:8080/winery

using your favorite Web browser.

## Build fresh image from Dockerfile

If you prefer to build a fresh image from the Dockerfile:

    docker build -t johannesw/winery github.com/jojow/winery-dockerfile
