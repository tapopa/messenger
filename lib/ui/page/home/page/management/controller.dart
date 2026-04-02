// Copyright © 2025-2026 Ideas Networks Solutions S.A.,
//                       <https://github.com/tapopa>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License v3.0 as published by the
// Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License v3.0 for
// more details.
//
// You should have received a copy of the GNU Affero General Public License v3.0
// along with this program. If not, see
// <https://www.gnu.org/licenses/agpl-3.0.html>.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '/domain/model/link.dart';
import '/domain/model/user.dart';
import '/domain/repository/paginated.dart';
import '/domain/repository/user.dart';
import '/domain/service/auth.dart';
import '/domain/service/link.dart';
import '/domain/service/user.dart';

/// Possible [DirectLink] columns to display in a [TableView].
enum LinkColumn {
  created,
  slug,
  leads,
  percentage,
  income,
  clicks,
  partners,
  promotions,
  actions,
}

/// Controller of a [ManagementView].
class ManagementController extends GetxController {
  ManagementController(this._linkService, this._userService, this._authService);

  /// [Paginated] containing the [DirectLink]s of the current [MyUser].
  late final Paginated<DirectLinkSlug, DirectLink> links;

  /// [ScrollController] controlling the horizontal scrolling of a [TableView].
  final ScrollController horizontal = ScrollController();

  /// [ScrollController] controlling the vertical scrolling of a [TableView].
  final ScrollController vertical = ScrollController();

  /// [GlobalKey]s of [LinkColumn]s.
  final Map<LinkColumn, GlobalKey> keys = {
    for (var e in LinkColumn.values) e: GlobalKey(),
  };

  /// [LinkColumn] sorted to be displayed in a specific order in [TableView].
  final RxList<LinkColumn> headers = RxList(LinkColumn.values);

  /// [LinkService] managing the [DirectLink]s.
  final LinkService _linkService;

  /// [User]s service fetching the [User]s in [getUser] method.
  final UserService _userService;

  /// [AuthService] used to retrieve the [me].
  final AuthService _authService;

  /// Returns the [UserId] of the currently authenticated [MyUser].
  UserId? get me => _authService.userId;

  /// Returns the total amount of [DirectLink] created by [MyUser].
  RxInt get total => _linkService.total;

  @override
  void onInit() {
    vertical.addListener(_scrollListener);

    links = _linkService.links();
    links.ensureInitialized();

    super.onInit();
  }

  @override
  void onClose() {
    vertical.removeListener(_scrollListener);
    super.onClose();
  }

  /// Unlinks the provided [DirectLinkSlug].
  Future<void> unlinkLink(DirectLinkSlug slug) async {
    await _linkService.updateLink(slug, null);
  }

  /// Returns a reactive [User] from [UserService] by the provided [id].
  FutureOr<RxUser?> getUser(UserId id) => _userService.get(id);

  /// Invokes [Paginated.next] when [vertical] hits the bottom scrolling
  /// window, thus paginating the [links].
  Future<void> _scrollListener() async {
    if (vertical.hasClients) {
      final position = vertical.position.pixels;
      final max = vertical.position.maxScrollExtent;

      if (position >= max - 50) {
        if (links.hasNext.value && !links.nextLoading.value) {
          await links.next();
        }
      }
    }
  }
}
