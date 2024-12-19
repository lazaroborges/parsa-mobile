import 'package:flutter/material.dart';
import 'package:parsa/core/extensions/string.extension.dart';
import 'package:parsa/core/presentation/widgets/skeleton.dart';
import 'package:parsa/core/extensions/color.extensions.dart';
import 'package:parsa/core/utils/open_external_url.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'widgets/settings_list_separator.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Widget buildLinkItem(
    String title, {
    String? subtitle,
    required Function() onTap,
    IconData? icon,
  }) {
    return ListTile(
      title: Text(title),
      minVerticalPadding: 16,
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: icon != null
          ? FaIcon(icon, size: 24, color: Colors.green)
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.more.about_us.display)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DisplayAppIcon(height: 80),
                  const SizedBox(width: 16),
                  FutureBuilder(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Column(
                            children: [
                              Skeleton(width: 25, height: 16),
                              Skeleton(width: 12, height: 12),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data!.appName.capitalize(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'v${snapshot.data!.version} (${snapshot.data!.buildNumber})',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.intro.welcome_subtitle2,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                          ],
                        );
                      })
                ],
              ),
            ),
            createListSeparator(context, t.more.about_us.project.display),
            // buildLinkItem(
            //   t.more.about_us.project.contributors,
            //   subtitle: t.more.about_us.project.contributors_descr,
            //   onTap: () {
            //     openExternalURL(context,
            //         'https://github.com/enrique-lozano/Monekin/graphs/contributors');
            //   },
            // ),
            buildLinkItem(
              t.more.about_us.project.about_us,
              onTap: () {
                openExternalURL(context, 'https://www.parsa-ai.com.br/');
              },
            ),
            buildLinkItem(t.more.about_us.project.contact, onTap: () {
              openExternalURL(context, 'mailto:lazaro@parsa-ai.com.br');
            }),
                        buildLinkItem(
              'Chama no Zap',
              onTap: () {
                openExternalURL(context, 'https://wa.me/5531972012338');
              },
              icon: FontAwesomeIcons.whatsapp,
            ),
            createListSeparator(context, t.more.about_us.legal.display),
            buildLinkItem(
              t.more.about_us.legal.terms,
              onTap: () {
                openExternalURL(context,
                    'https://www.parsa-ai.com.br/termos-e-condi%C3%A7%C3%B5es-de-servi%C3%A7o');
              },
            ),
            buildLinkItem(
              t.more.about_us.legal.privacy,
              onTap: () {
                openExternalURL(context,
                    'https://www.parsa-ai.com.br/pol%C3%ADtica-de-privacidade');
              },
            ),

            buildLinkItem(
              t.more.about_us.legal.licenses,
              onTap: () async {
                openLicense({String? appName, String? version}) {
                  showLicensePage(
                    context: context,
                    applicationName: appName,
                    applicationVersion: version,
                  );
                }

                final info = await PackageInfo.fromPlatform();
                openLicense(appName: info.appName, version: info.version);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayAppIcon extends StatelessWidget {
  const DisplayAppIcon({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: height,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.transparent),
        borderRadius: BorderRadius.circular(18),
        color: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.asset(
            'assets/resources/appIcon.png',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
