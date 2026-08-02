# Buildbot

Buildbot is a system to automate the compile/test cycle required by most software projects to validate code changes. By automatically rebuilding and testing the tree each time something has changed, build problems are pinpointed quickly, before other developers are inconvenienced by the failure. The guilty developer can be identified and harassed without human intervention. By running the builds on a variety of platforms, developers who do not have the facilities to test their changes everywhere before checkin will at least know shortly afterwards whether they have broken the build or not.

wikipedia.org/wiki/Buildbot

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Buildbot_logo.svg/250px-Buildbot_logo.svg.png" width="30%" height="auto" alt="Buildbot logo">

## How to use this Makejail

Both the master and the worker may require external dependencies. You can create a new OCI image with the dependencies you need or use the `pkg` option as shown below.

**Master**:

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -e BUILDBOT_CONFIG_DIR=/config \
    -e BUILDBOT_CONFIG_URL=https://github.com/buildbot/buildbot-docker-example-config/archive/master.tar.gz \
    -e BUILDBOT_WORKER_PORT=9989 \
    -e BUILDBOT_WEB_URL=http://buildbot-master:8010/ \
    -e BUILDBOT_WEB_PORT=tcp:port=8010 \
    -o pkg=git-tiny \
    ghcr.io/appjail-makejails/buildbot buildbot-master
```

**Worker**:

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -e BUILDMASTER=buildbot-master \
    -e BUILDMASTER_PORT=9989 \
    -e WORKERNAME=example-worker \
    -e WORKERPASS=pass \
    -e WORKER_ENVIRONMENT_BLACKLIST="DOCKER_BUILDBOT* BUILDBOT_ENV_* BUILDBOT_1* WORKER_ENVIRONMENT_BLACKLIST" \
    -o pkg=git-tiny \
    -o pkg=py312-pyflakes \
    ghcr.io/appjail-makejails/buildbot:15.1-worker buildbot-worker
```

---

You should now be able to go to http://buildbot-master:8010 and see a web page similar to:

![](https://docs.buildbot.net/latest/_images/index.png)

Click on “Builds” at the left to open the submenu and then [Builders](http://buildbot-master:8010/#/builders) to see that the worker you just started has connected to the master:

![](https://docs.buildbot.net/latest/_images/builders.png)

### Arguments (stage: build)

* `buildbot_from` (default: `ghcr.io/appjail-makejails/buildbot`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `buildbot_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).

### Environment (OCI image)

* `PGID` (default: `1000`): Equivalent to `PUID` but for the Process Group ID.
* `PUID` (default: `1000`): Process User ID for the container's main process, allowing you to match the owner of files written to mounted host volumes to your host system's user. Writable volumes are changed based on this environment variable.

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1-master
      containerfile: Containerfile.master
      aliases: ["latest"]
      default: true
      args:
        FREEBSD_RELEASE: "15.1"
        PYVER: "312"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
    - tag: 15.1-worker
      containerfile: Containerfile.worker
      args:
        FREEBSD_RELEASE: "15.1"
        PYVER: "312"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```
