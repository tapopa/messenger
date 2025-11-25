// Copyright © 2022-2025 IT ENGINEERING MANAGEMENT INC,
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

import 'package:graphql_flutter/graphql_flutter.dart';

import '../base.dart';
import '/api/backend/schema.dart';
import '/domain/model/my_user.dart';
import '/domain/model/session.dart';
import '/store/model/operation.dart';
import '/util/log.dart';

/// [MyUser]'s purse related functionality.
mixin WalletGraphQlMixin {
  GraphQlClient get client;

  AccessTokenSecret? get token;

  Future<Operations$Query$Operations> operations({
    int? first,
    OperationsCursor? after,
    int? last,
    OperationsCursor? before,
  }) async {
    Log.debug('operations($first, $after, $last, $before)', '$runtimeType');

    final variables = OperationsArguments(
      origin: OperationOrigin.purse,
      pagination: OperationsPagination(
        first: first,
        after: after,
        last: last,
        before: before,
      ),
    );
    final QueryResult result = await client.query(
      QueryOptions(
        operationName: 'Operations',
        document: OperationsQuery(variables: variables).document,
        variables: variables.toJson(),
      ),
    );
    return Operations$Query.fromJson(result.data!).operations;
  }
}
