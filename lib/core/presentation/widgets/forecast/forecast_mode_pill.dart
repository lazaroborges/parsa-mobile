import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
import 'package:parsa/main.dart' show firebaseAnalytics;

class ForecastModePill extends StatelessWidget {
  const ForecastModePill({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ForecastModeService.instance.forecastModeStream,
      initialData: ForecastModeService.instance.isInForecastMode,
      builder: (context, snapshot) {
        final isForecasting = snapshot.data ?? false;

        return Semantics(
          label: isForecasting
              ? 'Voltar ao modo real'
              : 'Ativar modo previsao',
          button: true,
          child: GestureDetector(
            onTap: () {
              ForecastModeService.instance.toggle();

              firebaseAnalytics?.logEvent(
                name: 'forecast_mode_toggle',
                parameters: {
                  'enabled': (!isForecasting).toString(),
                },
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isForecasting
                    ? ForecastModeService.forecastAccentColor
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isForecasting
                      ? ForecastModeService.forecastAccentColor
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isForecasting
                        ? ForecastModeService.forecastAccentColor
                            .withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isForecasting
                        ? Icons.account_balance_rounded
                        : Icons.auto_graph_rounded,
                    size: 16,
                    color: isForecasting
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      isForecasting ? 'Real' : 'Previsao',
                      key: ValueKey(isForecasting),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isForecasting
                            ? Colors.white
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
