import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/details/account_details.dart';
import 'package:parsa/app/accounts/widgets/credit_card_list_card.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/routes/route_utils.dart';

import '../../../accounts/account_connection_modal.dart';

class CreditCardsCard extends StatelessWidget {
  const CreditCardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Account>>(
      stream: AccountService.instance.getAccounts(
        predicate: (a, c) => a.type.equals('credit'),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final creditCards =
            snapshot.data!.where((account) => !account.removed).toList();

        if (creditCards.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: CreditCardListCard(
            creditCards: creditCards,
            onCardTap: (card) => RouteUtils.pushRoute(
              context,
              AccountDetailsPage(
                account: card,
                accountIconHeroTag: null,
              ),
            ),
            onAddCardTap: () {
              RouteUtils.pushRoute(context, const AccountConnectionModal());
            },
          ),
        );
      },
    );
  }
}
