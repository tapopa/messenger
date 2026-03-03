`tapopa-messenger` Helm chart changelog
=======================================

All user visible changes to this project will be documented in this file. This project uses [Semantic Versioning 2.0.0].




## [0.1.1] · 2026-03-03
[0.1.1]: https://github.com/tapopa/messenger/tree/helm%2Ftapopa-messenger%2F0.1.1/helm/tapopa-messenger

### Added

- `/geo-ip` [Nginx] proxy forwarding to `ip-api.com` geo IP fetching service. ([team113/messenger#1620])

[team113/messenger#1620]: https://github.com/team113/messenger/pull/1620




## [0.1.0] · 2026-01-15
[0.1.0]: https://github.com/tapopa/messenger/tree/helm%2Ftapopa-messenger%2F0.1.0/helm/tapopa-messenger

### Added

- `Service` with `tapopa-messenger` and optional `sftp` containers. ([#1])
- `Ingress` with: ([#1])
    - `/` prefix pointing to `tapopa` container.
    - `tls.auto` capabilities.
    - Handling optional `www.` domain part.
- Ability to specify application's configuration. ([#1])

[#1]: https://github.com/tapopa/messenger/pull/1




[Nginx]: https://nginx.org
[Semantic Versioning 2.0.0]: https://semver.org
