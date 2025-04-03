import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/user-setting/private_mode_service.dart';
import 'package:parsa/core/database/services/user-setting/user_setting_service.dart';
import 'package:parsa/core/presentation/widgets/platform_alert_dialogue.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/api/post_methods/post_user_settings.dart';

import 'widgets/settings_list_separator.dart';

class PreferencesSettingsPage extends StatefulWidget {
  const PreferencesSettingsPage({super.key});

  @override
  State<PreferencesSettingsPage> createState() =>
      _PreferencesSettingsPageState();
}

class SelectItem<T> {
  T value;
  String label;

  IconData? icon;

  SelectItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

class _PreferencesSettingsPageState extends State<PreferencesSettingsPage> {
  Widget buildSelector<T>({
    required String title,
    String? dialogDescr,
    required List<SelectItem<T>> items,
    required T selected,
    required void Function(T newValue) onChanged,
  }) {
    SelectItem<T> selectedItem =
        items.firstWhere((element) => element.value == selected);

    return ListTile(
        title: Text(title),
        subtitle: Text(selectedItem.label),
        leading: Icon(Icons.light_mode),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  if (dialogDescr != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      dialogDescr,
                      style: Theme.of(context).textTheme.labelMedium,
                    )
                  ]
                ],
              ),
              contentPadding: const EdgeInsets.only(top: 12),
              content: SingleChildScrollView(
                  child: StatefulBuilder(builder: (context, alertState) {
                return Column(
                    children: items
                        .map(
                          (item) => RadioListTile(
                            title: Text(item.label),
                            value: item.value,
                            groupValue: selected,
                            onChanged: (newValue) {
                              if (newValue != null && newValue != selected) {
                                onChanged(newValue);
                                selected = newValue;
                              }
                            },
                          ),
                        )
                        .toList());
              })),
              actions: [
                TextButton(
                  child: Text(t.general.cancel),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.title_short),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // createListSeparator(context, t.settings.lang_section),
            // ListTile(
            //   title: Text(t.settings.lang_title),
            //   leading: const Icon(Icons.language),
            //   subtitle: Text(
            //     appSupportedLocales
            //         .firstWhere((element) =>
            //             element.locale.languageTag ==
            //             LocaleSettings.currentLocale.languageTag)
            //         .label,
            //   ),
            //   onTap: () async {
            //     final snackbarDisplayer =
            //         ScaffoldMessenger.of(context).showSnackBar;

            //     final newLang = await showLanguageSelectorBottomSheet(
            //       context,
            //       LanguageSelector(
            //           selectedLangTag:
            //               LocaleSettings.currentLocale.languageTag),
            //     );

            //     if (newLang == null) {
            //       return;
            //     }

            //     LocaleSettings.setLocaleRaw(newLang,
            //         listenToDeviceLocale: true);

            //     try {
            //       await UserSettingService.instance
            //           .setSetting(SettingKey.appLanguage, newLang);
            //     } catch (e) {
            //       snackbarDisplayer(const SnackBar(
            //         content: Text(
            //             'There was an error persisting this setting on your device. Contact the developers for more information'),
            //       ));
            //     }
            //   },
            // ),
            // // createListSeparator(context, t.settings.theme_and_colors),
            StreamBuilder(
                stream: UserSettingService.instance
                    .getSetting(SettingKey.themeMode)
                    .map((event) => 'light'),
                initialData: 'light',
                builder: (context, snapshot) {
                  // Not rendering the widget, but keeping the stream active
                  return const SizedBox.shrink();
                }),
            // Removed AMOLED mode, dynamic colors, and accent color widgets
            StreamBuilder(
                stream: UserSettingService.instance
                    .getSetting(SettingKey.amoledMode)
                    .map((event) => 'light'),
                initialData: 'light',
                builder: (context, snapshot) {
                  // Not rendering the widget, but keeping the stream active
                  return const SizedBox.shrink();
                }),
            StreamBuilder(
                stream: UserSettingService.instance
                    .getSetting(SettingKey.accentColor)
                    .map((event) => 'true'),
                initialData: 'true',
                builder: (context, snapshot) {
                  // Not rendering the widget, but keeping the stream active
                  return const SizedBox.shrink();
                }),
            StreamBuilder(
                stream: UserSettingService.instance
                    .getSetting(SettingKey.accentColor)
                    .map((event) => 'MaterialBlue3.24'),
                initialData: 'MaterialBlue3.24',
                builder: (context, snapshot) {
                  // Not rendering the widget, but keeping the stream active
                  return const SizedBox.shrink();
                }),
            createListSeparator(context, t.settings.security.title),
            StreamBuilder(
              stream: PrivateModeService.instance.getPrivateModeAtLaunch(),
              builder: (context, snapshot) {
                return SwitchListTile(
                  title: Text(t.settings.security.private_mode_at_launch),
                  subtitle:
                      Text(t.settings.security.private_mode_at_launch_descr),
                  secondary: const Icon(Icons.phonelink_lock_outlined),
                  value: snapshot.data ?? false,
                  onChanged: (bool value) async {
                    await PrivateModeService.instance
                        .setPrivateModeAtLaunch(value);
                    setState(() {});
                  },
                );
              },
            ),
            createListSeparator(context, "Prestações"),
            Builder(builder: (context) {
              // Get the initial value from UserDataProvider
              final userDataProvider = UserDataProvider.instance;
              final isAccrualBasisAccounting =
                  userDataProvider.userData?['accrual_basis_accounting'] ??
                      false;

              return SwitchListTile(
                title: const Text("Regime de Competência"),
                subtitle: const Text(
                    "Lança o valor total de uma prestação na data da compra."),
                secondary: const Icon(Icons.calendar_month),
                value: isAccrualBasisAccounting,
                onChanged: (bool value) async {
                  // Show confirmation dialog before making the change
                  final confirmed = await showPlatformAlertDialog(
                    context: context,
                    title: "Confirmar alteração",
                    content: value
                        ? "Ativar o regime de competência lançará o valor total de uma compra parcelada na data da compra. Você pode perder dados relacionados a transações editadas anteriormente. Deseja continuar?"
                        : "Desativar o regime de competência irá lançar cada parcela na data de vencimento. Você pode perder dados relacionados a transações editadas anteriormente. Deseja continuar?",
                    cancelActionText: "Cancelar",
                    defaultActionText: "Confirmar",
                  );

                  // If user confirmed, proceed with the change
                  if (confirmed == true) {
                    try {
                      // Update the value in the backend
                      await PostUserSettings
                          .updateAccrualBasisAccountingSetting(
                        isAccrualBasisAccounting: value,
                      );

                      // Update the local user data
                      userDataProvider
                          .updateUserData({'accrual_basis_accounting': value});

                      // Update the UI
                      setState(() {});

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Configuração atualizada com sucesso'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao atualizar configuração: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      print('Error updating competent_user setting: $e');
                    }
                  }
                },
              );
            }),
            // PrivateMode button disabled for now
            // StreamBuilder(
            //     stream: PrivateModeService.instance.privateModeStream,
            //     builder: (context, snapshot) {
            //       return SwitchListTile(
            //         title: Text(t.settings.security.private_mode),
            //         subtitle: Text(t.settings.security.private_mode_descr),
            //         secondary: const Icon(Icons.lock),
            //         value: snapshot.data ?? false,
            //         onChanged: (bool value) {
            //           PrivateModeService.instance.setPrivateMode(value);
            //           setState(() {});
            //         },
            //       );
            //     }),
          ],
        ),
      ),
    );
  }
}
