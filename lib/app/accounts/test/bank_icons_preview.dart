import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/extensions/color.extensions.dart';
import 'package:parsa/core/models/supported-icon/icon_displayer.dart';
import 'package:parsa/core/models/supported-icon/supported_icon.dart';

// Custom SupportedIcon implementation for PNG icons
class PngSupportedIcon extends SupportedIcon {
  PngSupportedIcon({required String id}) : super(id: id, scope: 'png_icons');

  @override
  String get urlToAssets => 'assets/png_icons/$id.png';

  @override
  Widget display({double size = 22, Color? color}) {
    return SizedBox(
      height: size,
      width: size,
      child: Image.asset(
        urlToAssets,
        height: size,
        width: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class BankIconsPreviewPage extends StatefulWidget {
  const BankIconsPreviewPage({Key? key}) : super(key: key);

  @override
  _BankIconsPreviewPageState createState() => _BankIconsPreviewPageState();
}

class _BankIconsPreviewPageState extends State<BankIconsPreviewPage> {
  late List<String> iconIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    try {
      // Carregar todos os arquivos da pasta de instituições
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = Map.from(
          Map.castFrom<String, dynamic, String, dynamic>(
              manifestContent.isNotEmpty
                  ? json.decode(manifestContent)
                  : <String, dynamic>{}));

      // Incluir apenas os arquivos PNG da pasta png_icons
      final iconPaths = manifestMap.keys
          .where((String key) => key.contains('assets/png_icons/'))
          .toList();

      // Log the paths of the icons
      print('Icon paths: $iconPaths');

      final List<String> ids = iconPaths
          .map((path) {
            final filename = path.split('/').last;
            // Remove a extensão do arquivo (.png)
            return filename.contains('.')
                ? filename.substring(0, filename.lastIndexOf('.'))
                : filename;
          })
          .toSet() // Usa Set para remover duplicatas
          .toList();

      // Ordenar para facilitar a visualização
      ids.sort();

      setState(() {
        iconIds = ids;
        isLoading = false;
      });

      // Log the loaded icon IDs
      print('Loaded icon IDs: $iconIds');
    } catch (e) {
      print('Erro ao carregar ícones: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método para exibir o ícone diretamente como imagem, imitando o displayIcon do Account
  Widget _buildIconImage(String iconId) {
    return Builder(builder: (BuildContext context) {
      // Obter a cor base do ícone usando a lógica de getComputedColor
      final bool isLightMode = Theme.of(context).brightness == Brightness.light;
      final Color baseColor = isLightMode
          ? AppColors.of(context).primary
          : AppColors.of(context).primaryContainer;

      // Clarear a cor para o fundo do badge
      final Color mainColor = baseColor.lighten(isLightMode ? 0 : 0.82);
      final Color secondaryColor = baseColor.lighten(isLightMode ? 0.82 : 0);

      // Tamanho do ícone
      const double size = 42;

      // Create a PngSupportedIcon for the icon ID
      final PngSupportedIcon supportedIcon = PngSupportedIcon(id: iconId);

      // Usar IconDisplayer para exibir o ícone
      return IconDisplayer(
        supportedIcon: supportedIcon,
        mainColor: mainColor,
        secondaryColor: secondaryColor,
        size: size,
        displayMode: IconDisplayMode.polygon,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ícones de Bancos'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                itemCount: iconIds.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final iconId = iconIds[index];

                  return ListTile(
                    leading: _buildIconImage(iconId),
                    title: Text(
                      'Banco $iconId',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Text(
                      'ID: $iconId',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Em um aplicativo real, poderia navegar para detalhes do ícone
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ícone ID: $iconId'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
