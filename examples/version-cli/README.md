<!--
SPDX-License-Identifier: Apache-2.0
-->

# version-cli example

In this example, we will run a simple app as container that displays the version name.
At this time, it shows the process of updating or rolling back the app according to pre-specified conditions through `Piccolo`.

## Run the example

### Build test application

This container image only show `version:x.0` in monitor.

```bash
# in 'examples/version-display/app' directory
podman build --no-cache --build-arg VERSION=1.0 -t version-cli:1.0 .
podman build --no-cache --build-arg VERSION=2.0 -t version-cli:2.0 .
```

You can see

```Text
# podman images
REPOSITORY                   TAG   IMAGE ID      CREATED        SIZE
...
localhost/version-cli    2.0   d1b0cd9eb6c2  12 hours ago   566 MB
localhost/version-cli    1.0   892206770723  12 hours ago   566 MB
...
```

### Build dds message sender

There is a msg sender application written in pyqt.

```bash
# in 'examples/version-cli/msg-sender/cli-dds-sender' directory
podman build --no-cache -t cli-dds-sender:1.0 .
```

You can see,

```Text
# podman images
localhost/cli-dds-sender    1.0   7a9e5b7a6580  7 hours ago    917 MB
```

### Running Piccolo

If you have some problems during this section, refer to [Getting started - installation](/doc/docs/getting-started.md#installation).

```bash
# in top folder,
make image
```

Then,

```Text
# podman images
REPOSITORY                   TAG     IMAGE ID      CREATED        SIZE
localhost/piccolo-gateway    1.0     5df0f9b55414  4 hours ago    84.7 MB
localhost/piccolo            1.0     590a847ef028  4 hours ago    36.3 MB
```

Now,

```bash
# in top folder,
make install
```

You can find,

```Text
# podman ps | grep piccolo
fe7721ed  localhost/piccolo:1.0                  ...   piccolo-yamlparser
8fc4a363  localhost/piccolo:1.0                  ...   piccolo-api-server
52842bbf  localhost/piccolo:1.0                  ...   piccolo-statemanager
0083aafd  gcr.io/etcd-development/etcd:v3.5.11   ...   piccolo-etcd
1ac934af  localhost/piccolo-gateway:1.0          ...   piccolo-gateway

# tree /root/piccolo_yaml/version-display/
/root/piccolo_yaml/version-display/
├── version-display_1.0.kube
├── version-display_1.0.yaml
├── version-display_2.0.kube
└── version-display_2.0.yaml

# tree /etc/containers/systemd/
/etc/containers/systemd/
└── piccolo
    ├── etcd-data
    │   └── member
    │       ├── ...
    │       └── ...
    ├── example
    ├── piccolo.kube
    └── piccolo.yaml
```

### Running container example

```bash
make tinstall
```

Then there are two X11 applications.  
(Now, there are two more button `launch`, `terminate` in gRPC sender.)

<img alt="pyqt sender" src="../../doc/images/pyqt-sender.png"
width="60%"
height="60%"
/>

Now, if you press the following buttons sequentially, the color of buttons are changed to green.

1. update button (in Qt gRPC sender)
2. parking (in Qt button Example...)

And, you can see version-display container window.

<img alt="version 2" src="../../doc/images/ver-display-2.png"
width="40%"
height="40%"
/>

If you do not see this window, check the status of service.

```bash
systemctl status bluechi-agent.service
```

Simillary, if you press the following buttons sequentially, the color of buttons are changed to green.

1. rollback button (in Qt gRPC sender)
2. reverse (in Qt button Example...)

<img alt="version 1" src="../../doc/images/ver-display-1.png"
width="40%"
height="40%"
/>

Additionally, the `launch` and `terminate` buttons also receive parking DDS message and operate similarly.

### Clean up

```bash
make uninstall
make tuninstall
```

<!-- markdownlint-disable-file MD033 -->