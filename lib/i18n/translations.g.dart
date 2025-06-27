/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 1
/// Strings: 619
///
/// Built on 2025-06-27 at 12:37 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.pt;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.pt) // set locale
/// - Locale locale = AppLocale.pt.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.pt) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	pt(languageCode: 'pt', build: Translations.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// context enums

enum GenderContext {
	male,
	female,
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _TranslationsConnectionsPt connections = _TranslationsConnectionsPt._(_root);
	late final _TranslationsGeneralPt general = _TranslationsGeneralPt._(_root);
	late final _TranslationsIntroPt intro = _TranslationsIntroPt._(_root);
	late final _TranslationsHomePt home = _TranslationsHomePt._(_root);
	late final _TranslationsFinancialHealthPt financial_health = _TranslationsFinancialHealthPt._(_root);
	late final _TranslationsStatsPt stats = _TranslationsStatsPt._(_root);
	late final _TranslationsIconSelectorPt icon_selector = _TranslationsIconSelectorPt._(_root);
	late final _TranslationsTransactionPt transaction = _TranslationsTransactionPt._(_root);
	late final _TranslationsTransferPt transfer = _TranslationsTransferPt._(_root);
	late final _TranslationsRecurrentTransactionsPt recurrent_transactions = _TranslationsRecurrentTransactionsPt._(_root);
	late final _TranslationsAccountPt account = _TranslationsAccountPt._(_root);
	late final _TranslationsCurrenciesPt currencies = _TranslationsCurrenciesPt._(_root);
	late final _TranslationsTagsPt tags = _TranslationsTagsPt._(_root);
	late final _TranslationsCategoriesPt categories = _TranslationsCategoriesPt._(_root);
	late final _TranslationsBudgetsPt budgets = _TranslationsBudgetsPt._(_root);
	late final _TranslationsBackupPt backup = _TranslationsBackupPt._(_root);
	late final _TranslationsSettingsPt settings = _TranslationsSettingsPt._(_root);
	late final _TranslationsMorePt more = _TranslationsMorePt._(_root);
	late final _TranslationsAuthPt auth = _TranslationsAuthPt._(_root);
}

// Path: connections
class _TranslationsConnectionsPt {
	_TranslationsConnectionsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get success => 'Sincronização concluída com sucesso. Vamos analisar seus dados. Em um minuto, tente atualizar a tela para ver seus dados atualizados.';
	String get error => 'Ocorreu um erro ao sincronizar seus dados. Por favor, tente novamente mais tarde.';
}

// Path: general
class _TranslationsGeneralPt {
	_TranslationsGeneralPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get cancel => 'Cancelar';
	String get or => 'ou';
	String get understood => 'Entendido';
	String get unspecified => 'Não especificado';
	String get confirm => 'Confirmar';
	String get continue_text => 'Continuar';
	String get quick_actions => 'Ações rápidas';
	String get save => 'Salvar';
	String get save_changes => 'Salvar alterações';
	String get close_and_save => 'Salvar e fechar';
	String get add => 'Adicionar';
	String get edit => 'Editar';
	String get balance => 'Saldo';
	String get delete => 'Excluir';
	String get account => 'Conta';
	String get accounts => 'Contas';
	String get categories => 'Categorias';
	String get category => 'Categoria';
	String get today => 'Hoje';
	String get yesterday => 'Ontem';
	String get filters => 'Filtros';
	String get select_all => 'Selecionar tudo';
	String get deselect_all => 'Desmarcar tudo';
	String get empty_warn => 'Ops! Isso está muito vazio';
	String get insufficient_data => 'Dados insuficientes';
	String get show_more_fields => 'Mostrar mais campos';
	String get show_less_fields => 'Mostrar menos campos';
	String get tap_to_search => 'Toque para pesquisar';
	late final _TranslationsGeneralClipboardPt clipboard = _TranslationsGeneralClipboardPt._(_root);
	late final _TranslationsGeneralTimePt time = _TranslationsGeneralTimePt._(_root);
	late final _TranslationsGeneralTransactionOrderPt transaction_order = _TranslationsGeneralTransactionOrderPt._(_root);
	late final _TranslationsGeneralValidationsPt validations = _TranslationsGeneralValidationsPt._(_root);
}

// Path: intro
class _TranslationsIntroPt {
	_TranslationsIntroPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get start => 'Começar';
	String get skip => 'Pular';
	String get next => 'Próximo';
	String get select_your_currency => 'Selecione sua moeda';
	String get welcome_subtitle => 'Seu gerente financeiro pessoal';
	String get welcome_subtitle2 => 'Controle Financeiro sem esforço.';
	String get welcome_footer => 'Ao entrar, você concorda com a <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/PRIVACY_POLICY.md\'>Política de Privacidade</a> e os <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/TERMS_OF_USE.md\'>Termos de Uso</a> do aplicativo';
	String get offline_descr_title => 'CONTA OFFLINE:';
	String get offline_descr => 'Seus dados serão armazenados apenas no seu dispositivo e estarão seguros enquanto você não desinstalar o aplicativo ou trocar de telefone. Para evitar a perda de dados, é recomendável fazer backup regularmente nas configurações do aplicativo.';
	String get offline_start => 'Iniciar sessão offline';
	String get sl1_title => 'Selecione sua moeda';
	String get sl1_descr => 'Sua moeda padrão será usada em relatórios e gráficos gerais. Você poderá alterar a moeda e o idioma do aplicativo mais tarde a qualquer momento nas configurações do aplicativo';
	String get sl2_title => 'Seguro, privado e confiável';
	String get sl2_descr => 'Seus dados são apenas seus. Armazenamos as informações diretamente no seu dispositivo, sem passar por servidores externos. Isso possibilita o uso do aplicativo mesmo sem internet';
	String get sl2_descr2 => 'Além disso, o código-fonte do aplicativo é público, qualquer pessoa pode colaborar e ver como ele funciona';
	String get last_slide_title => 'Tudo pronto';
	String get last_slide_descr => 'Com o Parsa, você finalmente pode alcançar a independência financeira que tanto deseja. Você terá gráficos, orçamentos, dicas, insights e muito mais sobre seu dinheiro.';
	String get last_slide_descr2 => 'Esperamos que aproveite sua experiência! Não hesite em nos contatar em caso de dúvidas, sugestões...';
}

// Path: home
class _TranslationsHomePt {
	_TranslationsHomePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Início';
	String get filter_transactions => 'Filtrar transações';
	String get hello_day => 'Bom dia,';
	String get hello_night => 'Boa noite,';
	String get total_balance => 'Saldo Disponível';
	String get total_balance_tooltip => 'Soma de todos os saldos das suas contas menos os saldos do cartão de crédito e empréstimos.';
	String get available_balance => 'Saldo disponível';
	String get available_balance_tooltip => 'Soma de todos os saldos das suas contas menos os saldos do cartão de crédito e empréstimos.';
	String get future_balance => 'Saldo futuro';
	String get future_balance_tooltip => 'Soma de todos os saldos das suas contas menos os saldos do cartão de crédito e empréstimos.';
	String get my_accounts => 'Minhas contas';
	String get active_accounts => 'Contas ativas';
	String get no_accounts => 'Nenhuma conta criada ainda';
	String get no_accounts_descr => 'Comece a usar toda a magia do Parsa. Crie pelo menos uma conta para começar a adicionar transações';
	String get last_transactions => 'Últimas transações';
	String get should_create_account_header => 'Ops!';
	String get should_create_account_message => 'Você deve ter pelo menos uma conta não arquivada antes de começar a criar transações';
}

// Path: financial_health
class _TranslationsFinancialHealthPt {
	_TranslationsFinancialHealthPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Saúde financeira';
	late final _TranslationsFinancialHealthReviewPt review = _TranslationsFinancialHealthReviewPt._(_root);
	late final _TranslationsFinancialHealthMonthsWithoutIncomePt months_without_income = _TranslationsFinancialHealthMonthsWithoutIncomePt._(_root);
	late final _TranslationsFinancialHealthSavingsPercentagePt savings_percentage = _TranslationsFinancialHealthSavingsPercentagePt._(_root);
}

// Path: stats
class _TranslationsStatsPt {
	_TranslationsStatsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Insights';
	String get balance => 'Saldo';
	String get final_balance => 'Saldo final';
	String get balance_by_account => 'Saldo por contas';
	String get balance_by_currency => 'Saldo por moeda';
	String get cash_flow => 'Fluxo de caixa';
	String get balance_evolution => 'Evolução do saldo';
	String get compared_to_previous_period => 'Comparado ao período anterior';
	String get by_periods => 'Por períodos';
	String get by_categories => 'Por categorias';
	String get by_tags => 'Por tags';
	String get distribution => 'Categorias';
	String get finance_health_resume => 'Resumo';
	String get finance_health_breakdown => 'Detalhamento';
}

// Path: icon_selector
class _TranslationsIconSelectorPt {
	_TranslationsIconSelectorPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Nome:';
	String get icon => 'Ícone';
	String get color => 'Cor';
	String get select_icon => 'Selecione um ícone';
	String get select_color => 'Selecione uma cor';
	String get select_account_icon => 'Identifique sua conta';
	String get select_category_icon => 'Identifique sua categoria';
	late final _TranslationsIconSelectorScopesPt scopes = _TranslationsIconSelectorScopesPt._(_root);
}

// Path: transaction
class _TranslationsTransactionPt {
	_TranslationsTransactionPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Transações',
		other: 'Transações',
	);
	String get title => 'Info';
	String get source => 'Origem';
	String get openfinance_source => 'Open Finance';
	String get manual_source => 'Manual';
	String get manipulated => 'Modificada pelo usuário';
	String get synch_method => 'Sincronizada';
	String get synch_auto => 'Automaticamente (Open Finance)';
	String get synch_manual => 'Manualmente';
	String get yes => 'Sim';
	String get no => 'Não';
	String get delete_openfinance_error => 'Não é possível deletar transações do Open Finance. Caso você queira desconsiderar uma transação, use a opção \'Desconsiderada\' dentro do card da transação.';
	String get last_update => 'Última atualização';
	String get payment_method => 'Forma de pagamento';
	String get create => 'Nova transação';
	String get new_income => 'Nova receita';
	String get new_expense => 'Nova despesa';
	String get new_success => 'Transação criada com sucesso';
	String get edit => 'Editar transação';
	String get edit_success => 'Transação editada com sucesso';
	String get edit_multiple => 'Editar transações';
	String edit_multiple_success({required Object x}) => '${x} transações editadas com sucesso';
	String get duplicate => 'Clonar transação';
	String get duplicate_short => 'Clonar';
	String get duplicate_warning_message => 'Uma transação idêntica a esta será criada com a mesma data, deseja continuar?';
	String get duplicate_success => 'Transação clonada com sucesso';
	String get delete => 'Excluir transação';
	String get delete_warning_message => 'Essa ação é irreversível. Prefira usar o status \'Desconsiderada\' para remover a transação das suas análises. O saldo atual de suas contas e todas as suas análises serão recalculados';
	String get delete_success => 'Transação excluída com sucesso.';
	String get delete_multiple => 'Excluir com sucesso';
	String delete_multiple_warning_message({required Object x}) => 'Essa ação é irreversível e removerá ${x} transações. O saldo atual de suas contas e todas as suas análises serão recalculados';
	String delete_multiple_success({required Object x}) => '${x} transações excluídas com sucesso';
	String get details => 'Detalhes da transação';
	String get transaction_cousin => 'Transações Similares';
	late final _TranslationsTransactionNextPaymentsPt next_payments = _TranslationsTransactionNextPaymentsPt._(_root);
	late final _TranslationsTransactionListPt list = _TranslationsTransactionListPt._(_root);
	late final _TranslationsTransactionFiltersPt filters = _TranslationsTransactionFiltersPt._(_root);
	late final _TranslationsTransactionFormPt form = _TranslationsTransactionFormPt._(_root);
	late final _TranslationsTransactionNotesPt notes = _TranslationsTransactionNotesPt._(_root);
	late final _TranslationsTransactionReversedPt reversed = _TranslationsTransactionReversedPt._(_root);
	late final _TranslationsTransactionStatusPt status = _TranslationsTransactionStatusPt._(_root);
	late final _TranslationsTransactionTypesPt types = _TranslationsTransactionTypesPt._(_root);
}

// Path: transfer
class _TranslationsTransferPt {
	_TranslationsTransferPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Transferência';
	String get transfers => 'Transferências';
	String transfer_to({required Object account}) => 'Transferir para ${account}';
	String get create => 'Nova Transferência';
	String get need_two_accounts_warning_header => 'Ops!';
	String get need_two_accounts_warning_message => 'São necessárias pelo menos duas contas para realizar esta ação. Se precisar ajustar ou editar o saldo atual desta conta, clique no botão de edição';
	late final _TranslationsTransferFormPt form = _TranslationsTransferFormPt._(_root);
}

// Path: recurrent_transactions
class _TranslationsRecurrentTransactionsPt {
	_TranslationsRecurrentTransactionsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Transações recorrentes';
	String get title_short => 'Trans. recorrentes';
	String get empty => 'Parece que você não tem nenhuma transação recorrente. Crie uma transação recorrente mensal, anual ou semanal e ela aparecerá aqui';
	String get total_expense_title => 'Despesa total por período';
	String get total_expense_descr => '* Sem considerar a data de início e término de cada recorrência';
	late final _TranslationsRecurrentTransactionsDetailsPt details = _TranslationsRecurrentTransactionsDetailsPt._(_root);
}

