import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsa/app/accounts/all_accounts_page.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/presentation/widgets/monekin_reorderable_list.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/i18n/translations.g.dart';

import 'package:parsa/core/presentation/widgets/reorderable_drag_icon.dart';

import '../app_colors.dart';

/// The radius of the `CardWithHeader` widget, a very useful widget through the app
const cardWithHeaderRadius = 12.0;

class CardWithHeader extends StatelessWidget {
  const CardWithHeader({
    super.key,
    required this.title,
    required this.body,
    this.onHeaderButtonClick,
    this.headerButtonIcon = Icons.arrow_forward_ios_rounded,
    this.bodyPadding = const EdgeInsets.all(0),
    this.isEditable = false,
    this.onHeaderTap,
  });

  final Widget body;

  final String title;

  final IconData headerButtonIcon;

  final EdgeInsets bodyPadding;

  final void Function()? onHeaderButtonClick;

  final bool isEditable;

  final void Function()? onHeaderTap;

  @override
  Widget build(BuildContext context) {
    const double iconSize = 16;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(cardWithHeaderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).shadowColorLight,
            blurRadius: 8,
            offset: const Offset(0, 0),
            spreadRadius: 2,
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardWithHeaderRadius),
        border: Border.all(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
      ),
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onHeaderTap,
            child: Container(
              clipBehavior: Clip.hardEdge,
              padding: EdgeInsets.fromLTRB(
                  16,
                  onHeaderButtonClick != null ? 2 : iconSize - 6,
                  2,
                  onHeaderButtonClick != null ? 2 : iconSize - 6),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: AppColors.of(context).light,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      if (isEditable)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.blue[500],
                          ),
                        ),
                    ],
                  ),
                  if (onHeaderButtonClick != null)
                    IconButton(
                      onPressed: onHeaderButtonClick,
                      iconSize: iconSize,
                      color: AppColors.of(context).primary,
                      icon: Icon(headerButtonIcon),
                    )
                ],
              ),
            ),
          ),
          const Divider(),
          Material(
            type: MaterialType.transparency,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Padding(
              padding: bodyPadding,
              child: body,
            ),
          )
        ],
      ),
    );
  }
}

class AccountListCard extends StatefulWidget {
  const AccountListCard({
    super.key,
    required this.accounts,
    required this.onAccountTap,
    required this.onAddAccountTap,
    this.title = '',
  });

  final List<Account> accounts;
  final Function(Account) onAccountTap;
  final VoidCallback onAddAccountTap;
  final String title;

  @override
  State<AccountListCard> createState() => _AccountListCardState();
}

class _AccountListCardState extends State<AccountListCard> {
  final Map<String, String> _iconPathCache = {};

  Future<String> _getIconPath(String iconId) async {
    if (_iconPathCache.containsKey(iconId)) {
      return _iconPathCache[iconId]!;
    }

    final defaultPath = 'assets/png_icons/$iconId.png';
    final fallbackPath = 'assets/png_icons/1.png';

    try {
      await rootBundle.load(defaultPath);
      _iconPathCache[iconId] = defaultPath;
      return defaultPath;
    } catch (_) {
      _iconPathCache[iconId] = fallbackPath;
      return fallbackPath;
    }
  }

  Widget _buildAccountIcon(String iconId) {
    return FutureBuilder<String>(
      future: _getIconPath(iconId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Image.asset(
            'assets/png_icons/1.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          );
        }

        return Image.asset(
          snapshot.data!,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          cacheWidth: 64,
          cacheHeight: 64,
        );
      },
    );
  }

  String _cleanAccountName(String accountName) {
    // List of common Brazilian bank names to remove from the beginning
    final bankNames = [
      'Itaú',
      'Nubank Empresas',
      'Nubank',
      'Banco do Brasil',
      'Bradesco',
      'Santander',
      'Caixa',
      'Caixa Econômica',
      'Inter',
      'BTG',
      'BTG Pactual',
      'C6 Bank',
      'XP',
      'Neon',
      'PicPay',
      'Original',
      'Banrisul',
      'Sicoob',
      'Next',
      'BS2',
      'BV',
      'Banco BV',
      'Will Bank',
      'Mercado Pago',
      'PagBank',
    ];

    // Check if the account name starts with any bank name (case insensitive)
    for (final bankName in bankNames) {
      final pattern = RegExp('^$bankName\\s+', caseSensitive: false);
      if (pattern.hasMatch(accountName)) {
        return accountName.replaceFirst(pattern, '');
      }
    }

    return accountName;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    final visibleAccounts =
        widget.accounts.where((account) => !account.hiddenByUser).toList();

    return CardWithHeader(
      title: widget.title.isEmpty ? "Contas" : widget.title,
      onHeaderButtonClick: widget.onAddAccountTap,
      headerButtonIcon: Icons.add,
      onHeaderTap: () => RouteUtils.pushRoute(context, const AllAccountsPage()),
      bodyPadding: EdgeInsets.zero,
      body: visibleAccounts.isEmpty
          ? InkWell(
              onTap: widget.onAddAccountTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Center(
                  child: Text(
                    "Adicione uma conta",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          : MonekinReorderableList(
              totalItemCount: visibleAccounts.length,
              isOrderEnabled: visibleAccounts.length > 1,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final account = visibleAccounts[index];
                return Dismissible(
                  key: Key(account.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child:
                        const Icon(Icons.visibility_off, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child:
                        const Icon(Icons.visibility_off, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${account.name}foi ocultada do Menu Principal. Visite a aba "Contas" em "Menu" para poder exibi-la novamente aqui.'),
                        action: SnackBarAction(
                          label: 'Desfazer',
                          onPressed: () async {
                            await AccountService.instance.updateAccount(
                              account.copyWith(hiddenByUser: false),
                            );
                          },
                        ),
                      ),
                    );
                    return true;
                  },
                  onDismissed: (direction) async {
                    await AccountService.instance.updateAccount(
                      account.copyWith(hiddenByUser: true),
                    );
                  },
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => widget.onAccountTap(account),
                        leading: _buildAccountIcon(account.iconId),
                        title: Text(
                          _cleanAccountName(account.name),
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CurrencyDisplayer(
                                  amountToConvert: account.balance,
                                  currency: account.currency,
                                  integerStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: account.type == AccountType.credit
                                        ? Colors.red
                                        : Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (account != visibleAccounts.last)
                        const Divider(indent: 72),
                    ],
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex--;

                final item = visibleAccounts.removeAt(oldIndex);
                visibleAccounts.insert(newIndex, item);

                // You'll need to add AccountService to handle the updates
                await Future.wait(
                  visibleAccounts.mapIndexed(
                    (index, element) => AccountService.instance.updateAccount(
                      element.copyWith(displayOrder: index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
