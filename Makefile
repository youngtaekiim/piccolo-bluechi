# SPDX-FileCopyrightText: Copyright 2024 LG Electronics Inc.
# SPDX-License-Identifier: Apache-2.0

.PHONY: default build
build:
	cargo build --manifest-path=src/Cargo.toml

.PHONY: release
release:
	cargo build --manifest-path=src/Cargo.toml --release

.PHONY: tool
tool:
	cargo build --manifest-path=src/tools/Cargo.toml

.PHONY: clean
clean:
	cargo clean --manifest-path=src/Cargo.toml
	cargo clean --manifest-path=src/tools/Cargo.toml

# Section for podman-kube workload - START
.PHONY: image
image:
	podman build -t piccolo:1.0 -f containers/Dockerfile .

.PHONY: pre
pre:
	-mkdir /root/piccolo_yaml
	-cp -r examples/resources/* /root/piccolo_yaml/
	-mkdir /etc/containers/systemd/piccolo/
	-podman-compose -f examples/nginx/docker-compose.yaml up -d

.PHONY: install
install:
	-cp -r ./piccolo.ini /etc/containers/systemd/piccolo/
	-cp -r ./containers/piccolo.* /etc/containers/systemd/piccolo/
	-cp -r ./etcd-data /etc/containers/systemd/piccolo/etcd-data/
	systemctl daemon-reload
	systemctl start piccolo

.PHONY: uninstall
uninstall:
	-systemctl stop piccolo
	systemctl daemon-reload

.PHONY: post
post:
	-rm -rf /root/piccolo_yaml
	-rm -rf /etc/containers/systemd/*
	-podman-compose -f examples/nginx/docker-compose.yaml down
	-podman pod rm -f bms-blis
	-podman pod rm -f bms-frism
	-podman pod rm -f bms-mavd
	-podman pod rm -f bms-rdv
	systemctl daemon-reload

.PHONY: tinstall
tinstall:
	-mkdir /etc/containers/systemd/piccolo-test/
	-cp -r ./examples/version-display/qt-msg-sender/qt-sender.* /etc/containers/systemd/piccolo-test/
	systemctl daemon-reload
	systemctl start qt-sender

.PHONY: tuninstall
tuninstall:
	-systemctl stop version-display.service
	-systemctl stop qt-sender
	-rm -rf /etc/containers/systemd/version-display.kube
	-rm -rf /etc/containers/systemd/piccolo-test/
	systemctl daemon-reload

.PHONY: cinstall
cinstall:
	-mkdir /etc/containers/systemd/piccolo-test/
	-cp -r ./examples/version-cli/msg-sender/cli-dds-sender.* /etc/containers/systemd/piccolo-test/
	systemctl daemon-reload
	systemctl start cli-dds-sender

.PHONY: cuninstall
cuninstall:
	-systemctl stop version-cli.service
	-systemctl stop cli-dds-sender
	-rm -rf /etc/containers/systemd/version-cli.kube
	-rm -rf /etc/containers/systemd/piccolo-test/
	systemctl daemon-reload
# Section for podman-kube workload - END
