Change Log
==========

All user visible changes to this project will be documented in this file. This project uses to [Semantic Versioning 2.0.0].




## [0.4.0] · 2026-??-??
[0.4.0]: /../../tree/v0.4.0

[Diff](/../../compare/v0.3.1...v0.4.0) | [Milestone](/../../milestone/7)

### Added

- UI:
    - Wallet tab:
        - PayPal deposit. ([#23])
    - Chat page:
        - Donations. ([#27])

### Changed

- UI:
    - Monetization tab:
        - Operations with pagination on transaction page. ([#26])
    - Wallet tab:
        - Operations with pagination on transaction page. ([#26])

[#23]: /../../pull/23
[#26]: /../../pull/26
[#27]: /../../pull/27




## [0.3.1] · 2026-02-11
[0.3.1]: /../../tree/v0.3.1

[Diff](/../../compare/v0.3.0...v0.3.1) | [Milestone](/../../milestone/6)

### Fixed

- UI:
    - Media panel:
        - Enabled video sometimes not being seen by participants. ([team113/messenger#1602])
        - Call buttons dragged from dock to panel are being left hanging on screen. ([team113/messenger#1602])

[team113/messenger#1602]: https://github.com/team113/messenger/pull/1602




## [0.3.0] · 2026-02-05
[0.3.0]: /../../tree/v0.3.0

[Diff](/../../compare/v0.2.2...v0.3.0) | [Milestone](/../../milestone/5)

### Added

- UI:
    - Wallet tab:
        - Deposit methods. ([#20])

### Changed

- UI:
    - Profile page:
        - Allow name to be 1 symbols long. ([team113/messenger#1600])

### Fixed

- Web:
    - Chats tab:
        - Default context menu displayed when pressing on first chat. ([#21])

[#20]: /../../pull/20
[#21]: /../../pull/21
[team113/messenger#1600]: https://github.com/team113/messenger/pull/1600




## [0.2.2] · 2026-02-02
[0.2.2]: /../../tree/v0.2.2

[Diff](/../../compare/v0.2.1...v0.2.2) | [Milestone](/../../milestone/4)

### Added

- Mobile:
    - Media panel:
        - Output device modal being displayed when any external device is connected. ([team113/messenger#1596], [team113/messenger#1593])

### Changed

- UI:
    - Redesigned deposit page on desktop to be only in tab. ([#18])
    - User page:
        - Join and decline call buttons. ([team113/messenger#1597])

### Fixed

- UI:
    - Media panel:
        - Camera disabling for remote peers when disable screen sharing. ([team113/messenger#1594])
- iOS:
    - Dialogue calls not being connected sometimes. ([team113/messenger#1594])
    - Output device not switching to headphones or not displaying being switched. ([team113/messenger#1593])

[#18]: /../../pull/18
[team113/messenger#1593]: https://github.com/team113/messenger/pull/1593
[team113/messenger#1594]: https://github.com/team113/messenger/pull/1594
[team113/messenger#1596]: https://github.com/team113/messenger/pull/1596
[team113/messenger#1597]: https://github.com/team113/messenger/pull/1597




## [0.2.1] · 2026-01-27
[0.2.1]: /../../tree/v0.2.1

[Diff](/../../compare/v0.2.0...v0.2.1) | [Milestone](/../../milestone/3)

### Fixed

- UI:
    - Login modal:
        - Invalid accounts being displayed in accounts list. ([#16])
    - Media panel:
        - Camera disabling for remote peers when disable screen sharing. ([team113/messenger#1594])
- iOS:
    - Dialogue calls not being connected sometimes. ([team113/messenger#1594])

[#16]: /../../pull/16
[team113/messenger#1594]: https://github.com/team113/messenger/pull/1594




## [0.2.0] · 2026-01-21
[0.2.0]: /../../tree/v0.2.0

[Diff](/../../compare/v0.1.0...v0.2.0) | [Milestone](/../../milestone/2)

### Added

- UI:
    - Media panel:
        - Reconnecting notifications when network changes in call. ([team113/messenger#1581])
    - Chat page:
        - Logs button in notes and support chats. ([#12])

### Fixed

- UI:
    - Media panel:
        - Infinite vibration when ringing pending calls on iOS and Android. ([team113/messenger#1580])
        - Connection not being reconnected on network changes on Web. ([team113/messenger#1581])
        - Own camera or recipient's video sometimes not being rendered. ([team113/messenger#1582])
        - Raised hand appearing on display demonstrations. ([team113/messenger#1584])

[#12]: /../../pull/12
[team113/messenger#1580]: https://github.com/team113/messenger/pull/1580
[team113/messenger#1581]: https://github.com/team113/messenger/pull/1581
[team113/messenger#1582]: https://github.com/team113/messenger/pull/1582
[team113/messenger#1584]: https://github.com/team113/messenger/pull/1584




## [0.1.0] · 2026-01-15
[0.1.0]: /../../tree/v0.1.0

[Diff](/../../compare/70ddb0e8375b57f9c1d8f5d69f9e25407915bc34...v0.1.0) | [Milestone](/../../milestone/1)

### Added

- UI:
    - Home page:
        - Wallet and monetization tabs. ([#2])
    - Wallet tab:
        - Top up and transactions pages. ([#4])
    - Monetization tab:
        - Partner programs and your promotion pages. ([#4])
        - Set your prices, transactions and withdrawal pages. ([#5])
    - Support chat. ([#6])
- Deployment:
    - [Helm] chart. ([#1])

[#1]: /../../pull/1
[#2]: /../../pull/2
[#4]: /../../pull/4
[#5]: /../../pull/5
[#6]: /../../pull/6




[Helm]: https://helm.sh
[Semantic Versioning 2.0.0]: https://semver.org
