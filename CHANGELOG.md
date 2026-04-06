Change Log
==========

All user visible changes to this project will be documented in this file. This project uses to [Semantic Versioning 2.0.0].




## [0.5.0] · 2026-??-??
[0.5.0]: /../../tree/v0.5.0

[Diff](/../../compare/v0.4.0...v0.5.0) | [Milestone](/../../milestone/13)

### Changed

- UI:
    - Currency symbol. ([#46])
    - Tap ID visual appearance. ([#46])
    - Chat page:
        - Tapping on Tap ID sent in message opens chat with user. ([#46])
    - Monetization tab:
        - Updated icons and texts. ([#47])
        - Links statistics page. ([#48], [#47])
        - Display total balances in transactions. ([#49])
        - Your prices page texts, blocks and illustrations. ([#49])
        - Your promotion page texts, blocks and illustrations. ([#49])
        - Your partner page texts, blocks and illustrations. ([#49])
    - Chats tab:
        - Display welcome message when searching users. ([team113/messenger#1671])
        - Support service in chats context menu. ([team113/messenger#1677])
    - User page:
        - Allow creating multiple direct links to chat. ([team113/messenger#1674])
    - Media panel:
        - Context menu missing from dialog calls on mobiles. ([team113/messenger#1666])
        - Outgoing ringtone sometimes being played for less than 2 seconds. ([team113/messenger#1676])
    - Chat page:
        - Gaps between selected messages. ([team113/messenger#1666])
        - Notes being present two times in forwarding modal. ([team113/messenger#1668])
    - Profile page:
        - Session termination opening with an error. ([team113/messenger#1675])
        - Grey rectangle displayed in cache block on native platforms. ([team113/messenger#1678])

### Fixed

- UI:
    - Media panel:
        - Context menu missing from dialog calls on mobiles. ([team113/messenger#1666])
    - Chat page:
        - Gaps between selected messages. ([team113/messenger#1666])

[#46]: /../../pull/46
[#47]: /../../pull/47
[#48]: /../../pull/48
[#49]: /../../pull/49
[team113/messenger#1666]: https://github.com/team113/messenger/pull/1666
[team113/messenger#1668]: https://github.com/team113/messenger/pull/1668
[team113/messenger#1671]: https://github.com/team113/messenger/pull/1671
[team113/messenger#1674]: https://github.com/team113/messenger/pull/1674
[team113/messenger#1675]: https://github.com/team113/messenger/pull/1675
[team113/messenger#1676]: https://github.com/team113/messenger/pull/1676
[team113/messenger#1677]: https://github.com/team113/messenger/pull/1677
[team113/messenger#1678]: https://github.com/team113/messenger/pull/1678




## [0.4.0] · 2026-03-27
[0.4.0]: /../../tree/v0.4.0

[Diff](/../../compare/v0.3.6...v0.4.0) | [Milestone](/../../milestone/12)

### Changed

- UI:
    - Support page. ([team113/messenger#1660])
    - Chats tab:
        - Display about information when searching users. ([team113/messenger#1659])
    - Profile page:
        - Allow creating multiple direct links to chat. ([team113/messenger#1664])
    - Login modal. ([#42], [#41])
- Web:
    - Page loader. ([#42])

### Fixed

- UI:
    - Media panel:
        - Inability to drag-n-drop buttons in dock. ([team113/messenger#1654])
        - Incoming video being disabled when disabling screen sharing only. ([team113/messenger#1662])
- macOS:
    - Application crashing when exiting. ([team113/messenger#1657], [team113/messenger#1561])
- Windows:
    - Unsupported devices displayed in output devices list for Windows 10. ([team113/messenger#1643])

[#41]: /../../pull/41
[#42]: /../../pull/42
[team113/messenger#1561]: https://github.com/team113/messenger/issues/1561
[team113/messenger#1643]: https://github.com/team113/messenger/pull/1643
[team113/messenger#1654]: https://github.com/team113/messenger/pull/1654
[team113/messenger#1657]: https://github.com/team113/messenger/pull/1657
[team113/messenger#1659]: https://github.com/team113/messenger/pull/1659
[team113/messenger#1660]: https://github.com/team113/messenger/pull/1660
[team113/messenger#1662]: https://github.com/team113/messenger/pull/1662
[team113/messenger#1664]: https://github.com/team113/messenger/pull/1664




## [0.3.6] · 2026-03-16
[0.3.6]: /../../tree/v0.3.6

[Diff](/../../compare/v0.3.5...v0.3.6) | [Milestone](/../../milestone/11)

### Changed

- UI: 
    - Chats tab:
        - Avatar for support. ([#39])

[#39]: /../../pull/39




## [0.3.5] · 2026-03-16
[0.3.5]: /../../tree/v0.3.5

[Diff](/../../compare/v0.3.4...v0.3.5) | [Milestone](/../../milestone/10)

### Added

- UI:
    - Profile page:
        - Added help and sign out blocks. ([team113/messenger#1638])

### Changed

- UI:
    - Chat info page:
        - Redesigned links block. ([team113/messenger#1644], [team113/messenger#1642], [team113/messenger#1638])
    - Profile page:
        - Redesigned links, cache and media devices blocks. ([team113/messenger#1644], [team113/messenger#1638])
    - Chats tab:
        - Avatar for support chats. ([team113/messenger#1646])
    - Chat page:
        - Media attachments displayed in column instead of grid. ([team113/messenger#1651], [team113/messenger#1647])

### Fixed

- UI:
    - Chat page:
        - Welcome message displayed at bottom instead of top. ([team113/messenger#1649])
    - Media panel:
        - Click cursor missing when hovering over dock buttons on macOS. ([team113/messenger#1651])

[team113/messenger#1638]: https://github.com/team113/messenger/pull/1638
[team113/messenger#1642]: https://github.com/team113/messenger/pull/1642
[team113/messenger#1644]: https://github.com/team113/messenger/pull/1644
[team113/messenger#1646]: https://github.com/team113/messenger/pull/1646
[team113/messenger#1647]: https://github.com/team113/messenger/pull/1647
[team113/messenger#1649]: https://github.com/team113/messenger/pull/1649
[team113/messenger#1651]: https://github.com/team113/messenger/pull/1651




## [0.3.4] · 2026-03-10
[0.3.4]: /../../tree/v0.3.4

[Diff](/../../compare/v0.3.3...v0.3.4) | [Milestone](/../../milestone/9)

### Added

- UI:
    - Profile page:
        - Display input volume for selected microphone. ([team113/messenger#1634])

### Changed

- UI:
    - Chats tab:
        - Redesigned searching. ([team113/messenger#1630])
    - Horizontal application scroll when window's width is less than 300px. ([team113/messenger#1632])
    - Chat page:
        - Redesigned attachments buttons. ([team113/messenger#1633])
        - Redesigned desktop player. ([team113/messenger#1636])
    - Media panel:
        - Increased camera resolution to 960x720. ([team113/messenger#1637])

### Fixed

- UI:
    - Player:
        - Screen turning dark when double pressing escape. ([team113/messenger#1629])
    - Freelance page:
        - Multiline lines displayed in a single line. ([team113/messenger#1617], [team113/messenger#544])

[team113/messenger#544]: https://github.com/team113/messenger/issues/544
[team113/messenger#1617]: https://github.com/team113/messenger/pull/1617
[team113/messenger#1629]: https://github.com/team113/messenger/pull/1629
[team113/messenger#1630]: https://github.com/team113/messenger/pull/1630
[team113/messenger#1632]: https://github.com/team113/messenger/pull/1632
[team113/messenger#1633]: https://github.com/team113/messenger/pull/1633
[team113/messenger#1634]: https://github.com/team113/messenger/pull/1634
[team113/messenger#1636]: https://github.com/team113/messenger/pull/1636
[team113/messenger#1637]: https://github.com/team113/messenger/pull/1637




## [0.3.3] · 2026-03-02
[0.3.3]: /../../tree/v0.3.3

[Diff](/../../compare/v0.3.2...v0.3.3) | [Milestone](/../../milestone/8)

### Changed

- UI:
    - Redesigned user page. ([team113/messenger#1625])
    - Redesigned chat info page. ([team113/messenger#1625])
    - Wallet tab:
        - Redesigned PayPal deposit. ([#31])
    - Chat page:
        - Minimum donation amount displaying in donation selection menu. ([#32])

### Fixed

- UI:
    - Profile page:
        - Country and city missing from linked Web devices. ([team113/messenger#1620])
    - Media panel:
        - Reconnect button playing animation when dragging. ([team113/messenger#1621])

[#31]: /../../pull/31
[#32]: /../../pull/32
[team113/messenger#1620]: https://github.com/team113/messenger/pull/1620
[team113/messenger#1621]: https://github.com/team113/messenger/pull/1621
[team113/messenger#1625]: https://github.com/team113/messenger/pull/1625



## [0.3.2] · 2026-02-23
[0.3.2]: /../../tree/v0.3.2

[Diff](/../../compare/v0.3.1...v0.3.2) | [Milestone](/../../milestone/7)

### Added

- UI:
    - Wallet tab:
        - PayPal deposit. ([#23])
    - Chat page:
        - Donations. ([#27])
    - Set your prices page:
        - Incoming donations minimum price settings. ([#28])
        - Incoming donations enabling and disabling. ([#28])
    - User page:
        - Individual donation monetization settings setting. ([#29])

### Changed

- UI:
    - Monetization tab:
        - Operations with pagination on transaction page. ([#27], [#26])
    - Wallet tab:
        - Operations with pagination on transaction page. ([#26])

### Fixed

- UI:
    - Chat page:
        - Draft not being updated when removing attachments or replies. ([team113/messenger#1613])
    - Profile page:
        - Invalid microphone and output device displayed as selected by default. ([team113/messenger#1613])
        - Invalid icon being used for devices with unknown OS. ([team113/messenger#1615])

[#23]: /../../pull/23
[#26]: /../../pull/26
[#27]: /../../pull/27
[#28]: /../../pull/28
[#29]: /../../pull/29
[team113/messenger#1613]: https://github.com/team113/messenger/pull/1613
[team113/messenger#1615]: https://github.com/team113/messenger/pull/1615




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