// Path: account
class _TranslationsAccountPt {
	_TranslationsAccountPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get details => 'Detalhes da conta';
	String get date => 'Data de abertura';
	String get date_sync => 'Conta sincronizada desde';
	String get close_date => 'Data de fechamento';
	String get disconnection_date => 'Data de desconexão';
	String get reopen => 'Reabrir conta';
	String get reopen_short => 'Reabrir';
	String get reopen_descr => 'Tem certeza de que deseja reabrir esta conta?';
	String get balance => 'Saldo da conta';
	String get n_transactions => 'Número de transações';
	String get add_money => 'Adicionar dinheiro';
	String get withdraw_money => 'Retirar dinheiro';
	String get last_update => 'Última atualização';
	String get no_accounts => 'Nenhuma transação encontrada para exibir aqui. Adicione uma transação clicando no botão \'+\' na parte inferior';
	late final _TranslationsAccountTypesPt types = _TranslationsAccountTypesPt._(_root);
	late final _TranslationsAccountFormPt form = _TranslationsAccountFormPt._(_root);
	late final _TranslationsAccountDisconnectPt disconnect = _TranslationsAccountDisconnectPt._(_root);
	late final _TranslationsAccountRemovePt remove = _TranslationsAccountRemovePt._(_root);
	late final _TranslationsAccountRestorePt restore = _TranslationsAccountRestorePt._(_root);
	late final _TranslationsAccountDeleteOpenfinancePt delete_openfinance = _TranslationsAccountDeleteOpenfinancePt._(_root);
	late final _TranslationsAccountDeletePt delete = _TranslationsAccountDeletePt._(_root);
	late final _TranslationsAccountClosePt close = _TranslationsAccountClosePt._(_root);
	late final _TranslationsAccountSelectPt select = _TranslationsAccountSelectPt._(_root);
	late final _TranslationsAccountConnectionErrorsPt connection_errors = _TranslationsAccountConnectionErrorsPt._(_root);
}

// Path: currencies
class _TranslationsCurrenciesPt {
	_TranslationsCurrenciesPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get currency_converter => 'Conversor de moedas';
	String get currency => 'Moeda';
	String get currency_manager => 'Gerenciador de moedas';
	String get currency_manager_descr => 'Configure sua moeda e suas taxas de câmbio com outras';
	String get preferred_currency => 'Moeda preferida/base';
	String get change_preferred_currency_title => 'Alterar moeda preferida';
	String get change_preferred_currency_msg => 'Todas as insights e orçamentos serão exibidos nesta moeda a partir de agora. Contas e transações manterão a moeda que possuíam. Todas as taxas de câmbio salvas serão excluídas se você executar esta ação. Deseja continuar?';
	late final _TranslationsCurrenciesFormPt form = _TranslationsCurrenciesFormPt._(_root);
	String get delete_all_success => 'Taxas de câmbio excluídas com sucesso';
	String get historical => 'Taxas históricas';
	String get exchange_rate => 'Taxa de câmbio';
	String get exchange_rates => 'Taxas de câmbio';
	String get empty => 'Adicione taxas de câmbio aqui para que se você tiver contas em moedas diferentes da sua moeda base, nossos gráficos sejam mais precisos';
	String get select_a_currency => 'Selecione uma moeda';
	String get search => 'Pesquise por nome ou código da moeda';
}

// Path: tags
class _TranslationsTagsPt {
	_TranslationsTagsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Tag',
		other: 'Tags',
	);
	late final _TranslationsTagsFormPt form = _TranslationsTagsFormPt._(_root);
	String get empty_list => 'Você ainda não criou nenhuma tag. Tags e categorias são uma ótima maneira de categorizar suas transações';
	String get without_tags => 'Sem tags';
	String get select => 'Selecionar tags';
	String get add => 'Adicionar tag';
	String get create => 'Criar tag';
	String get create_success => 'Tag criada com sucesso';
	String get already_exists => 'Este nome de tag já existe. Talvez você queira editá-lo';
	String get edit => 'Editar tag';
	String get edit_success => 'Tag editada com sucesso';
	String get delete_success => 'Tag excluída com sucesso';
	String get delete_warning_header => 'Excluir tag?';
	String get delete_warning_message => 'Essa ação não excluirá as transações que possuem essa tag.';
	String get no_tags => 'Transação sem tags. Clique aqui para adicionar uma tag.';
}

// Path: categories
class _TranslationsCategoriesPt {
	_TranslationsCategoriesPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get unknown => 'Categoria desconhecida';
	String get create => 'Criar categoria';
	String get create_success => 'Categoria criada com sucesso.';
	String get new_category => 'Nova categoria';
	String get already_exists => 'O nome desta categoria já existe. Talvez você queira editá-la';
	String get edit => 'Editar categoria';
	String get edit_success => 'Categoria editada com sucesso.';
	String get name => 'Nome da categoria';
	String get type => 'Tipo de categoria';
	String get both_types => 'Ambos os tipos';
	String get subcategories => 'Subcategorias';
	String get subcategories_add => 'Adicionar subcategoria';
	String get make_parent => 'Tornar categoria';
	String get make_child => 'Tornar subcategoria';
	String make_child_warning1({required Object destiny}) => 'Esta categoria e suas subcategorias se tornarão subcategorias de <b>${destiny}</b>.';
	String make_child_warning2({required Object x, required Object destiny}) => 'Suas transações <b>(${x})</b> serão movidas para as novas subcategorias criadas dentro da categoria <b>${destiny}</b>.';
	String get make_child_success => 'Subcategorias criadas com sucesso';
	String get merge => 'Mesclar com outra categoria';
	String merge_warning1({required Object x, required Object from, required Object destiny}) => 'Todas as transações (${x}) associadas à categoria <b>${from}</b> serão movidas para a categoria <b>${destiny}</b>';
	String merge_warning2({required Object from}) => 'A categoria <b>${from}</b> será excluída de forma irreversível.';
	String get merge_success => 'Categoria mesclada com sucesso';
	String get delete_success => 'Categoria excluída com sucesso.';
	String get delete_warning_header => 'Excluir categoria?';
	String delete_warning_message({required Object x}) => 'Essa ação excluirá de forma irreversível todas as transações <b>(${x})</b> relacionadas a esta categoria.';
	late final _TranslationsCategoriesSelectPt select = _TranslationsCategoriesSelectPt._(_root);
}

// Path: budgets
class _TranslationsBudgetsPt {
	_TranslationsBudgetsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Orçamentos';
	String get repeated => 'Recorrente';
	String get one_time => 'Único';
	String get annual => 'Anuais';
	String get week => 'Semanal';
	String get month => 'Mensal';
	String get actives => 'Ativos';
	String get pending => 'Aguardando início';
	String get finish => 'Finalizado';
	String get from_budgeted => 'restante de ';
	String get days_left => 'dias restantes';
	String get days_to_start => 'dias para começar';
	String get since_expiration => 'dias desde a expiração';
	String get no_budgets => 'Parece não haver orçamentos nesse período para exibir nesta seção. Comece criando um orçamento clicando aqui.';
	String get delete => 'Excluir orçamento';
	String get delete_warning => 'Essa ação é irreversível. Categorias e transações referentes a esta cota não serão excluídas';
	late final _TranslationsBudgetsFormPt form = _TranslationsBudgetsFormPt._(_root);
	late final _TranslationsBudgetsDetailsPt details = _TranslationsBudgetsDetailsPt._(_root);
}

// Path: backup
class _TranslationsBackupPt {
	_TranslationsBackupPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsBackupExportPt export = _TranslationsBackupExportPt._(_root);
	late final _TranslationsBackupImportPt import = _TranslationsBackupImportPt._(_root);
	late final _TranslationsBackupAboutPt about = _TranslationsBackupAboutPt._(_root);
}

// Path: settings
class _TranslationsSettingsPt {
	_TranslationsSettingsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get logout => 'Sair / Logout';
	String get title_long => 'Preferências';
	String get title_short => 'Preferências';
	String get description => 'Configure o Parsa do seu jeito.';
	String get edit_profile => 'Editar perfil';
	late final _TranslationsSettingsDashboardPt dashboard = _TranslationsSettingsDashboardPt._(_root);
	String get lang_section => 'Idioma e textos';
	String get lang_title => 'Idioma do aplicativo';
	String get lang_descr => 'Idioma em que os textos serão exibidos no aplicativo';
	String get locale => 'Região';
	String get locale_descr => 'Defina o formato a ser usado para datas, números...';
	String get locale_warn => 'Ao mudar de região, o aplicativo será atualizado';
	String get first_day_of_week => 'Primeiro dia da semana';
	String get theme_and_colors => 'Tema e cores';
	String get theme => 'Tema';
	String get theme_auto => 'Definido pelo sistema';
	String get theme_light => 'Claro';
	String get theme_dark => 'Escuro';
	String get amoled_mode => 'Modo AMOLED';
	String get amoled_mode_descr => 'Use um papel de parede preto puro sempre que possível. Isso ajudará um pouco na bateria de dispositivos com telas AMOLED';
	String get dynamic_colors => 'Cores dinâmicas';
	String get dynamic_colors_descr => 'Use a cor de destaque do sistema sempre que possível';
	String get accent_color => 'Cor de destaque';
	String get accent_color_descr => 'Escolha a cor que o aplicativo usará para destacar certas partes da interface';
	late final _TranslationsSettingsSecurityPt security = _TranslationsSettingsSecurityPt._(_root);
}

// Path: more
class _TranslationsMorePt {
	_TranslationsMorePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Menu';
	String get title_long => 'Menu e Preferências';
	late final _TranslationsMoreDataPt data = _TranslationsMoreDataPt._(_root);
	late final _TranslationsMoreSubscribePt subscribe = _TranslationsMoreSubscribePt._(_root);
	late final _TranslationsMoreAboutUsPt about_us = _TranslationsMoreAboutUsPt._(_root);
	late final _TranslationsMoreHelpUsPt help_us = _TranslationsMoreHelpUsPt._(_root);
}

// Path: auth
class _TranslationsAuthPt {
	_TranslationsAuthPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get login_button => 'Fazer Login no Parsa';
	String get login_reason => 'Por favor, confirme sua biometria para continuar. ';
	String get login_error => 'Erro ao fazer login. Por favor, verifique suas credenciais e conexão de rede.';
	String get biometric_failed => 'Autenticação biométrica falhou. Por favor, faça o login novamente.';
	String get app_name => 'Parsa';
}

// Path: general.clipboard
class _TranslationsGeneralClipboardPt {
	_TranslationsGeneralClipboardPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String success({required Object x}) => '${x} copiado para a área de transferência';
	String get error => 'Erro ao copiar';
}

// Path: general.time
class _TranslationsGeneralTimePt {
	_TranslationsGeneralTimePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get start_date => 'Data de início';
	String get end_date => 'Data de término';
	String get from_date => 'A partir da data';
	String get until_date => 'Até a data';
	String get date => 'Data';
	String get datetime => 'Data e hora';
	String get time => 'Hora';
	String get each => 'Cada';
	String get after => 'Após';
	late final _TranslationsGeneralTimeRangesPt ranges = _TranslationsGeneralTimeRangesPt._(_root);
	late final _TranslationsGeneralTimePeriodicityPt periodicity = _TranslationsGeneralTimePeriodicityPt._(_root);
	late final _TranslationsGeneralTimeCurrentPt current = _TranslationsGeneralTimeCurrentPt._(_root);
	late final _TranslationsGeneralTimeAllPt all = _TranslationsGeneralTimeAllPt._(_root);
}

// Path: general.transaction_order
class _TranslationsGeneralTransactionOrderPt {
	_TranslationsGeneralTransactionOrderPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Ordenar transações';
	String get category => 'Por categoria';
	String get quantity => 'Por quantidade';
	String get date => 'Por data';
}

// Path: general.validations
class _TranslationsGeneralValidationsPt {
	_TranslationsGeneralValidationsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Campo obrigatório';
	String get positive => 'Deve ser positivo';
	String min_number({required Object x}) => 'Deve ser maior que ${x}';
	String max_number({required Object x}) => 'Deve ser menor que ${x}';
}

// Path: financial_health.review
class _TranslationsFinancialHealthReviewPt {
	_TranslationsFinancialHealthReviewPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String very_good({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Muito bom!';
			case GenderContext.female:
				return 'Muito bom!';
		}
	}
	String good({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Bom';
			case GenderContext.female:
				return 'Bom';
		}
	}
	String normal({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Razoável';
			case GenderContext.female:
				return 'Razoável';
		}
	}
	String bad({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Ruim';
			case GenderContext.female:
				return 'Ruim';
		}
	}
	String very_bad({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Muito ruim';
			case GenderContext.female:
				return 'Muito ruim';
		}
	}
	String insufficient_data({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Dados insuficientes';
			case GenderContext.female:
				return 'Dados insuficientes';
		}
	}
	late final _TranslationsFinancialHealthReviewDescrPt descr = _TranslationsFinancialHealthReviewDescrPt._(_root);
}

// Path: financial_health.months_without_income
class _TranslationsFinancialHealthMonthsWithoutIncomePt {
	_TranslationsFinancialHealthMonthsWithoutIncomePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Taxa de sobrevivência';
	String get subtitle => 'Dado seu saldo, tempo que você poderia viver sem renda';
	String get text_zero => 'Você não conseguiria sobreviver um mês sem renda neste ritmo de despesas!';
	String get text_one => 'Você mal conseguiria sobreviver aproximadamente um mês sem renda neste ritmo de despesas!';
	String text_other({required Object n}) => 'Você conseguiria sobreviver aproximadamente <b>${n} meses</b> sem renda neste ritmo de despesas.';
	String get text_infinite => 'Você conseguiria sobreviver aproximadamente <b>toda a vida</b> sem renda neste ritmo de despesas.';
	String get suggestion => 'Lembre-se de que é aconselhável sempre manter essa proporção acima de 5 meses, pelo menos. Se você perceber que não tem uma reserva de emergência suficiente, reduza as despesas desnecessárias.';
	String get insufficient_data => 'Parece que não temos despesas suficientes para calcular quantos meses você poderia sobreviver sem renda. Insira algumas transações e volte aqui para verificar sua saúde financeira';
}

