// Copyright © 2022-2026 IT ENGINEERING MANAGEMENT INC,
//                       <https://github.com/team113>
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

import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_gherkin/src/flutter/parameters/existence_parameter.dart';
import 'package:get/get.dart';
import 'package:gherkin/gherkin.dart';
import 'package:messenger/domain/model/chat.dart';
import 'package:messenger/domain/model/chat_item.dart';
import 'package:messenger/domain/repository/chat.dart';
import 'package:messenger/domain/service/chat.dart';
import 'package:messenger/routes.dart';
import 'package:messenger/ui/page/home/page/chat/controller.dart';
import 'package:messenger/util/get.dart';
import 'package:messenger/util/log.dart';

import '../configuration.dart';
import '../parameters/keys.dart';

/// Waits until the provided [WidgetKey] is present or absent.
///
/// Examples:
/// - Then I wait until `WidgetKey` is absent
/// - Then I wait until `WidgetKey` is present
final StepDefinitionGeneric
waitUntilKeyExists = then2<WidgetKey, Existence, FlutterWorld>(
  'I wait until {key} is {existence}',
  (key, existence, context) async {
    await context.world.appDriver.waitUntil(() async {
      final finder = context.world.appDriver.findByKeySkipOffstage(key.name);

      Log.debug('waitUntilKeyExists -> finder for `$key` is $finder', 'E2E');

      if (key == WidgetKey.NoMessages) {
        final ChatId chatId = ChatId(router.route.split('/').last);
        final RxChat? chat = Get.find<ChatService>().chats[chatId];

        Log.debug(
          'waitUntilKeyExists -> looking for `NoMessage`s, thus the current `Chat` is probably `$chatId` -> $chat',
        );

        final RxChat? paginated = Get.find<ChatService>().paginated[chatId];
        Log.debug(
          'waitUntilKeyExists -> looking for `NoMessage`s, the paginated one -> $paginated',
        );

        final Iterable<ChatItem>? items = chat?.messages.map((e) => e.value);
        Log.debug('waitUntilKeyExists -> the items -> $items');

        final ChatController? controller = Get.findOrNull<ChatController>();
        Log.debug('waitUntilKeyExists -> the controller -> $controller');
        Log.debug(
          'waitUntilKeyExists -> the elements in controller -> ${controller?.elements.values}',
        );
      }

      return switch (existence) {
        Existence.absent => finder.evaluate().isEmpty,
        Existence.present => finder.evaluate().isNotEmpty,
      };
    }, timeout: const Duration(seconds: 30));
  },
);
