import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/i18n/translations.g.dart';



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
  });

  final Widget body;

  final String title;

  final IconData headerButtonIcon;

  final EdgeInsets bodyPadding;

  final void Function()? onHeaderButtonClick;

  final bool isEditable;

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
            blurRadius: cardWithHeaderRadius,
            offset: const Offset(0, 0),
            spreadRadius: 4,
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
          Container(
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

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    
    return CardWithHeader(
      title: widget.title.isEmpty ? "Contas" : widget.title,
      onHeaderButtonClick: widget.onAddAccountTap,
      headerButtonIcon: Icons.add,
      body: Column(
        children: [
          ...widget.accounts.map((account) => Column(
            children: [
              ListTile(
                onTap: () => widget.onAccountTap(account),
                leading: _buildAccountIcon(account.iconId),
                title: Text(
                  account.name,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
                        ),
                       
                      ],
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
              if (account != widget.accounts.last)
                const Divider(indent: 72),
            ],
          )).toList(),
        ],
      ),
    );
  }
}