// Path: financial_health.savings_percentage
class _TranslationsFinancialHealthSavingsPercentagePt {
	_TranslationsFinancialHealthSavingsPercentagePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Porcentagem de economia';
	String get subtitle => 'Qual parte da sua renda não foi gasta neste período';
	late final _TranslationsFinancialHealthSavingsPercentageTextPt text = _TranslationsFinancialHealthSavingsPercentageTextPt._(_root);
	String get suggestion => 'Lembre-se de que é aconselhável economizar pelo menos 15-20% do que você ganha.';
}

// Path: icon_selector.scopes
class _TranslationsIconSelectorScopesPt {
	_TranslationsIconSelectorScopesPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get transport => 'Transporte';
	String get money => 'Dinheiro';
	String get food => 'Alimentação';
	String get medical => 'Saúde';
	String get entertainment => 'Lazer';
	String get technology => 'Tecnologia';
	String get other => 'Outros';
	String get logos_financial_institutions => 'Instituições financeiras';
}

// Path: transaction.next_payments
class _TranslationsTransactionNextPaymentsPt {
	_TranslationsTransactionNextPaymentsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get accept => 'Aceitar';
	String get skip => 'Pular';
	String get skip_success => 'Transação pulada com sucesso';
	String get skip_dialog_title => 'Pular transação';
	String skip_dialog_msg({required Object date}) => 'Essa ação é irreversível. Vamos mover a data da próxima transação para ${date}';
	String get accept_today => 'Aceitar hoje';
	String accept_in_required_date({required Object date}) => 'Aceitar na data requerida (${date})';
	String get accept_dialog_title => 'Aceitar transação';
	String get accept_dialog_msg_single => 'O novo status da transação será nulo. Você pode re-editar o status dessa transação sempre que quiser';
	String accept_dialog_msg({required Object date}) => 'Essa ação criará uma nova transação com data ${date}. Você poderá verificar os detalhes desta transação na página de transações';
	String get recurrent_rule_finished => 'A regra recorrente foi concluída, não há mais pagamentos a serem feitos!';
}

