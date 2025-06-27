import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/details/account_details.dart';
import 'package:parsa/app/accounts/widgets/account_list_card.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/routes/route_utils.dart';

import '../../../accounts/account_connection_modal.dart';

class AccountsCard extends StatelessWidget {
  const AccountsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: StreamBuilder<List<Account>>(
        stream: AccountService.instance.getAccounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final accounts =
              snapshot.data!.where((account) => !account.removed).toList();

          return AccountListCard(
            accounts: accounts,
            onAccountTap: (account) => RouteUtils.pushRoute(
              context,
              AccountDetailsPage(
                account: account,
                accountIconHeroTag: null,
              ),
            ),
            onAddAccountTap: () {
              RouteUtils.pushRoute(context, const AccountConnectionModal());
            },
          );
        },
      ),
    );
  }
}
