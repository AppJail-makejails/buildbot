# BuildBot

The BuildBot is a system to automate the compile/test cycle required by most software projects to validate code changes. By automatically rebuilding and testing the tree each time something has changed, build problems are pinpointed quickly, before other developers are inconvenienced by the failure. The guilty developer can be identified and harassed without human intervention. By running the builds on a variety of platforms, developers who do not have the facilities to test their changes everywhere before checkin will at least know shortly afterwards whether they have broken the build or not.

buildbot.net

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Buildbot_logo.svg/2048px-Buildbot_logo.svg.png" alt="buildbot logo" width="30%" height="auto">

## How to use this Makejail

The master and worker use the `/var/db/buildbot` directory to put files only if there are no files or if the `BUILDBOT_FORCE` environment variable is set, so this means that you can mount your directory with the corresponding BuildBot files to suit your needs. If you mount a directory and there are files, the environment variables have no effect unless the `BUILDBOT_FORCE` environment variable is set.

**Note**: You can use environment variables in your configuration files (e.g. `os.getenv(...)`) using the `appjail-start(1)` `-V` parameter.

### master

```sh
mkdir -p .volumes/buildbot-master/db
appjail makejail \
    -j buildbot-master \
    -f gh+AppJail-makejails/buildbot \
    -o virtualnet=":<random> default" \
    -o nat \
    -o expose=8010 \
    -o expose=80 \
    -o fstab="$PWD/.volumes/buildbot-master/db buildbot-db <volumefs>"
appjail start \
    -V BUILDBOT_WEB_URL="http://buildbot-master:8010/" \
    buildbot-master
appjail pkg jail buildbot-master install -y git-tiny # if you want to use git(1)
```

#### Arguments

* `buildbot_master_tag` (default: `13.4-master`): see [#tags](#tags).
* `buildbot_master_ajspec` (default: `gh+AppJail-makejails/buildbot`): Entry point where the `appjail-ajspec(5)` file is located.

#### Environment (stage: build)

* `BUILDBOT_CONFIG` (default: `master.cfg`): Name of the buildmaster config file.
* `BUILDBOT_DB` (default: `sqlite:///state.sqlite`): Which DB to use for scheduler/status state.
* `BUILDBOT_LOG_COUNT` (default: `10`): Limit the number of kept old twisted log files
* `BUILDBOT_LOG_SIZE` (default: `10000000`): Size at which to rotate twisted log files
* `BUILDBOT_NOLOGROTATE` (optional): Do not permit buildmaster rotate logs by itself.

#### Environment (stage: start)

The following environment variables are only available if the Makejail has copied the `master.cfg` file from this repository, but remember that you can put any environment variable you want in your own file.

* `BUILDBOT_WORKER_NAME` (default: `example-worker`).
* `BUILDBOT_WORKER_PASS` (default: `pass`).
* `BUILDBOT_WORKER_PORT` (default: `9989`).
* `BUILDBOT_WEB_TITLE` (default: `Hello World CI`).
* `BUILDBOT_WEB_TITLEURL` (default: `https://buildbot.github.io/hello-world/`).
* `BUILDBOT_WEB_URL` (default: `http://localhost:8010/`).
* `BUILDBOT_WEB_PORT` (default: `8010`).
* `BUILDBOT_DB` (default: `sqlite:///state.sqlite`).

### worker

```sh
mkdir -p .volumes/buildbot-worker/db
appjail makejail \
    -j buildbot-worker \
    -f "gh+AppJail-makejails/buildbot --file worker.makejail" \
    -o virtualnet=":<random> default" \
    -o nat \
    -o fstab="$PWD/.volumes/buildbot-worker/db buildbot-db <volumefs>" \
    -V BUILDBOT_MASTER="buildbot-master" \
    -V BUILDBOT_WORKER_NAME="example-worker" \
    -V BUILDBOT_WORKER_PASS="pass"
appjail start buildbot-worker
appjail pkg jail buildbot-worker install -y git-tiny # if you want to use git(1)
```

#### Arguments

* `buildbot_worker_tag` (default: `13.4-worker`): see [#tags](#tags).
* `buildbot_worker_ajspec` (default: `gh+AppJail-makejails/buildbot`): Entry point where the `appjail-ajspec(5)` file is located.

#### Environment

* `BUILDBOT_INFO_ADMIN` (optional): Admin contact in a syntax like `[name] <[email]>`.
* `BUILDBOT_INFO_HOST` (optional): Description of the build.
* `BUILDBOT_KEEPALIVE` (default: `600`): Interval at which keepalives should be sent.
* `BUILDBOT_LOG_COUNT` (default: `10`): Limit the number of kept old twisted log files.
* `BUILDBOT_MAXDELAY` (default: `300`): Maximum time between connection attempts.
* `BUILDBOT_MAXRETRIES` (optional): Maximum number of retries before worker
* `BUILDBOT_NOLOGROTATE` (optional): Do not permit buildmaster rotate logs by itself.
* `BUILDBOT_NUMCPUS` (optional): Number of available cpus to use on a build.
* `BUILDBOT_PROTOCOL` (default: `pb`): Protocol to be used when creating master-worker connection.
* `BUILDBOT_PROXY_CONNECTION` (optional): Address of HTTP proxy to tunnel through.
* `BUILDBOT_LOG_SIZE` (default: `10000000`): Size at which to rotate twisted log files.
* `BUILDBOT_UMASK` (optional): Controls permissions of generated files.
* `BUILDBOT_USE_TLS` (optional): Uses TLS to connect to master.
* `BUILDBOT_MASTER` (mandatory): Address and (optionally) port of the master.
* `BUILDBOT_WORKER_NAME` (mandatory): Worker name.
* `BUILDBOT_WORKER_PASS` (mandatory): Password.

### Check current status

The custom stage `buildbot_status` can be used to run `top(1)` to check the status of BuildBot.

```sh
appjail run -s buildbot_status buildbot-master # or buildbot-worker
```

### Log

To view the log generated by the web application, run the custom stage `buildbot_log`.

```sh
appjail run -s buildbot_log buildbot-master # or buildbot-worker
```

### Volumes

| Name        | Owner | Group | Perm | Type | Mountpoint        |
| ----------- | ----- | ----- | ---- | ---- | ----------------- |
| buildbot-db | 870   | 870   |  -   |  -   | /var/db/buildbot  |

## Tags

| Tag    | Arch    | Version        | Type   |
| ------ | ------- | -------------- | ------ |
| `13.4-master` | `amd64` | `13.4-RELEASE` | `thin` |
| `13.4-worker` | `amd64` | `13.4-RELEASE` | `thin` |
| `14.2-master` | `amd64` | `14.2-RELEASE` | `thin` |
| `14.2-worker` | `amd64` | `14.2-RELEASE` | `thin` |