// Path: transaction.list
class _TranslationsTransactionListPt {
	_TranslationsTransactionListPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get empty => 'Nenhuma transação encontrada para exibir aqui. Adicione uma transação clicando no botão \'+\' na parte inferior';
	String get searcher_placeholder => 'Pesquisar por categoria, descrição...';
	String get searcher_no_results => 'Nenhuma transação encontrada correspondente aos critérios de pesquisa';
	String get loading => 'Carregando mais transações...';
	String selected_short({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: '${n} selecionada',
		other: '${n} selecionadas',
	);
	String selected_long({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: '${n} transação selecionada',
		other: '${n} transações selecionadas',
	);
	late final _TranslationsTransactionListBulkEditPt bulk_edit = _TranslationsTransactionListBulkEditPt._(_root);
}

// Path: transaction.filters
class _TranslationsTransactionFiltersPt {
	_TranslationsTransactionFiltersPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get from_value => 'A partir do valor';
	String get to_value => 'Até o valor';
	String from_value_def({required Object x}) => 'De ${x}';
	String to_value_def({required Object x}) => 'Até ${x}';
	String from_date_def({required Object date}) => 'De ${date}';
	String to_date_def({required Object date}) => 'Até ${date}';
}

// Path: transaction.form
class _TranslationsTransactionFormPt {
	_TranslationsTransactionFormPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsTransactionFormValidatorsPt validators = _TranslationsTransactionFormValidatorsPt._(_root);
	String get title => 'Descrição';
	String get title_short => 'Descrição';
	String get value => 'Valor da transação';
	String get tap_to_see_more => 'Toque para ver mais detalhes';
	String get no_tags => '-- Sem tags --';
	String get description => 'Comentários';
	String get description_info => 'Toque aqui para inserir uma descrição mais detalhada sobre esta transação';
	String exchange_to_preferred_title({required Object currency}) => 'Taxa de câmbio para ${currency}';
	String get exchange_to_preferred_in_date => 'Na data da transação';
}

// Path: transaction.notes
class _TranslationsTransactionNotesPt {
	_TranslationsTransactionNotesPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Detalhes extras sobre a Transação';
	String get title_short => 'Insira informações adicionais sobre a transação.';
}

// Path: transaction.reversed
class _TranslationsTransactionReversedPt {
	_TranslationsTransactionReversedPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'AINDA NÃO FUNCIONA Transação inversa';
	String get title_short => 'AINDA NÃO FUNCIONA Trans. inversa';
	String get description_for_expenses => 'AINDA NÃO FUNCIONA Apesar de ser uma transação de despesa, ela tem um valor positivo. Esses tipos de transações podem ser usados para representar o retorno de uma despesa previamente registrada, como um reembolso ou o pagamento de uma dívida.';
	String get description_for_incomes => 'AINDA NÃO FUNCIONA Apesar de ser uma transação de receita, ela tem um valor negativo. Esses tipos de transações podem ser usados para anular ou corrigir uma receita que foi registrada incorretamente, para refletir um retorno ou reembolso de dinheiro ou para registrar o pagamento de dívidas.';
}

// Path: transaction.status
class _TranslationsTransactionStatusPt {
	_TranslationsTransactionStatusPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Status',
		other: 'Status',
	);
	String get display_long => 'Status da transação para Insights';
	String tr_status({required Object status}) => 'Transação ${status}';
	String get none => 'Sem status';
	String get insights => 'Insights';
	String get none_descr => 'Transação sem status específico';
	String get reconciled => 'Considerada';
	String get reconciled_descr => 'Esta transação conta para seus insights e saldos.';
	String get unreconciled => 'Não considerada';
	String get unreconciled_descr => 'Esta transação ainda não foi validada e, portanto, ainda não aparece em suas contas bancárias reais. No entanto, ela conta para o cálculo de saldos e insights no Parsa';
	String get notconsidered => 'Desconsiderada';
	String get notconsidered_descr => 'Esta transação não conta para seus insights e saldos.';
	String get pending => 'Pendente';
	String get pending_descr => 'Esta transação está pendente e, portanto, não será considerada no cálculo de saldos e insights';
	String get voided => 'Anulada';
	String get voided_descr => 'Transação anulada/cancelada devido a erro de pagamento ou qualquer outro motivo. Ela não será considerada no cálculo de saldos e insights';
}

// Path: transaction.types
class _TranslationsTransactionTypesPt {
	_TranslationsTransactionTypesPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Tipo de transação',
		other: 'Tipos de transações',
	);
	String income({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Entradas',
		other: 'Entradas',
	);
	String expense({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Saídas',
		other: 'Saídas',
	);
	String outflow({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Gasto',
		other: 'Gastos',
	);
	String transfer({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Transferência',
		other: 'Transferências',
	);
}

// Path: transfer.form
class _TranslationsTransferFormPt {
	_TranslationsTransferFormPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get from => 'Conta de origem';
	String get to => 'Conta de destino';
	late final _TranslationsTransferFormValueInDestinyPt value_in_destiny = _TranslationsTransferFormValueInDestinyPt._(_root);
}

// Path: recurrent_transactions.details
class _TranslationsRecurrentTransactionsDetailsPt {
	_TranslationsRecurrentTransactionsDetailsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Transação recorrente';
	String get descr => 'As próximas transações para esta operação estão listadas abaixo. Você pode aceitar a primeira transação ou optar por ignorá-la';
	String get last_payment_info => 'Esta transação é a última da regra recorrente, portanto, a regra será automaticamente excluída ao confirmar esta ação';
	String get delete_header => 'Excluir transação recorrente';
	String get delete_message => 'Esta ação é irreversível e não afetará as transações que você já confirmou/pagou';
}

// Path: account.types
class _TranslationsAccountTypesPt {
	_TranslationsAccountTypesPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Tipo de conta';
	String get warning => 'Uma vez escolhido o tipo de conta, ele não poderá ser alterado no futuro';
	String get normal => 'Conta corrente';
	String get normal_descr => 'Útil para registrar suas finanças do dia a dia. É a conta mais comum, permite adicionar despesas, receitas...';
	String get saving => 'Investimentos';
	String get saving_descr => 'Você só poderá adicionar e retirar dinheiro dela a partir de outras contas. Perfeito para começar a economizar';
	String get credit => 'Cartão de crédito';
	String get credit_descr => 'Conta que simula uma conta corrente, porém com um saldo negativo. Útil para simular compras parceladas, empréstimos, financiamentos, etc';
	String get wallet => 'Carteira';
	String get wallet_descr => 'Para controlar dinheiro físico (eca!). Usuários Premium terão saques automaticamente creditados nesta conta.';
}

// Path: account.form
class _TranslationsAccountFormPt {
	_TranslationsAccountFormPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Nome da conta';
	String get name_placeholder => 'Ex: Conta poupança';
	String get notes => 'Notas';
	String get notes_placeholder => 'Digite algumas notas/descrição sobre esta conta';
	String get initial_balance => 'Saldo inicial';
	String get current_balance => 'Saldo atual';
	String get create => 'Criar conta';
	String get edit => 'Editar conta';
	String get currency_not_found_warn => 'Você não tem informações sobre taxas de câmbio para esta moeda. 1.0 será usado como a taxa de câmbio padrão. Você pode modificar isso nas configurações';
	String get already_exists => 'Já existe outra com o mesmo nome, por favor escreva outro';
	String get tr_before_opening_date => 'Existem transações nesta conta com uma data anterior à data de abertura';
	String get iban => 'Número de Conta';
	String get swift => 'Agencia';
}

// Path: account.disconnect
class _TranslationsAccountDisconnectPt {
	_TranslationsAccountDisconnectPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Desconectar Banco';
	String get warning_header => 'Desconectar conta?';
	String get warning_text => 'Esta ação cancelerá seu consentimento com o seu banco e não poderemos mais sincronizar suas transações. Esta ação afetará também outros produtos do mesmo banco. Suas transações ainda permanecerão guardadas no Parsa.';
	String get success => 'Conta desconectada com sucesso';
}

// Path: account.remove
class _TranslationsAccountRemovePt {
	_TranslationsAccountRemovePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Remover Conta';
	String get warning_header => 'Deletar?';
	String get warning_text => 'Está ação irá remover esta conta da interface do Parsa, mas seu banco e outras contas continuarão sendo sincronizadas. Esta ação é totalmente reversível. Você deseja continuar?';
	String get success => 'Conta removida com sucesso';
}

// Path: account.restore
class _TranslationsAccountRestorePt {
	_TranslationsAccountRestorePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Restaurar Conta';
	String get warning_header => 'Restaurar?';
	String get warning_text => 'Está ação irá trazer de volta para sincronização automática continua esta conta que você parou de sincronizar. Você gostaria de prosseguir com esta ação?';
	String get success => 'Conta restaurada com sucesso.';
	String get in_progress => 'Restauração da Conta em Andamento. Você pode continuar usando o app.';
}

// Path: account.delete_openfinance
class _TranslationsAccountDeleteOpenfinancePt {
	_TranslationsAccountDeleteOpenfinancePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Remover Banco';
	String get warning_header => 'Deletar?';
	String get warning_text => 'Está ação irá remover seu consentimento com o seu banco, interromperá a sincronização de todas as contas e transações neste banco e excluirá todas as suas transações desta conta no Parsa. Deseja prosseguir?';
	String get success => 'Conta deletada com sucesso';
}

// Path: account.delete
class _TranslationsAccountDeletePt {
	_TranslationsAccountDeletePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get warning_header => 'Excluir conta?';
	String get warning_text => 'Essa ação excluirá essa conta e todas as suas transações';
	String get success => 'Conta excluída com sucesso';
}

// Path: account.close
class _TranslationsAccountClosePt {
	_TranslationsAccountClosePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Fechar conta';
	String get title_short => 'Fechar';
	String get warn => 'Esta conta não aparecerá mais em determinados listagens e você não poderá criar transações nela com uma data posterior à especificada abaixo. Esta ação não afeta nenhuma transação ou saldo, e você também pode reabrir esta conta a qualquer momento.';
	String get should_have_zero_balance => 'Você deve ter um saldo atual de 0 nesta conta para fechá-la. Por favor, edite a conta antes de continuar';
	String get should_have_no_transactions => 'Esta conta possui transações após a data de fechamento especificada. Exclua-as ou edite a data de fechamento da conta antes de continuar';
	String get success => 'Conta fechada com sucesso';
	String get unarchive_succes => 'Conta reaberta com sucesso';
}

// Path: account.select
class _TranslationsAccountSelectPt {
	_TranslationsAccountSelectPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get one => 'Selecione uma conta';
	String get all => 'Todas as contas';
	String get multiple => 'Selecionar contas';
}

// Path: account.connection_errors
class _TranslationsAccountConnectionErrorsPt {
	_TranslationsAccountConnectionErrorsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get not_subscribed => 'Você ainda não é assinante do plano Premium. Por favor, assine o plano Premium para conectar suas contas com o Open Finance.';
	String get limit_reached => 'Você atingiu o limite de 3 contas conectadas. Tente desconectar uma conta para adicionar outra.';
	String get daily_limit_reached => 'O sistema atingiu o limite de conexões diárias. Por favor, tente novamente amanhã.';
	String get item_connection_in_progress => 'Uma conta está em processo de conexão. Por favor, aguarde um momento e tente novamente.';
	String get default_message => 'Não foi possível conectar no momento. Tente novamente mais tarde.';
}

// Path: currencies.form
class _TranslationsCurrenciesFormPt {
	_TranslationsCurrenciesFormPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get equal_to_preferred_warn => 'A moeda não pode ser igual à moeda do usuário';
	String get specify_a_currency => 'Por favor, especifique uma moeda';
	String get add => 'Adicionar taxa de câmbio';
	String get add_success => 'Taxa de câmbio adicionada com sucesso';
	String get edit => 'Editar taxa de câmbio';
	String get edit_success => 'Taxa de câmbio editada com sucesso';
}

// Path: tags.form
class _TranslationsTagsFormPt {
	_TranslationsTagsFormPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Nome da tag';
	String get description => 'Descrição';
}

// Path: categories.select
class _TranslationsCategoriesSelectPt {
	_TranslationsCategoriesSelectPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Selecione categorias';
	String get select_one => 'Selecione uma categoria';
	String get select_subcategory => 'Escolha uma subcategoria';
	String get without_subcategory => 'Sem subcategoria';
	String get all => 'Todas as categorias';
	String get all_short => 'Todas';
}

// Path: budgets.form
class _TranslationsBudgetsFormPt {
	_TranslationsBudgetsFormPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Adicionar um orçamento';
	String get name => 'Nome do orçamento';
	String get value => 'Quantidade limite';
	String get create => 'Adicionar orçamento';
	String get edit => 'Editar orçamento';
	String get negative_warn => 'Os orçamentos não podem ter um valor negativo';
	String get null_warn => 'O valor inserido é inválido.';
}

// Path: budgets.details
class _TranslationsBudgetsDetailsPt {
	_TranslationsBudgetsDetailsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Detalhes do orçamento';
	String get statistics => 'Insights';
	String get budget_value => 'Orçado';
	String expend_diary_left({required Object dailyAmount, required Object remainingDays}) => 'Você pode gastar ${dailyAmount}/dia pelos ${remainingDays} dias restantes';
	String get expend_evolution => 'Evolução dos gastos';
	String get no_transactions => 'Parece que você não fez nenhuma despesa relacionada a este orçamento';
}

// Path: backup.export
class _TranslationsBackupExportPt {
	_TranslationsBackupExportPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Exportar seus dados';
	String get title_short => 'Exportar';
	String get all => 'Backup completo';
	String get all_descr => 'Exporte todos os seus dados (contas, transações, orçamentos, configurações...). Importe-os novamente a qualquer momento para não perder nada.';
	String get transactions => 'Backup de transações';
	String get transactions_descr => 'Exporte suas transações em CSV para que você possa analisá-las mais facilmente em outros programas ou aplicativos.';
	String get description => 'Baixe os dados da suas transações em formato CSV. Recomendamos o uso do Google Sheets para abrir o arquivo por primeira vez - de lá você poderá exportar o arquivo para o Excel.';
	String get dialog_title => 'Salvar/Enviar arquivo';
	String success({required Object x}) => 'Arquivo salvo/baixado com sucesso em ${x}';
	String get error => 'Erro ao baixar o arquivo. Entre em contato com o desenvolvedor via lozin.technologies@gmail.com';
}

// Path: backup.import
class _TranslationsBackupImportPt {
	_TranslationsBackupImportPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Importar seus dados';
	String get title_short => 'Importar';
	String get restore_backup => 'Restaurar backup';
	String get restore_backup_descr => 'Importe um banco de dados salvo anteriormente do Parsa. Esta ação substituirá todos os dados atuais do aplicativo pelos novos dados';
	String get restore_backup_warn_description => 'Ao importar um novo banco de dados, você perderá todos os dados atualmente salvos no aplicativo. Recomenda-se fazer um backup antes de continuar. Não carregue aqui nenhum arquivo cuja origem você não conheça, carregue apenas arquivos que você tenha baixado anteriormente do Parsa';
	String get restore_backup_warn_title => 'Sobrescrever todos os dados';
	String get select_other_file => 'Selecionar outro arquivo';
	String get tap_to_select_file => 'Toque para selecionar um arquivo';
	late final _TranslationsBackupImportManualImportPt manual_import = _TranslationsBackupImportManualImportPt._(_root);
	String get success => 'Importação realizada com sucesso';
	String get cancelled => 'A importação foi cancelada pelo usuário';
	String get error => 'Erro ao importar arquivo. Entre em contato com o desenvolvedor via lozin.technologies@gmail.com';
}

// Path: backup.about
class _TranslationsBackupAboutPt {
	_TranslationsBackupAboutPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Informações sobre seu banco de dados';
	String get create_date => 'Data de criação';
	String get modify_date => 'Última modificação';
	String get last_backup => 'Último backup';
	String get size => 'Tamanho';
}

// Path: settings.dashboard
class _TranslationsSettingsDashboardPt {
	_TranslationsSettingsDashboardPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Personalizar Dashboard';
}

// Path: settings.security
class _TranslationsSettingsSecurityPt {
	_TranslationsSettingsSecurityPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Privacidade';
	String get private_mode_at_launch => 'Modo privado ao iniciar';
	String get private_mode_at_launch_descr => 'Inicie o aplicativo no modo privado por padrão';
	String get private_mode => 'Modo privado';
	String get private_mode_descr => 'Oculte todos os valores monetários';
	String get private_mode_activated => 'Modo privado ativado';
	String get private_mode_deactivated => 'Modo privado desativado';
}

// Path: more.data
class _TranslationsMoreDataPt {
	_TranslationsMoreDataPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Dados';
	String get display_descr => 'Exporte os dados da suas transações.';
	String get delete_all => 'Excluir meus dados';
	String get delete_all_header1 => 'Pare aí, padawan ⚠️⚠️';
	String get delete_all_message1 => 'Tem certeza de que deseja continuar? Todos os seus dados serão excluídos permanentemente e não poderão ser recuperados';
	String get delete_all_header2 => 'Último passo ⚠️⚠️';
	String get delete_all_message2 => 'Ao excluir uma conta, você excluirá todos os seus dados pessoais armazenados. Suas contas, transações, orçamentos e categorias serão excluídos e não poderão ser recuperados. Você concorda?';
}

// Path: more.subscribe
class _TranslationsMoreSubscribePt {
	_TranslationsMoreSubscribePt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Assinatura';
	String get description => 'Assine o Parsa para desbloquear todos os recursos Premium.';
	String get title => 'Assinatura Premium';
	String get subscribe => 'Assinar';
	String subscribe_for({required Object price}) => 'Assinar por ${price}';
	String get confirm_subscription => 'Confirmar assinatura';
	String confirm_message({required Object price}) => 'Você está prestes a assinar o Parsa Premium por ${price}. Deseja continuar?';
	String get no_plans_available => 'Nenhum plano disponível no momento';
	String get success => 'Assinatura realizada com sucesso!';
	String get error => 'Erro ao processar a assinatura. Por favor, tente novamente.';
	String get cancel => 'Cancelar';
}

// Path: more.about_us
class _TranslationsMoreAboutUsPt {
	_TranslationsMoreAboutUsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Informações';
	String get description => 'Informações sobre o Parsa, entre em contato conosco, envie sugestões, etc. ';
	late final _TranslationsMoreAboutUsLegalPt legal = _TranslationsMoreAboutUsLegalPt._(_root);
	late final _TranslationsMoreAboutUsProjectPt project = _TranslationsMoreAboutUsProjectPt._(_root);
}

// Path: more.help_us
class _TranslationsMoreHelpUsPt {
	_TranslationsMoreHelpUsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Ajude-nos';
	String get description => 'Descubra como você pode ajudar o Parsa a ficar cada vez melhor';
	String get rate_us => 'Nos avalie';
	String get rate_us_descr => 'Qualquer avaliação é bem-vinda!';
	String get share => 'Compartilhar o Parsa';
	String get share_descr => 'Compartilhe nosso aplicativo com amigos e familiares';
	String get share_text => 'Parsa! O melhor aplicativo de finanças pessoais. Baixe aqui';
	String get thanks => 'Obrigado!';
	String get thanks_long => 'Suas contribuições para o Parsa e outros projetos de código aberto, grandes e pequenos, tornam possíveis grandes projetos como este. Obrigado por dedicar seu tempo para contribuir.';
	String get donate => 'Faça uma doação';
	String get donate_descr => 'Com sua doação, você ajudará o aplicativo a continuar recebendo melhorias. Que melhor maneira de agradecer pelo trabalho feito do que me convidar para um café?';
	String get donate_success => 'Doação realizada. Muito obrigado pela sua contribuição! ❤️';
	String get donate_err => 'Oops! Parece que houve um erro ao receber seu pagamento';
	String get report => 'Entre em contato.';
}

// Path: general.time.ranges
class _TranslationsGeneralTimeRangesPt {
	_TranslationsGeneralTimeRangesPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Intervalo de tempo';
	String get it_repeat => 'Repete';
	String get it_ends => 'Termina';
	String get forever => 'Para sempre';
	late final _TranslationsGeneralTimeRangesTypesPt types = _TranslationsGeneralTimeRangesTypesPt._(_root);
	String each_range({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Todo ${range}',
		other: 'Todo ${n} ${range}',
	);
	String each_range_until_date({required num n, required Object range, required Object day}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Todo ${range} até ${day}',
		other: 'Todo ${n} ${range} até ${day}',
	);
	String each_range_until_times({required num n, required Object range, required Object limit}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Todo ${range} ${limit} vezes',
		other: 'Todo ${n} ${range} ${limit} vezes',
	);
	String each_range_until_once({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Todo ${range} uma vez',
		other: 'Todo ${n} ${range} uma vez',
	);
	String month({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Mês',
		other: 'Meses',
	);
	String year({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Ano',
		other: 'Anos',
	);
	String day({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Dia',
		other: 'Dias',
	);
	String week({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Semana',
		other: 'Semanas',
	);
}

// Path: general.time.periodicity
class _TranslationsGeneralTimePeriodicityPt {
	_TranslationsGeneralTimePeriodicityPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Recorrência';
	String get no_repeat => 'Definir Minhas Datas';
	String repeat({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Repetição',
		other: 'Repetições',
	);
	String get diary => 'Diariamente';
	String get monthly => 'Mensalmente';
	String get annually => 'Anualmente';
	String get quaterly => 'Trimestralmente';
	String get weekly => 'Semanalmente';
	String get custom => 'Personalizado';
	String get infinite => 'Sempre';
}

// Path: general.time.current
class _TranslationsGeneralTimeCurrentPt {
	_TranslationsGeneralTimeCurrentPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get monthly => 'Este mês';
	String get annually => 'Este ano';
	String get quaterly => 'Este trimestre';
	String get weekly => 'Esta semana';
	String get infinite => 'Para sempre';
	String get custom => 'Intervalo personalizado';
}

// Path: general.time.all
class _TranslationsGeneralTimeAllPt {
	_TranslationsGeneralTimeAllPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get diary => 'Diário';
	String get monthly => 'Mensal';
	String get biweekly => 'Quinzenal';
	String get annually => 'Anual';
	String get quaterly => 'Trimestral';
	String get weekly => 'Semanal';
}

// Path: financial_health.review.descr
class _TranslationsFinancialHealthReviewDescrPt {
	_TranslationsFinancialHealthReviewDescrPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get insufficient_data => 'Você não possui atividade financeira no período para que possamos calcular sua saúde financeira. Conecte uma conta bancária agora mesmo para começar a monitorar suas finanças!';
	String get very_good => 'Parabéns! Sua saúde financeira está excelente. Esperamos que continue em sua boa fase e continue aprendendo com o Parsa. (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
	String get good => 'Ótimo! Sua saúde financeira está boa. Visite a aba de Insights para ver como economizar ainda mais! (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
	String get normal => 'Sua saúde financeira está mais ou menos na média do restante da população para este período (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
	String get bad => 'Parece que sua situação financeira ainda não é das melhores. Explore o restante dos gráficos para aprender mais sobre suas finanças. (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
	String get very_bad => 'Hmm, sua saúde financeira está muito abaixo do esperado. Explore o restante dos gráficos para aprender mais sobre suas finanças (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
}

// Path: financial_health.savings_percentage.text
class _TranslationsFinancialHealthSavingsPercentageTextPt {
	_TranslationsFinancialHealthSavingsPercentageTextPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String good({required Object value}) => 'Parabéns! Você conseguiu economizar <b>${value}%</b> da sua renda durante este período. Parece que você já é um especialista, continue assim!';
	String normal({required Object value}) => 'Parabéns, você conseguiu economizar <b>${value}%</b> da sua renda durante este período.';
	String bad({required Object value}) => 'Você conseguiu economizar <b>${value}%</b> da sua renda durante este período. No entanto, achamos que você ainda pode fazer muito mais!';
	String get very_bad => 'Você não conseguiu economizar nada durante este período.';
}

// Path: transaction.list.bulk_edit
class _TranslationsTransactionListBulkEditPt {
	_TranslationsTransactionListBulkEditPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get dates => 'Editar datas';
	String get categories => 'Editar categorias';
	String get status => 'Editar status';
}

// Path: transaction.form.validators
class _TranslationsTransactionFormValidatorsPt {
	_TranslationsTransactionFormValidatorsPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get zero => 'O valor de uma transação não pode ser igual a zero';
	String get date_max => 'A data selecionada é posterior à atual. A transação será adicionada como pendente';
	String get date_after_account_creation => 'Você não pode criar uma transação cuja data seja anterior à data de criação da conta a que pertence';
	String get negative_transfer => 'O valor monetário de uma transferência não pode ser negativo';
	String get transfer_between_same_accounts => 'A conta de origem e a conta de destino não podem ser a mesma';
}

// Path: transfer.form.value_in_destiny
class _TranslationsTransferFormValueInDestinyPt {
	_TranslationsTransferFormValueInDestinyPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Valor transferido no destino';
	String amount_short({required Object amount}) => '${amount} para conta de destino';
}

// Path: backup.import.manual_import
class _TranslationsBackupImportManualImportPt {
	_TranslationsBackupImportManualImportPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Importar histórico manualmente';
	String get descr => 'Importe transações de um arquivo .csv manualmente. Se você estiver usando sincronização do Open Finance, por favor não inclua transações do período de sincronização para evitar duplicidade.';
	String get default_account => 'Conta padrão';
	String get remove_default_account => 'Remover conta padrão';
	String get default_category => 'Categoria padrão';
	String get select_a_column => 'Selecione uma coluna do .csv';
	List<String> get steps => [
		'Selecione seu arquivo',
		'Coluna para quantidade',
		'Coluna para conta',
		'Coluna para categoria',
		'Coluna para data',
		'outras colunas',
	];
	List<String> get steps_descr => [
		'Selecione um arquivo .csv do seu dispositivo. Certifique-se de que ele tenha uma primeira linha que descreva o nome de cada coluna',
		'Selecione a coluna onde o valor de cada transação é especificado. Use valores negativos para despesas e valores positivos para receitas. Use ponto como separador decimal',
		'Selecione a coluna onde a conta à qual cada transação pertence é especificada. Você também pode selecionar uma conta padrão caso não consigamos encontrar a conta que deseja. Se uma conta padrão não for especificada, criaremos uma com o mesmo nome',
		'Especifique a coluna onde o nome da categoria da transação está localizado. Você deve especificar uma categoria padrão para que possamos atribuir essa categoria às transações, caso a categoria não possa ser encontrada',
		'Selecione a coluna onde a data de cada transação é especificada. Se não for especificado, as transações serão criadas na data atual',
		'Especifique as colunas para outros atributos opcionais da transação',
	];
	String success({required Object x}) => 'Importado com sucesso ${x} transações';
}

// Path: more.about_us.legal
class _TranslationsMoreAboutUsLegalPt {
	_TranslationsMoreAboutUsLegalPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Informações legais';
	String get privacy => 'Política de Privacidade e LGPD';
	String get terms => 'Termos de Uso e Serviço';
	String get licenses => 'Licenças';
}

// Path: more.about_us.project
class _TranslationsMoreAboutUsProjectPt {
	_TranslationsMoreAboutUsProjectPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get about_us => 'Sobre o Parsa';
	String get display => 'Sobre';
	String get contributors => 'Colaboradores';
	String get contributors_descr => 'Todos os desenvolvedores que ajudaram o Parsa a crescer';
	String get contact => 'Entre em contato';
}

// Path: general.time.ranges.types
class _TranslationsGeneralTimeRangesTypesPt {
	_TranslationsGeneralTimeRangesTypesPt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get cycle => 'Ciclos';
	String get last_days => 'Últimos dias';
	String last_days_form({required Object x}) => '${x} dias anteriores';
	String get all => 'Sempre';
	String get date_range => 'Intervalo personalizado';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'connections.success': return 'Sincronização concluída com sucesso. Vamos analisar seus dados. Em um minuto, tente atualizar a tela para ver seus dados atualizados.';
			case 'connections.error': return 'Ocorreu um erro ao sincronizar seus dados. Por favor, tente novamente mais tarde.';
			case 'general.cancel': return 'Cancelar';
			case 'general.or': return 'ou';
			case 'general.understood': return 'Entendido';
			case 'general.unspecified': return 'Não especificado';
			case 'general.confirm': return 'Confirmar';
			case 'general.continue_text': return 'Continuar';
			case 'general.quick_actions': return 'Ações rápidas';
			case 'general.save': return 'Salvar';
			case 'general.save_changes': return 'Salvar alterações';
			case 'general.close_and_save': return 'Salvar e fechar';
			case 'general.add': return 'Adicionar';
			case 'general.edit': return 'Editar';
			case 'general.balance': return 'Saldo';
			case 'general.delete': return 'Excluir';
			case 'general.account': return 'Conta';
			case 'general.accounts': return 'Contas';
			case 'general.categories': return 'Categorias';
			case 'general.category': return 'Categoria';
			case 'general.today': return 'Hoje';
			case 'general.yesterday': return 'Ontem';
			case 'general.filters': return 'Filtros';
			case 'general.select_all': return 'Selecionar tudo';
			case 'general.deselect_all': return 'Desmarcar tudo';
			case 'general.empty_warn': return 'Ops! Isso está muito vazio';
			case 'general.insufficient_data': return 'Dados insuficientes';
			case 'general.show_more_fields': return 'Mostrar mais campos';
			case 'general.show_less_fields': return 'Mostrar menos campos';
			case 'general.tap_to_search': return 'Toque para pesquisar';
			case 'general.clipboard.success': return ({required Object x}) => '${x} copiado para a área de transferência';
			case 'general.clipboard.error': return 'Erro ao copiar';
			case 'general.time.start_date': return 'Data de início';
			case 'general.time.end_date': return 'Data de término';
			case 'general.time.from_date': return 'A partir da data';
			case 'general.time.until_date': return 'Até a data';
			case 'general.time.date': return 'Data';
			case 'general.time.datetime': return 'Data e hora';
			case 'general.time.time': return 'Hora';
			case 'general.time.each': return 'Cada';
			case 'general.time.after': return 'Após';
			case 'general.time.ranges.display': return 'Intervalo de tempo';
			case 'general.time.ranges.it_repeat': return 'Repete';
			case 'general.time.ranges.it_ends': return 'Termina';
			case 'general.time.ranges.forever': return 'Para sempre';
			case 'general.time.ranges.types.cycle': return 'Ciclos';
			case 'general.time.ranges.types.last_days': return 'Últimos dias';
			case 'general.time.ranges.types.last_days_form': return ({required Object x}) => '${x} dias anteriores';
			case 'general.time.ranges.types.all': return 'Sempre';
			case 'general.time.ranges.types.date_range': return 'Intervalo personalizado';
			case 'general.time.ranges.each_range': return ({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Todo ${range}',
				other: 'Todo ${n} ${range}',
			);
			case 'general.time.ranges.each_range_until_date': return ({required num n, required Object range, required Object day}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Todo ${range} até ${day}',
				other: 'Todo ${n} ${range} até ${day}',
			);
			case 'general.time.ranges.each_range_until_times': return ({required num n, required Object range, required Object limit}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Todo ${range} ${limit} vezes',
				other: 'Todo ${n} ${range} ${limit} vezes',
			);
			case 'general.time.ranges.each_range_until_once': return ({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Todo ${range} uma vez',
				other: 'Todo ${n} ${range} uma vez',
			);
			case 'general.time.ranges.month': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Mês',
				other: 'Meses',
			);
			case 'general.time.ranges.year': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Ano',
				other: 'Anos',
			);
			case 'general.time.ranges.day': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Dia',
				other: 'Dias',
			);
			case 'general.time.ranges.week': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Semana',
				other: 'Semanas',
			);
			case 'general.time.periodicity.display': return 'Recorrência';
			case 'general.time.periodicity.no_repeat': return 'Definir Minhas Datas';
			case 'general.time.periodicity.repeat': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Repetição',
				other: 'Repetições',
			);
			case 'general.time.periodicity.diary': return 'Diariamente';
			case 'general.time.periodicity.monthly': return 'Mensalmente';
			case 'general.time.periodicity.annually': return 'Anualmente';
			case 'general.time.periodicity.quaterly': return 'Trimestralmente';
			case 'general.time.periodicity.weekly': return 'Semanalmente';
			case 'general.time.periodicity.custom': return 'Personalizado';
			case 'general.time.periodicity.infinite': return 'Sempre';
			case 'general.time.current.monthly': return 'Este mês';
			case 'general.time.current.annually': return 'Este ano';
			case 'general.time.current.quaterly': return 'Este trimestre';
			case 'general.time.current.weekly': return 'Esta semana';
			case 'general.time.current.infinite': return 'Para sempre';
			case 'general.time.current.custom': return 'Intervalo personalizado';
			case 'general.time.all.diary': return 'Diário';
			case 'general.time.all.monthly': return 'Mensal';
			case 'general.time.all.biweekly': return 'Quinzenal';
			case 'general.time.all.annually': return 'Anual';
			case 'general.time.all.quaterly': return 'Trimestral';
			case 'general.time.all.weekly': return 'Semanal';
			case 'general.transaction_order.display': return 'Ordenar transações';
			case 'general.transaction_order.category': return 'Por categoria';
			case 'general.transaction_order.quantity': return 'Por quantidade';
			case 'general.transaction_order.date': return 'Por data';
			case 'general.validations.required': return 'Campo obrigatório';
			case 'general.validations.positive': return 'Deve ser positivo';
			case 'general.validations.min_number': return ({required Object x}) => 'Deve ser maior que ${x}';
			case 'general.validations.max_number': return ({required Object x}) => 'Deve ser menor que ${x}';
			case 'intro.start': return 'Começar';
			case 'intro.skip': return 'Pular';
			case 'intro.next': return 'Próximo';
			case 'intro.select_your_currency': return 'Selecione sua moeda';
			case 'intro.welcome_subtitle': return 'Seu gerente financeiro pessoal';
			case 'intro.welcome_subtitle2': return 'Controle Financeiro sem esforço.';
			case 'intro.welcome_footer': return 'Ao entrar, você concorda com a <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/PRIVACY_POLICY.md\'>Política de Privacidade</a> e os <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/TERMS_OF_USE.md\'>Termos de Uso</a> do aplicativo';
			case 'intro.offline_descr_title': return 'CONTA OFFLINE:';
			case 'intro.offline_descr': return 'Seus dados serão armazenados apenas no seu dispositivo e estarão seguros enquanto você não desinstalar o aplicativo ou trocar de telefone. Para evitar a perda de dados, é recomendável fazer backup regularmente nas configurações do aplicativo.';
			case 'intro.offline_start': return 'Iniciar sessão offline';
			case 'intro.sl1_title': return 'Selecione sua moeda';
			case 'intro.sl1_descr': return 'Sua moeda padrão será usada em relatórios e gráficos gerais. Você poderá alterar a moeda e o idioma do aplicativo mais tarde a qualquer momento nas configurações do aplicativo';
			case 'intro.sl2_title': return 'Seguro, privado e confiável';
			case 'intro.sl2_descr': return 'Seus dados são apenas seus. Armazenamos as informações diretamente no seu dispositivo, sem passar por servidores externos. Isso possibilita o uso do aplicativo mesmo sem internet';
			case 'intro.sl2_descr2': return 'Além disso, o código-fonte do aplicativo é público, qualquer pessoa pode colaborar e ver como ele funciona';
			case 'intro.last_slide_title': return 'Tudo pronto';
			case 'intro.last_slide_descr': return 'Com o Parsa, você finalmente pode alcançar a independência financeira que tanto deseja. Você terá gráficos, orçamentos, dicas, insights e muito mais sobre seu dinheiro.';
			case 'intro.last_slide_descr2': return 'Esperamos que aproveite sua experiência! Não hesite em nos contatar em caso de dúvidas, sugestões...';
			case 'home.title': return 'Início';
			case 'home.filter_transactions': return 'Filtrar transações';
			case 'home.hello_day': return 'Bom dia,';
			case 'home.hello_night': return 'Boa noite,';
			case 'home.total_balance': return 'Saldo Disponível';
			case 'home.total_balance_tooltip': return 'Soma de todos os saldos das suas contas menos os saldos do cartão de crédito e empréstimos.';
			case 'home.available_balance': return 'Saldo disponível';
			case 'home.available_balance_tooltip': return 'Soma de todos os saldos das suas contas menos os saldos do cartão de crédito e empréstimos.';
			case 'home.future_balance': return 'Saldo futuro';
			case 'home.future_balance_tooltip': return 'Soma de todos os saldos das suas contas menos os saldos do cartão de crédito e empréstimos.';
			case 'home.my_accounts': return 'Minhas contas';
			case 'home.active_accounts': return 'Contas ativas';
			case 'home.no_accounts': return 'Nenhuma conta criada ainda';
			case 'home.no_accounts_descr': return 'Comece a usar toda a magia do Parsa. Crie pelo menos uma conta para começar a adicionar transações';
			case 'home.last_transactions': return 'Últimas transações';
			case 'home.should_create_account_header': return 'Ops!';
			case 'home.should_create_account_message': return 'Você deve ter pelo menos uma conta não arquivada antes de começar a criar transações';
			case 'financial_health.display': return 'Saúde financeira';
			case 'financial_health.review.very_good': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Muito bom!';
					case GenderContext.female:
						return 'Muito bom!';
				}
			};
			case 'financial_health.review.good': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Bom';
					case GenderContext.female:
						return 'Bom';
				}
			};
			case 'financial_health.review.normal': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Razoável';
					case GenderContext.female:
						return 'Razoável';
				}
			};
			case 'financial_health.review.bad': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Ruim';
					case GenderContext.female:
						return 'Ruim';
				}
			};
			case 'financial_health.review.very_bad': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Muito ruim';
					case GenderContext.female:
						return 'Muito ruim';
				}
			};
			case 'financial_health.review.insufficient_data': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Dados insuficientes';
					case GenderContext.female:
						return 'Dados insuficientes';
				}
			};
			case 'financial_health.review.descr.insufficient_data': return 'Você não possui atividade financeira no período para que possamos calcular sua saúde financeira. Conecte uma conta bancária agora mesmo para começar a monitorar suas finanças!';
			case 'financial_health.review.descr.very_good': return 'Parabéns! Sua saúde financeira está excelente. Esperamos que continue em sua boa fase e continue aprendendo com o Parsa. (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
			case 'financial_health.review.descr.good': return 'Ótimo! Sua saúde financeira está boa. Visite a aba de Insights para ver como economizar ainda mais! (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
			case 'financial_health.review.descr.normal': return 'Sua saúde financeira está mais ou menos na média do restante da população para este período (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
			case 'financial_health.review.descr.bad': return 'Parece que sua situação financeira ainda não é das melhores. Explore o restante dos gráficos para aprender mais sobre suas finanças. (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
			case 'financial_health.review.descr.very_bad': return 'Hmm, sua saúde financeira está muito abaixo do esperado. Explore o restante dos gráficos para aprender mais sobre suas finanças (Este recurso ainda é experimental e não deve ser considerado como uma ferramenta de decisão financeira).';
			case 'financial_health.months_without_income.title': return 'Taxa de sobrevivência';
			case 'financial_health.months_without_income.subtitle': return 'Dado seu saldo, tempo que você poderia viver sem renda';
			case 'financial_health.months_without_income.text_zero': return 'Você não conseguiria sobreviver um mês sem renda neste ritmo de despesas!';
			case 'financial_health.months_without_income.text_one': return 'Você mal conseguiria sobreviver aproximadamente um mês sem renda neste ritmo de despesas!';
			case 'financial_health.months_without_income.text_other': return ({required Object n}) => 'Você conseguiria sobreviver aproximadamente <b>${n} meses</b> sem renda neste ritmo de despesas.';
			case 'financial_health.months_without_income.text_infinite': return 'Você conseguiria sobreviver aproximadamente <b>toda a vida</b> sem renda neste ritmo de despesas.';
			case 'financial_health.months_without_income.suggestion': return 'Lembre-se de que é aconselhável sempre manter essa proporção acima de 5 meses, pelo menos. Se você perceber que não tem uma reserva de emergência suficiente, reduza as despesas desnecessárias.';
			case 'financial_health.months_without_income.insufficient_data': return 'Parece que não temos despesas suficientes para calcular quantos meses você poderia sobreviver sem renda. Insira algumas transações e volte aqui para verificar sua saúde financeira';
			case 'financial_health.savings_percentage.title': return 'Porcentagem de economia';
			case 'financial_health.savings_percentage.subtitle': return 'Qual parte da sua renda não foi gasta neste período';
			case 'financial_health.savings_percentage.text.good': return ({required Object value}) => 'Parabéns! Você conseguiu economizar <b>${value}%</b> da sua renda durante este período. Parece que você já é um especialista, continue assim!';
			case 'financial_health.savings_percentage.text.normal': return ({required Object value}) => 'Parabéns, você conseguiu economizar <b>${value}%</b> da sua renda durante este período.';
			case 'financial_health.savings_percentage.text.bad': return ({required Object value}) => 'Você conseguiu economizar <b>${value}%</b> da sua renda durante este período. No entanto, achamos que você ainda pode fazer muito mais!';
			case 'financial_health.savings_percentage.text.very_bad': return 'Você não conseguiu economizar nada durante este período.';
			case 'financial_health.savings_percentage.suggestion': return 'Lembre-se de que é aconselhável economizar pelo menos 15-20% do que você ganha.';
			case 'stats.title': return 'Insights';
			case 'stats.balance': return 'Saldo';
			case 'stats.final_balance': return 'Saldo final';
			case 'stats.balance_by_account': return 'Saldo por contas';
			case 'stats.balance_by_currency': return 'Saldo por moeda';
			case 'stats.cash_flow': return 'Fluxo de caixa';
			case 'stats.balance_evolution': return 'Evolução do saldo';
			case 'stats.compared_to_previous_period': return 'Comparado ao período anterior';
			case 'stats.by_periods': return 'Por períodos';
			case 'stats.by_categories': return 'Por categorias';
			case 'stats.by_tags': return 'Por tags';
			case 'stats.distribution': return 'Categorias';
			case 'stats.finance_health_resume': return 'Resumo';
			case 'stats.finance_health_breakdown': return 'Detalhamento';
			case 'icon_selector.name': return 'Nome:';
			case 'icon_selector.icon': return 'Ícone';
			case 'icon_selector.color': return 'Cor';
			case 'icon_selector.select_icon': return 'Selecione um ícone';
			case 'icon_selector.select_color': return 'Selecione uma cor';
			case 'icon_selector.select_account_icon': return 'Identifique sua conta';
			case 'icon_selector.select_category_icon': return 'Identifique sua categoria';
			case 'icon_selector.scopes.transport': return 'Transporte';
			case 'icon_selector.scopes.money': return 'Dinheiro';
			case 'icon_selector.scopes.food': return 'Alimentação';
			case 'icon_selector.scopes.medical': return 'Saúde';
			case 'icon_selector.scopes.entertainment': return 'Lazer';
			case 'icon_selector.scopes.technology': return 'Tecnologia';
			case 'icon_selector.scopes.other': return 'Outros';
			case 'icon_selector.scopes.logos_financial_institutions': return 'Instituições financeiras';
			case 'transaction.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Transações',
				other: 'Transações',
			);
			case 'transaction.title': return 'Info';
			case 'transaction.source': return 'Origem';
			case 'transaction.openfinance_source': return 'Open Finance';
			case 'transaction.manual_source': return 'Manual';
			case 'transaction.manipulated': return 'Modificada pelo usuário';
			case 'transaction.synch_method': return 'Sincronizada';
			case 'transaction.synch_auto': return 'Automaticamente (Open Finance)';
			case 'transaction.synch_manual': return 'Manualmente';
			case 'transaction.yes': return 'Sim';
			case 'transaction.no': return 'Não';
			case 'transaction.delete_openfinance_error': return 'Não é possível deletar transações do Open Finance. Caso você queira desconsiderar uma transação, use a opção \'Desconsiderada\' dentro do card da transação.';
			case 'transaction.last_update': return 'Última atualização';
			case 'transaction.payment_method': return 'Forma de pagamento';
			case 'transaction.create': return 'Nova transação';
			case 'transaction.new_income': return 'Nova receita';
			case 'transaction.new_expense': return 'Nova despesa';
			case 'transaction.new_success': return 'Transação criada com sucesso';
			case 'transaction.edit': return 'Editar transação';
			case 'transaction.edit_success': return 'Transação editada com sucesso';
			case 'transaction.edit_multiple': return 'Editar transações';
			case 'transaction.edit_multiple_success': return ({required Object x}) => '${x} transações editadas com sucesso';
			case 'transaction.duplicate': return 'Clonar transação';
			case 'transaction.duplicate_short': return 'Clonar';
			case 'transaction.duplicate_warning_message': return 'Uma transação idêntica a esta será criada com a mesma data, deseja continuar?';
			case 'transaction.duplicate_success': return 'Transação clonada com sucesso';
			case 'transaction.delete': return 'Excluir transação';
			case 'transaction.delete_warning_message': return 'Essa ação é irreversível. Prefira usar o status \'Desconsiderada\' para remover a transação das suas análises. O saldo atual de suas contas e todas as suas análises serão recalculados';
			case 'transaction.delete_success': return 'Transação excluída com sucesso.';
			case 'transaction.delete_multiple': return 'Excluir com sucesso';
			case 'transaction.delete_multiple_warning_message': return ({required Object x}) => 'Essa ação é irreversível e removerá ${x} transações. O saldo atual de suas contas e todas as suas análises serão recalculados';
			case 'transaction.delete_multiple_success': return ({required Object x}) => '${x} transações excluídas com sucesso';
			case 'transaction.details': return 'Detalhes da transação';
			case 'transaction.transaction_cousin': return 'Transações Similares';
			case 'transaction.next_payments.accept': return 'Aceitar';
			case 'transaction.next_payments.skip': return 'Pular';
			case 'transaction.next_payments.skip_success': return 'Transação pulada com sucesso';
			case 'transaction.next_payments.skip_dialog_title': return 'Pular transação';
			case 'transaction.next_payments.skip_dialog_msg': return ({required Object date}) => 'Essa ação é irreversível. Vamos mover a data da próxima transação para ${date}';
			case 'transaction.next_payments.accept_today': return 'Aceitar hoje';
			case 'transaction.next_payments.accept_in_required_date': return ({required Object date}) => 'Aceitar na data requerida (${date})';
			case 'transaction.next_payments.accept_dialog_title': return 'Aceitar transação';
			case 'transaction.next_payments.accept_dialog_msg_single': return 'O novo status da transação será nulo. Você pode re-editar o status dessa transação sempre que quiser';
			case 'transaction.next_payments.accept_dialog_msg': return ({required Object date}) => 'Essa ação criará uma nova transação com data ${date}. Você poderá verificar os detalhes desta transação na página de transações';
			case 'transaction.next_payments.recurrent_rule_finished': return 'A regra recorrente foi concluída, não há mais pagamentos a serem feitos!';
			case 'transaction.list.empty': return 'Nenhuma transação encontrada para exibir aqui. Adicione uma transação clicando no botão \'+\' na parte inferior';
			case 'transaction.list.searcher_placeholder': return 'Pesquisar por categoria, descrição...';
			case 'transaction.list.searcher_no_results': return 'Nenhuma transação encontrada correspondente aos critérios de pesquisa';
			case 'transaction.list.loading': return 'Carregando mais transações...';
			case 'transaction.list.selected_short': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: '${n} selecionada',
				other: '${n} selecionadas',
			);
			case 'transaction.list.selected_long': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: '${n} transação selecionada',
				other: '${n} transações selecionadas',
			);
			case 'transaction.list.bulk_edit.dates': return 'Editar datas';
			case 'transaction.list.bulk_edit.categories': return 'Editar categorias';
			case 'transaction.list.bulk_edit.status': return 'Editar status';
			case 'transaction.filters.from_value': return 'A partir do valor';
			case 'transaction.filters.to_value': return 'Até o valor';
			case 'transaction.filters.from_value_def': return ({required Object x}) => 'De ${x}';
			case 'transaction.filters.to_value_def': return ({required Object x}) => 'Até ${x}';
			case 'transaction.filters.from_date_def': return ({required Object date}) => 'De ${date}';
			case 'transaction.filters.to_date_def': return ({required Object date}) => 'Até ${date}';
			case 'transaction.form.validators.zero': return 'O valor de uma transação não pode ser igual a zero';
			case 'transaction.form.validators.date_max': return 'A data selecionada é posterior à atual. A transação será adicionada como pendente';
			case 'transaction.form.validators.date_after_account_creation': return 'Você não pode criar uma transação cuja data seja anterior à data de criação da conta a que pertence';
			case 'transaction.form.validators.negative_transfer': return 'O valor monetário de uma transferência não pode ser negativo';
			case 'transaction.form.validators.transfer_between_same_accounts': return 'A conta de origem e a conta de destino não podem ser a mesma';
			case 'transaction.form.title': return 'Descrição';
			case 'transaction.form.title_short': return 'Descrição';
			case 'transaction.form.value': return 'Valor da transação';
			case 'transaction.form.tap_to_see_more': return 'Toque para ver mais detalhes';
			case 'transaction.form.no_tags': return '-- Sem tags --';
			case 'transaction.form.description': return 'Comentários';
			case 'transaction.form.description_info': return 'Toque aqui para inserir uma descrição mais detalhada sobre esta transação';
			case 'transaction.form.exchange_to_preferred_title': return ({required Object currency}) => 'Taxa de câmbio para ${currency}';
			case 'transaction.form.exchange_to_preferred_in_date': return 'Na data da transação';
			case 'transaction.notes.title': return 'Detalhes extras sobre a Transação';
			case 'transaction.notes.title_short': return 'Insira informações adicionais sobre a transação.';
			case 'transaction.reversed.title': return 'AINDA NÃO FUNCIONA Transação inversa';
			case 'transaction.reversed.title_short': return 'AINDA NÃO FUNCIONA Trans. inversa';
			case 'transaction.reversed.description_for_expenses': return 'AINDA NÃO FUNCIONA Apesar de ser uma transação de despesa, ela tem um valor positivo. Esses tipos de transações podem ser usados para representar o retorno de uma despesa previamente registrada, como um reembolso ou o pagamento de uma dívida.';
			case 'transaction.reversed.description_for_incomes': return 'AINDA NÃO FUNCIONA Apesar de ser uma transação de receita, ela tem um valor negativo. Esses tipos de transações podem ser usados para anular ou corrigir uma receita que foi registrada incorretamente, para refletir um retorno ou reembolso de dinheiro ou para registrar o pagamento de dívidas.';
			case 'transaction.status.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Status',
				other: 'Status',
			);
			case 'transaction.status.display_long': return 'Status da transação para Insights';
			case 'transaction.status.tr_status': return ({required Object status}) => 'Transação ${status}';
			case 'transaction.status.none': return 'Sem status';
			case 'transaction.status.insights': return 'Insights';
			case 'transaction.status.none_descr': return 'Transação sem status específico';
			case 'transaction.status.reconciled': return 'Considerada';
			case 'transaction.status.reconciled_descr': return 'Esta transação conta para seus insights e saldos.';
			case 'transaction.status.unreconciled': return 'Não considerada';
			case 'transaction.status.unreconciled_descr': return 'Esta transação ainda não foi validada e, portanto, ainda não aparece em suas contas bancárias reais. No entanto, ela conta para o cálculo de saldos e insights no Parsa';
			case 'transaction.status.notconsidered': return 'Desconsiderada';
			case 'transaction.status.notconsidered_descr': return 'Esta transação não conta para seus insights e saldos.';
			case 'transaction.status.pending': return 'Pendente';
			case 'transaction.status.pending_descr': return 'Esta transação está pendente e, portanto, não será considerada no cálculo de saldos e insights';
			case 'transaction.status.voided': return 'Anulada';
			case 'transaction.status.voided_descr': return 'Transação anulada/cancelada devido a erro de pagamento ou qualquer outro motivo. Ela não será considerada no cálculo de saldos e insights';
			case 'transaction.types.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Tipo de transação',
				other: 'Tipos de transações',
			);
			case 'transaction.types.income': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Entradas',
				other: 'Entradas',
			);
			case 'transaction.types.expense': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Saídas',
				other: 'Saídas',
			);
			case 'transaction.types.outflow': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Gasto',
				other: 'Gastos',
			);
			case 'transaction.types.transfer': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Transferência',
				other: 'Transferências',
			);
			case 'transfer.display': return 'Transferência';
			case 'transfer.transfers': return 'Transferências';
			case 'transfer.transfer_to': return ({required Object account}) => 'Transferir para ${account}';
			case 'transfer.create': return 'Nova Transferência';
			case 'transfer.need_two_accounts_warning_header': return 'Ops!';
			case 'transfer.need_two_accounts_warning_message': return 'São necessárias pelo menos duas contas para realizar esta ação. Se precisar ajustar ou editar o saldo atual desta conta, clique no botão de edição';
			case 'transfer.form.from': return 'Conta de origem';
			case 'transfer.form.to': return 'Conta de destino';
			case 'transfer.form.value_in_destiny.title': return 'Valor transferido no destino';
			case 'transfer.form.value_in_destiny.amount_short': return ({required Object amount}) => '${amount} para conta de destino';
			case 'recurrent_transactions.title': return 'Transações recorrentes';
			case 'recurrent_transactions.title_short': return 'Trans. recorrentes';
			case 'recurrent_transactions.empty': return 'Parece que você não tem nenhuma transação recorrente. Crie uma transação recorrente mensal, anual ou semanal e ela aparecerá aqui';
			case 'recurrent_transactions.total_expense_title': return 'Despesa total por período';
			case 'recurrent_transactions.total_expense_descr': return '* Sem considerar a data de início e término de cada recorrência';
			case 'recurrent_transactions.details.title': return 'Transação recorrente';
			case 'recurrent_transactions.details.descr': return 'As próximas transações para esta operação estão listadas abaixo. Você pode aceitar a primeira transação ou optar por ignorá-la';
			case 'recurrent_transactions.details.last_payment_info': return 'Esta transação é a última da regra recorrente, portanto, a regra será automaticamente excluída ao confirmar esta ação';
			case 'recurrent_transactions.details.delete_header': return 'Excluir transação recorrente';
			case 'recurrent_transactions.details.delete_message': return 'Esta ação é irreversível e não afetará as transações que você já confirmou/pagou';
			case 'account.details': return 'Detalhes da conta';
			case 'account.date': return 'Data de abertura';
			case 'account.date_sync': return 'Conta sincronizada desde';
			case 'account.close_date': return 'Data de fechamento';
			case 'account.disconnection_date': return 'Data de desconexão';
			case 'account.reopen': return 'Reabrir conta';
			case 'account.reopen_short': return 'Reabrir';
			case 'account.reopen_descr': return 'Tem certeza de que deseja reabrir esta conta?';
			case 'account.balance': return 'Saldo da conta';
			case 'account.n_transactions': return 'Número de transações';
			case 'account.add_money': return 'Adicionar dinheiro';
			case 'account.withdraw_money': return 'Retirar dinheiro';
			case 'account.last_update': return 'Última atualização';
			case 'account.no_accounts': return 'Nenhuma transação encontrada para exibir aqui. Adicione uma transação clicando no botão \'+\' na parte inferior';
			case 'account.types.title': return 'Tipo de conta';
			case 'account.types.warning': return 'Uma vez escolhido o tipo de conta, ele não poderá ser alterado no futuro';
			case 'account.types.normal': return 'Conta corrente';
			case 'account.types.normal_descr': return 'Útil para registrar suas finanças do dia a dia. É a conta mais comum, permite adicionar despesas, receitas...';
			case 'account.types.saving': return 'Investimentos';
			case 'account.types.saving_descr': return 'Você só poderá adicionar e retirar dinheiro dela a partir de outras contas. Perfeito para começar a economizar';
			case 'account.types.credit': return 'Cartão de crédito';
			case 'account.types.credit_descr': return 'Conta que simula uma conta corrente, porém com um saldo negativo. Útil para simular compras parceladas, empréstimos, financiamentos, etc';
			case 'account.types.wallet': return 'Carteira';
			case 'account.types.wallet_descr': return 'Para controlar dinheiro físico (eca!). Usuários Premium terão saques automaticamente creditados nesta conta.';
			case 'account.form.name': return 'Nome da conta';
			case 'account.form.name_placeholder': return 'Ex: Conta poupança';
			case 'account.form.notes': return 'Notas';
			case 'account.form.notes_placeholder': return 'Digite algumas notas/descrição sobre esta conta';
			case 'account.form.initial_balance': return 'Saldo inicial';
			case 'account.form.current_balance': return 'Saldo atual';
			case 'account.form.create': return 'Criar conta';
			case 'account.form.edit': return 'Editar conta';
			case 'account.form.currency_not_found_warn': return 'Você não tem informações sobre taxas de câmbio para esta moeda. 1.0 será usado como a taxa de câmbio padrão. Você pode modificar isso nas configurações';
			case 'account.form.already_exists': return 'Já existe outra com o mesmo nome, por favor escreva outro';
			case 'account.form.tr_before_opening_date': return 'Existem transações nesta conta com uma data anterior à data de abertura';
			case 'account.form.iban': return 'Número de Conta';
			case 'account.form.swift': return 'Agencia';
			case 'account.disconnect.title': return 'Desconectar Banco';
			case 'account.disconnect.warning_header': return 'Desconectar conta?';
			case 'account.disconnect.warning_text': return 'Esta ação cancelerá seu consentimento com o seu banco e não poderemos mais sincronizar suas transações. Esta ação afetará também outros produtos do mesmo banco. Suas transações ainda permanecerão guardadas no Parsa.';
			case 'account.disconnect.success': return 'Conta desconectada com sucesso';
			case 'account.remove.title': return 'Remover Conta';
			case 'account.remove.warning_header': return 'Deletar?';
			case 'account.remove.warning_text': return 'Está ação irá remover esta conta da interface do Parsa, mas seu banco e outras contas continuarão sendo sincronizadas. Esta ação é totalmente reversível. Você deseja continuar?';
			case 'account.remove.success': return 'Conta removida com sucesso';
			case 'account.restore.title': return 'Restaurar Conta';
			case 'account.restore.warning_header': return 'Restaurar?';
			case 'account.restore.warning_text': return 'Está ação irá trazer de volta para sincronização automática continua esta conta que você parou de sincronizar. Você gostaria de prosseguir com esta ação?';
			case 'account.restore.success': return 'Conta restaurada com sucesso.';
			case 'account.restore.in_progress': return 'Restauração da Conta em Andamento. Você pode continuar usando o app.';
			case 'account.delete_openfinance.title': return 'Remover Banco';
			case 'account.delete_openfinance.warning_header': return 'Deletar?';
			case 'account.delete_openfinance.warning_text': return 'Está ação irá remover seu consentimento com o seu banco, interromperá a sincronização de todas as contas e transações neste banco e excluirá todas as suas transações desta conta no Parsa. Deseja prosseguir?';
			case 'account.delete_openfinance.success': return 'Conta deletada com sucesso';
			case 'account.delete.warning_header': return 'Excluir conta?';
			case 'account.delete.warning_text': return 'Essa ação excluirá essa conta e todas as suas transações';
			case 'account.delete.success': return 'Conta excluída com sucesso';
			case 'account.close.title': return 'Fechar conta';
			case 'account.close.title_short': return 'Fechar';
			case 'account.close.warn': return 'Esta conta não aparecerá mais em determinados listagens e você não poderá criar transações nela com uma data posterior à especificada abaixo. Esta ação não afeta nenhuma transação ou saldo, e você também pode reabrir esta conta a qualquer momento.';
			case 'account.close.should_have_zero_balance': return 'Você deve ter um saldo atual de 0 nesta conta para fechá-la. Por favor, edite a conta antes de continuar';
			case 'account.close.should_have_no_transactions': return 'Esta conta possui transações após a data de fechamento especificada. Exclua-as ou edite a data de fechamento da conta antes de continuar';
			case 'account.close.success': return 'Conta fechada com sucesso';
			case 'account.close.unarchive_succes': return 'Conta reaberta com sucesso';
			case 'account.select.one': return 'Selecione uma conta';
			case 'account.select.all': return 'Todas as contas';
			case 'account.select.multiple': return 'Selecionar contas';
			case 'account.connection_errors.not_subscribed': return 'Você ainda não é assinante do plano Premium. Por favor, assine o plano Premium para conectar suas contas com o Open Finance.';
			case 'account.connection_errors.limit_reached': return 'Você atingiu o limite de 3 contas conectadas. Tente desconectar uma conta para adicionar outra.';
			case 'account.connection_errors.daily_limit_reached': return 'O sistema atingiu o limite de conexões diárias. Por favor, tente novamente amanhã.';
			case 'account.connection_errors.item_connection_in_progress': return 'Uma conta está em processo de conexão. Por favor, aguarde um momento e tente novamente.';
			case 'account.connection_errors.default_message': return 'Não foi possível conectar no momento. Tente novamente mais tarde.';
			case 'currencies.currency_converter': return 'Conversor de moedas';
			case 'currencies.currency': return 'Moeda';
			case 'currencies.currency_manager': return 'Gerenciador de moedas';
			case 'currencies.currency_manager_descr': return 'Configure sua moeda e suas taxas de câmbio com outras';
			case 'currencies.preferred_currency': return 'Moeda preferida/base';
			case 'currencies.change_preferred_currency_title': return 'Alterar moeda preferida';
			case 'currencies.change_preferred_currency_msg': return 'Todas as insights e orçamentos serão exibidos nesta moeda a partir de agora. Contas e transações manterão a moeda que possuíam. Todas as taxas de câmbio salvas serão excluídas se você executar esta ação. Deseja continuar?';
			case 'currencies.form.equal_to_preferred_warn': return 'A moeda não pode ser igual à moeda do usuário';
			case 'currencies.form.specify_a_currency': return 'Por favor, especifique uma moeda';
			case 'currencies.form.add': return 'Adicionar taxa de câmbio';
			case 'currencies.form.add_success': return 'Taxa de câmbio adicionada com sucesso';
			case 'currencies.form.edit': return 'Editar taxa de câmbio';
			case 'currencies.form.edit_success': return 'Taxa de câmbio editada com sucesso';
			case 'currencies.delete_all_success': return 'Taxas de câmbio excluídas com sucesso';
			case 'currencies.historical': return 'Taxas históricas';
			case 'currencies.exchange_rate': return 'Taxa de câmbio';
			case 'currencies.exchange_rates': return 'Taxas de câmbio';
			case 'currencies.empty': return 'Adicione taxas de câmbio aqui para que se você tiver contas em moedas diferentes da sua moeda base, nossos gráficos sejam mais precisos';
			case 'currencies.select_a_currency': return 'Selecione uma moeda';
			case 'currencies.search': return 'Pesquise por nome ou código da moeda';
			case 'tags.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Tag',
				other: 'Tags',
			);
			case 'tags.form.name': return 'Nome da tag';
			case 'tags.form.description': return 'Descrição';
			case 'tags.empty_list': return 'Você ainda não criou nenhuma tag. Tags e categorias são uma ótima maneira de categorizar suas transações';
			case 'tags.without_tags': return 'Sem tags';
			case 'tags.select': return 'Selecionar tags';
			case 'tags.add': return 'Adicionar tag';
			case 'tags.create': return 'Criar tag';
			case 'tags.create_success': return 'Tag criada com sucesso';
			case 'tags.already_exists': return 'Este nome de tag já existe. Talvez você queira editá-lo';
			case 'tags.edit': return 'Editar tag';
			case 'tags.edit_success': return 'Tag editada com sucesso';
			case 'tags.delete_success': return 'Tag excluída com sucesso';
			case 'tags.delete_warning_header': return 'Excluir tag?';
			case 'tags.delete_warning_message': return 'Essa ação não excluirá as transações que possuem essa tag.';
			case 'tags.no_tags': return 'Transação sem tags. Clique aqui para adicionar uma tag.';
			case 'categories.unknown': return 'Categoria desconhecida';
			case 'categories.create': return 'Criar categoria';
			case 'categories.create_success': return 'Categoria criada com sucesso.';
			case 'categories.new_category': return 'Nova categoria';
			case 'categories.already_exists': return 'O nome desta categoria já existe. Talvez você queira editá-la';
			case 'categories.edit': return 'Editar categoria';
			case 'categories.edit_success': return 'Categoria editada com sucesso.';
			case 'categories.name': return 'Nome da categoria';
			case 'categories.type': return 'Tipo de categoria';
			case 'categories.both_types': return 'Ambos os tipos';
			case 'categories.subcategories': return 'Subcategorias';
			case 'categories.subcategories_add': return 'Adicionar subcategoria';
			case 'categories.make_parent': return 'Tornar categoria';
			case 'categories.make_child': return 'Tornar subcategoria';
			case 'categories.make_child_warning1': return ({required Object destiny}) => 'Esta categoria e suas subcategorias se tornarão subcategorias de <b>${destiny}</b>.';
			case 'categories.make_child_warning2': return ({required Object x, required Object destiny}) => 'Suas transações <b>(${x})</b> serão movidas para as novas subcategorias criadas dentro da categoria <b>${destiny}</b>.';
			case 'categories.make_child_success': return 'Subcategorias criadas com sucesso';
			case 'categories.merge': return 'Mesclar com outra categoria';
			case 'categories.merge_warning1': return ({required Object x, required Object from, required Object destiny}) => 'Todas as transações (${x}) associadas à categoria <b>${from}</b> serão movidas para a categoria <b>${destiny}</b>';
			case 'categories.merge_warning2': return ({required Object from}) => 'A categoria <b>${from}</b> será excluída de forma irreversível.';
			case 'categories.merge_success': return 'Categoria mesclada com sucesso';
			case 'categories.delete_success': return 'Categoria excluída com sucesso.';
			case 'categories.delete_warning_header': return 'Excluir categoria?';
			case 'categories.delete_warning_message': return ({required Object x}) => 'Essa ação excluirá de forma irreversível todas as transações <b>(${x})</b> relacionadas a esta categoria.';
			case 'categories.select.title': return 'Selecione categorias';
			case 'categories.select.select_one': return 'Selecione uma categoria';
			case 'categories.select.select_subcategory': return 'Escolha uma subcategoria';
			case 'categories.select.without_subcategory': return 'Sem subcategoria';
			case 'categories.select.all': return 'Todas as categorias';
			case 'categories.select.all_short': return 'Todas';
			case 'budgets.title': return 'Orçamentos';
			case 'budgets.repeated': return 'Recorrente';
			case 'budgets.one_time': return 'Único';
			case 'budgets.annual': return 'Anuais';
			case 'budgets.week': return 'Semanal';
			case 'budgets.month': return 'Mensal';
			case 'budgets.actives': return 'Ativos';
			case 'budgets.pending': return 'Aguardando início';
			case 'budgets.finish': return 'Finalizado';
			case 'budgets.from_budgeted': return 'restante de ';
			case 'budgets.days_left': return 'dias restantes';
			case 'budgets.days_to_start': return 'dias para começar';
			case 'budgets.since_expiration': return 'dias desde a expiração';
			case 'budgets.no_budgets': return 'Parece não haver orçamentos nesse período para exibir nesta seção. Comece criando um orçamento clicando aqui.';
			case 'budgets.delete': return 'Excluir orçamento';
			case 'budgets.delete_warning': return 'Essa ação é irreversível. Categorias e transações referentes a esta cota não serão excluídas';
			case 'budgets.form.title': return 'Adicionar um orçamento';
			case 'budgets.form.name': return 'Nome do orçamento';
			case 'budgets.form.value': return 'Quantidade limite';
			case 'budgets.form.create': return 'Adicionar orçamento';
			case 'budgets.form.edit': return 'Editar orçamento';
			case 'budgets.form.negative_warn': return 'Os orçamentos não podem ter um valor negativo';
			case 'budgets.form.null_warn': return 'O valor inserido é inválido.';
			case 'budgets.details.title': return 'Detalhes do orçamento';
			case 'budgets.details.statistics': return 'Insights';
			case 'budgets.details.budget_value': return 'Orçado';
			case 'budgets.details.expend_diary_left': return ({required Object dailyAmount, required Object remainingDays}) => 'Você pode gastar ${dailyAmount}/dia pelos ${remainingDays} dias restantes';
			case 'budgets.details.expend_evolution': return 'Evolução dos gastos';
			case 'budgets.details.no_transactions': return 'Parece que você não fez nenhuma despesa relacionada a este orçamento';
			case 'backup.export.title': return 'Exportar seus dados';
			case 'backup.export.title_short': return 'Exportar';
			case 'backup.export.all': return 'Backup completo';
			case 'backup.export.all_descr': return 'Exporte todos os seus dados (contas, transações, orçamentos, configurações...). Importe-os novamente a qualquer momento para não perder nada.';
			case 'backup.export.transactions': return 'Backup de transações';
			case 'backup.export.transactions_descr': return 'Exporte suas transações em CSV para que você possa analisá-las mais facilmente em outros programas ou aplicativos.';
			case 'backup.export.description': return 'Baixe os dados da suas transações em formato CSV. Recomendamos o uso do Google Sheets para abrir o arquivo por primeira vez - de lá você poderá exportar o arquivo para o Excel.';
			case 'backup.export.dialog_title': return 'Salvar/Enviar arquivo';
			case 'backup.export.success': return ({required Object x}) => 'Arquivo salvo/baixado com sucesso em ${x}';
			case 'backup.export.error': return 'Erro ao baixar o arquivo. Entre em contato com o desenvolvedor via lozin.technologies@gmail.com';
			case 'backup.import.title': return 'Importar seus dados';
			case 'backup.import.title_short': return 'Importar';
			case 'backup.import.restore_backup': return 'Restaurar backup';
			case 'backup.import.restore_backup_descr': return 'Importe um banco de dados salvo anteriormente do Parsa. Esta ação substituirá todos os dados atuais do aplicativo pelos novos dados';
			case 'backup.import.restore_backup_warn_description': return 'Ao importar um novo banco de dados, você perderá todos os dados atualmente salvos no aplicativo. Recomenda-se fazer um backup antes de continuar. Não carregue aqui nenhum arquivo cuja origem você não conheça, carregue apenas arquivos que você tenha baixado anteriormente do Parsa';
			case 'backup.import.restore_backup_warn_title': return 'Sobrescrever todos os dados';
			case 'backup.import.select_other_file': return 'Selecionar outro arquivo';
			case 'backup.import.tap_to_select_file': return 'Toque para selecionar um arquivo';
			case 'backup.import.manual_import.title': return 'Importar histórico manualmente';
			case 'backup.import.manual_import.descr': return 'Importe transações de um arquivo .csv manualmente. Se você estiver usando sincronização do Open Finance, por favor não inclua transações do período de sincronização para evitar duplicidade.';
			case 'backup.import.manual_import.default_account': return 'Conta padrão';
			case 'backup.import.manual_import.remove_default_account': return 'Remover conta padrão';
			case 'backup.import.manual_import.default_category': return 'Categoria padrão';
			case 'backup.import.manual_import.select_a_column': return 'Selecione uma coluna do .csv';
			case 'backup.import.manual_import.steps.0': return 'Selecione seu arquivo';
			case 'backup.import.manual_import.steps.1': return 'Coluna para quantidade';
			case 'backup.import.manual_import.steps.2': return 'Coluna para conta';
			case 'backup.import.manual_import.steps.3': return 'Coluna para categoria';
			case 'backup.import.manual_import.steps.4': return 'Coluna para data';
			case 'backup.import.manual_import.steps.5': return 'outras colunas';
			case 'backup.import.manual_import.steps_descr.0': return 'Selecione um arquivo .csv do seu dispositivo. Certifique-se de que ele tenha uma primeira linha que descreva o nome de cada coluna';
			case 'backup.import.manual_import.steps_descr.1': return 'Selecione a coluna onde o valor de cada transação é especificado. Use valores negativos para despesas e valores positivos para receitas. Use ponto como separador decimal';
			case 'backup.import.manual_import.steps_descr.2': return 'Selecione a coluna onde a conta à qual cada transação pertence é especificada. Você também pode selecionar uma conta padrão caso não consigamos encontrar a conta que deseja. Se uma conta padrão não for especificada, criaremos uma com o mesmo nome';
			case 'backup.import.manual_import.steps_descr.3': return 'Especifique a coluna onde o nome da categoria da transação está localizado. Você deve especificar uma categoria padrão para que possamos atribuir essa categoria às transações, caso a categoria não possa ser encontrada';
			case 'backup.import.manual_import.steps_descr.4': return 'Selecione a coluna onde a data de cada transação é especificada. Se não for especificado, as transações serão criadas na data atual';
			case 'backup.import.manual_import.steps_descr.5': return 'Especifique as colunas para outros atributos opcionais da transação';
			case 'backup.import.manual_import.success': return ({required Object x}) => 'Importado com sucesso ${x} transações';
			case 'backup.import.success': return 'Importação realizada com sucesso';
			case 'backup.import.cancelled': return 'A importação foi cancelada pelo usuário';
			case 'backup.import.error': return 'Erro ao importar arquivo. Entre em contato com o desenvolvedor via lozin.technologies@gmail.com';
			case 'backup.about.title': return 'Informações sobre seu banco de dados';
			case 'backup.about.create_date': return 'Data de criação';
			case 'backup.about.modify_date': return 'Última modificação';
			case 'backup.about.last_backup': return 'Último backup';
			case 'backup.about.size': return 'Tamanho';
			case 'settings.logout': return 'Sair / Logout';
			case 'settings.title_long': return 'Preferências';
			case 'settings.title_short': return 'Preferências';
			case 'settings.description': return 'Configure o Parsa do seu jeito.';
			case 'settings.edit_profile': return 'Editar perfil';
			case 'settings.dashboard.title': return 'Personalizar Dashboard';
			case 'settings.lang_section': return 'Idioma e textos';
			case 'settings.lang_title': return 'Idioma do aplicativo';
			case 'settings.lang_descr': return 'Idioma em que os textos serão exibidos no aplicativo';
			case 'settings.locale': return 'Região';
			case 'settings.locale_descr': return 'Defina o formato a ser usado para datas, números...';
			case 'settings.locale_warn': return 'Ao mudar de região, o aplicativo será atualizado';
			case 'settings.first_day_of_week': return 'Primeiro dia da semana';
			case 'settings.theme_and_colors': return 'Tema e cores';
			case 'settings.theme': return 'Tema';
			case 'settings.theme_auto': return 'Definido pelo sistema';
			case 'settings.theme_light': return 'Claro';
			case 'settings.theme_dark': return 'Escuro';
			case 'settings.amoled_mode': return 'Modo AMOLED';
			case 'settings.amoled_mode_descr': return 'Use um papel de parede preto puro sempre que possível. Isso ajudará um pouco na bateria de dispositivos com telas AMOLED';
			case 'settings.dynamic_colors': return 'Cores dinâmicas';
			case 'settings.dynamic_colors_descr': return 'Use a cor de destaque do sistema sempre que possível';
			case 'settings.accent_color': return 'Cor de destaque';
			case 'settings.accent_color_descr': return 'Escolha a cor que o aplicativo usará para destacar certas partes da interface';
			case 'settings.security.title': return 'Privacidade';
			case 'settings.security.private_mode_at_launch': return 'Modo privado ao iniciar';
			case 'settings.security.private_mode_at_launch_descr': return 'Inicie o aplicativo no modo privado por padrão';
			case 'settings.security.private_mode': return 'Modo privado';
			case 'settings.security.private_mode_descr': return 'Oculte todos os valores monetários';
			case 'settings.security.private_mode_activated': return 'Modo privado ativado';
			case 'settings.security.private_mode_deactivated': return 'Modo privado desativado';
			case 'more.title': return 'Menu';
			case 'more.title_long': return 'Menu e Preferências';
			case 'more.data.display': return 'Dados';
			case 'more.data.display_descr': return 'Exporte os dados da suas transações.';
			case 'more.data.delete_all': return 'Excluir meus dados';
			case 'more.data.delete_all_header1': return 'Pare aí, padawan ⚠️⚠️';
			case 'more.data.delete_all_message1': return 'Tem certeza de que deseja continuar? Todos os seus dados serão excluídos permanentemente e não poderão ser recuperados';
			case 'more.data.delete_all_header2': return 'Último passo ⚠️⚠️';
			case 'more.data.delete_all_message2': return 'Ao excluir uma conta, você excluirá todos os seus dados pessoais armazenados. Suas contas, transações, orçamentos e categorias serão excluídos e não poderão ser recuperados. Você concorda?';
			case 'more.subscribe.display': return 'Assinatura';
			case 'more.subscribe.description': return 'Assine o Parsa para desbloquear todos os recursos Premium.';
			case 'more.subscribe.title': return 'Assinatura Premium';
			case 'more.subscribe.subscribe': return 'Assinar';
			case 'more.subscribe.subscribe_for': return ({required Object price}) => 'Assinar por ${price}';
			case 'more.subscribe.confirm_subscription': return 'Confirmar assinatura';
			case 'more.subscribe.confirm_message': return ({required Object price}) => 'Você está prestes a assinar o Parsa Premium por ${price}. Deseja continuar?';
			case 'more.subscribe.no_plans_available': return 'Nenhum plano disponível no momento';
			case 'more.subscribe.success': return 'Assinatura realizada com sucesso!';
			case 'more.subscribe.error': return 'Erro ao processar a assinatura. Por favor, tente novamente.';
			case 'more.subscribe.cancel': return 'Cancelar';
			case 'more.about_us.display': return 'Informações';
			case 'more.about_us.description': return 'Informações sobre o Parsa, entre em contato conosco, envie sugestões, etc. ';
			case 'more.about_us.legal.display': return 'Informações legais';
			case 'more.about_us.legal.privacy': return 'Política de Privacidade e LGPD';
			case 'more.about_us.legal.terms': return 'Termos de Uso e Serviço';
			case 'more.about_us.legal.licenses': return 'Licenças';
			case 'more.about_us.project.about_us': return 'Sobre o Parsa';
			case 'more.about_us.project.display': return 'Sobre';
			case 'more.about_us.project.contributors': return 'Colaboradores';
			case 'more.about_us.project.contributors_descr': return 'Todos os desenvolvedores que ajudaram o Parsa a crescer';
			case 'more.about_us.project.contact': return 'Entre em contato';
			case 'more.help_us.display': return 'Ajude-nos';
			case 'more.help_us.description': return 'Descubra como você pode ajudar o Parsa a ficar cada vez melhor';
			case 'more.help_us.rate_us': return 'Nos avalie';
			case 'more.help_us.rate_us_descr': return 'Qualquer avaliação é bem-vinda!';
			case 'more.help_us.share': return 'Compartilhar o Parsa';
			case 'more.help_us.share_descr': return 'Compartilhe nosso aplicativo com amigos e familiares';
			case 'more.help_us.share_text': return 'Parsa! O melhor aplicativo de finanças pessoais. Baixe aqui';
			case 'more.help_us.thanks': return 'Obrigado!';
			case 'more.help_us.thanks_long': return 'Suas contribuições para o Parsa e outros projetos de código aberto, grandes e pequenos, tornam possíveis grandes projetos como este. Obrigado por dedicar seu tempo para contribuir.';
			case 'more.help_us.donate': return 'Faça uma doação';
			case 'more.help_us.donate_descr': return 'Com sua doação, você ajudará o aplicativo a continuar recebendo melhorias. Que melhor maneira de agradecer pelo trabalho feito do que me convidar para um café?';
			case 'more.help_us.donate_success': return 'Doação realizada. Muito obrigado pela sua contribuição! ❤️';
			case 'more.help_us.donate_err': return 'Oops! Parece que houve um erro ao receber seu pagamento';
			case 'more.help_us.report': return 'Entre em contato.';
			case 'auth.login_button': return 'Fazer Login no Parsa';
			case 'auth.login_reason': return 'Por favor, confirme sua biometria para continuar. ';
			case 'auth.login_error': return 'Erro ao fazer login. Por favor, verifique suas credenciais e conexão de rede.';
			case 'auth.biometric_failed': return 'Autenticação biométrica falhou. Por favor, faça o login novamente.';
			case 'auth.app_name': return 'Parsa';
			default: return null;
		}
	}
}
