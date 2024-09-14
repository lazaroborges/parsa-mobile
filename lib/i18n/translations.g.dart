/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 3
/// Strings: 1621 (540 per locale)
///
/// Built on 2024-09-14 at 00:14 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	es(languageCode: 'es', build: _TranslationsEs.build),
	pt(languageCode: 'pt', build: _TranslationsPt.build);

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
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _TranslationsGeneralEn general = _TranslationsGeneralEn._(_root);
	late final _TranslationsIntroEn intro = _TranslationsIntroEn._(_root);
	late final _TranslationsHomeEn home = _TranslationsHomeEn._(_root);
	late final _TranslationsFinancialHealthEn financial_health = _TranslationsFinancialHealthEn._(_root);
	late final _TranslationsStatsEn stats = _TranslationsStatsEn._(_root);
	late final _TranslationsIconSelectorEn icon_selector = _TranslationsIconSelectorEn._(_root);
	late final _TranslationsTransactionEn transaction = _TranslationsTransactionEn._(_root);
	late final _TranslationsTransferEn transfer = _TranslationsTransferEn._(_root);
	late final _TranslationsRecurrentTransactionsEn recurrent_transactions = _TranslationsRecurrentTransactionsEn._(_root);
	late final _TranslationsAccountEn account = _TranslationsAccountEn._(_root);
	late final _TranslationsCurrenciesEn currencies = _TranslationsCurrenciesEn._(_root);
	late final _TranslationsTagsEn tags = _TranslationsTagsEn._(_root);
	late final _TranslationsCategoriesEn categories = _TranslationsCategoriesEn._(_root);
	late final _TranslationsBudgetsEn budgets = _TranslationsBudgetsEn._(_root);
	late final _TranslationsBackupEn backup = _TranslationsBackupEn._(_root);
	late final _TranslationsSettingsEn settings = _TranslationsSettingsEn._(_root);
	late final _TranslationsMoreEn more = _TranslationsMoreEn._(_root);
}

// Path: general
class _TranslationsGeneralEn {
	_TranslationsGeneralEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get cancel => 'Cancel';
	String get or => 'or';
	String get understood => 'Understood';
	String get unspecified => 'Unspecified';
	String get confirm => 'Confirm';
	String get continue_text => 'Continue';
	String get quick_actions => 'Quick actions';
	String get save => 'Save';
	String get save_changes => 'Save changes';
	String get close_and_save => 'Save and close';
	String get add => 'Add';
	String get edit => 'Edit';
	String get balance => 'Balance';
	String get delete => 'Delete';
	String get account => 'Account';
	String get accounts => 'Accounts';
	String get categories => 'Categories';
	String get category => 'Category';
	String get today => 'Today';
	String get yesterday => 'Yesterday';
	String get filters => 'Filters';
	String get select_all => 'Select all';
	String get deselect_all => 'Deselect all';
	String get empty_warn => 'Ops! This is very empty';
	String get insufficient_data => 'Insufficient data';
	String get show_more_fields => 'Show more fields';
	String get show_less_fields => 'Show less fields';
	String get tap_to_search => 'Tap to search';
	late final _TranslationsGeneralClipboardEn clipboard = _TranslationsGeneralClipboardEn._(_root);
	late final _TranslationsGeneralTimeEn time = _TranslationsGeneralTimeEn._(_root);
	late final _TranslationsGeneralTransactionOrderEn transaction_order = _TranslationsGeneralTransactionOrderEn._(_root);
	late final _TranslationsGeneralValidationsEn validations = _TranslationsGeneralValidationsEn._(_root);
}

// Path: intro
class _TranslationsIntroEn {
	_TranslationsIntroEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get start => 'Start';
	String get skip => 'Skip';
	String get next => 'Next';
	String get select_your_currency => 'Select your currency';
	String get welcome_subtitle => 'Your personal finance manager';
	String get welcome_subtitle2 => '100% open, 100% free';
	String get welcome_footer => 'By logging in you agree to the <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/PRIVACY_POLICY.md\'>Privacy Policy</a> and the <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/TERMS_OF_USE.md\'>Terms of Use</a> of the application';
	String get offline_descr_title => 'OFFLINE ACCOUNT:';
	String get offline_descr => 'Your data will only be stored on your device, and will be safe as long as you don\'t uninstall the app or change phone. To prevent data loss, it is recommended to make a backup regularly from the app settings.';
	String get offline_start => 'Start session offline';
	String get sl1_title => 'Select your currency';
	String get sl1_descr => 'Your default currency will be used in reports and general charts. You will be able to change the currency and the app language later at any time in the application settings';
	String get sl2_title => 'Safe, private and reliable';
	String get sl2_descr => 'Your data is only yours. We store the information directly on your device, without going through external servers. This makes it possible to use the app even without internet';
	String get sl2_descr2 => 'Also, the source code of the application is public, anyone can collaborate on it and see how it works';
	String get last_slide_title => 'All ready';
	String get last_slide_descr => 'With Parsa, you can finally achieve the financial independence you want so much. You will have graphs, budgets, tips, statistics and much more about your money.';
	String get last_slide_descr2 => 'We hope you enjoy your experience! Do not hesitate to contact us in case of doubts, suggestions...';
}

// Path: home
class _TranslationsHomeEn {
	_TranslationsHomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Dashboard';
	String get filter_transactions => 'Filter transactions';
	String get hello_day => 'Good morning,';
	String get hello_night => 'Good night,';
	String get total_balance => 'Total balance';
	String get my_accounts => 'My accounts';
	String get active_accounts => 'Active accounts';
	String get no_accounts => 'No accounts created yet';
	String get no_accounts_descr => 'Start using all the magic of Parsa. Create at least one account to start adding transactions';
	String get last_transactions => 'Last transactions';
	String get should_create_account_header => 'Oops!';
	String get should_create_account_message => 'You must have at least one no-archived account before you can start creating transactions';
}

// Path: financial_health
class _TranslationsFinancialHealthEn {
	_TranslationsFinancialHealthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Financial health';
	late final _TranslationsFinancialHealthReviewEn review = _TranslationsFinancialHealthReviewEn._(_root);
	late final _TranslationsFinancialHealthMonthsWithoutIncomeEn months_without_income = _TranslationsFinancialHealthMonthsWithoutIncomeEn._(_root);
	late final _TranslationsFinancialHealthSavingsPercentageEn savings_percentage = _TranslationsFinancialHealthSavingsPercentageEn._(_root);
}

// Path: stats
class _TranslationsStatsEn {
	_TranslationsStatsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Statistics';
	String get balance => 'Balance';
	String get final_balance => 'Final balance';
	String get balance_by_account => 'Balance by accounts';
	String get balance_by_currency => 'Balance by currency';
	String get cash_flow => 'Cash flow';
	String get balance_evolution => 'Balance evolution';
	String get compared_to_previous_period => 'Compared to the previous period';
	String get by_periods => 'By periods';
	String get by_categories => 'By categories';
	String get by_tags => 'By tags';
	String get distribution => 'Distribution';
	String get finance_health_resume => 'Resume';
	String get finance_health_breakdown => 'Breakdown';
}

// Path: icon_selector
class _TranslationsIconSelectorEn {
	_TranslationsIconSelectorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Name:';
	String get icon => 'Icon';
	String get color => 'Color';
	String get select_icon => 'Select an icon';
	String get select_color => 'Select a color';
	String get select_account_icon => 'Identify your account';
	String get select_category_icon => 'Identify your category';
	late final _TranslationsIconSelectorScopesEn scopes = _TranslationsIconSelectorScopesEn._(_root);
}

// Path: transaction
class _TranslationsTransactionEn {
	_TranslationsTransactionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Transaction',
		other: 'Transactions',
	);
	String get create => 'New transaction';
	String get new_income => 'New income';
	String get new_expense => 'New expense';
	String get new_success => 'Transaction created successfully';
	String get edit => 'Edit transaction';
	String get edit_success => 'Transaction edited successfully';
	String get edit_multiple => 'Edit transactions';
	String edit_multiple_success({required Object x}) => '${x} transactions edited successfully';
	String get duplicate => 'Clone transaction';
	String get duplicate_short => 'Clone';
	String get duplicate_warning_message => 'A transaction identical to this will be created with the same date, do you want to continue?';
	String get duplicate_success => 'Transaction cloned successfully';
	String get delete => 'Delete transaction';
	String get delete_warning_message => 'This action is irreversible. The current balance of your accounts and all your statistics will be recalculated';
	String get delete_success => 'Transaction deleted correctly';
	String get delete_multiple => 'Delete transactions';
	String delete_multiple_warning_message({required Object x}) => 'This action is irreversible and will remove ${x} transactions. The current balance of your accounts and all your statistics will be recalculated';
	String delete_multiple_success({required Object x}) => '${x} transactions deleted correctly';
	String get details => 'Movement details';
	late final _TranslationsTransactionNextPaymentsEn next_payments = _TranslationsTransactionNextPaymentsEn._(_root);
	late final _TranslationsTransactionListEn list = _TranslationsTransactionListEn._(_root);
	late final _TranslationsTransactionFiltersEn filters = _TranslationsTransactionFiltersEn._(_root);
	late final _TranslationsTransactionFormEn form = _TranslationsTransactionFormEn._(_root);
	late final _TranslationsTransactionReversedEn reversed = _TranslationsTransactionReversedEn._(_root);
	late final _TranslationsTransactionStatusEn status = _TranslationsTransactionStatusEn._(_root);
	late final _TranslationsTransactionTypesEn types = _TranslationsTransactionTypesEn._(_root);
}

// Path: transfer
class _TranslationsTransferEn {
	_TranslationsTransferEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Transfer';
	String get transfers => 'Transfers';
	String transfer_to({required Object account}) => 'Transfer to ${account}';
	String get create => 'New Transfer';
	String get need_two_accounts_warning_header => 'Ops!';
	String get need_two_accounts_warning_message => 'At least two accounts are needed to perform this action. If you need to adjust or edit the current balance of this account, click the edit button';
	late final _TranslationsTransferFormEn form = _TranslationsTransferFormEn._(_root);
}

// Path: recurrent_transactions
class _TranslationsRecurrentTransactionsEn {
	_TranslationsRecurrentTransactionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Recurrent transactions';
	String get title_short => 'Rec. transactions';
	String get empty => 'It looks like you don\'t have any recurring transactions. Create a monthly, yearly, or weekly recurring transaction and it will appear here';
	String get total_expense_title => 'Total expense per period';
	String get total_expense_descr => '* Without considering the start and end date of each recurrence';
	late final _TranslationsRecurrentTransactionsDetailsEn details = _TranslationsRecurrentTransactionsDetailsEn._(_root);
}

// Path: account
class _TranslationsAccountEn {
	_TranslationsAccountEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get details => 'Account details';
	String get date => 'Opening date';
	String get close_date => 'Closing date';
	String get reopen => 'Re-open account';
	String get reopen_short => 'Re-open';
	String get reopen_descr => 'Are you sure you want to reopen this account?';
	String get balance => 'Account balance';
	String get n_transactions => 'Number of transactions';
	String get add_money => 'Add money';
	String get withdraw_money => 'Withdraw money';
	String get no_accounts => 'No transactions found to display here. Add a transaction by clicking the \'+\' button at the bottom';
	late final _TranslationsAccountTypesEn types = _TranslationsAccountTypesEn._(_root);
	late final _TranslationsAccountFormEn form = _TranslationsAccountFormEn._(_root);
	late final _TranslationsAccountDeleteEn delete = _TranslationsAccountDeleteEn._(_root);
	late final _TranslationsAccountCloseEn close = _TranslationsAccountCloseEn._(_root);
	late final _TranslationsAccountSelectEn select = _TranslationsAccountSelectEn._(_root);
}

// Path: currencies
class _TranslationsCurrenciesEn {
	_TranslationsCurrenciesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get currency_converter => 'Currency converter';
	String get currency => 'Currency';
	String get currency_manager => 'Currency manager';
	String get currency_manager_descr => 'Configure your currency and its exchange rates with others';
	String get preferred_currency => 'Preferred/base currency';
	String get change_preferred_currency_title => 'Change preferred currency';
	String get change_preferred_currency_msg => 'All stats and budgets will be displayed in this currency from now on. Accounts and transactions will keep the currency they had. All saved exchange rates will be deleted if you execute this action. Do you wish to continue?';
	late final _TranslationsCurrenciesFormEn form = _TranslationsCurrenciesFormEn._(_root);
	String get delete_all_success => 'Deleted exchange rates successfully';
	String get historical => 'Historical rates';
	String get exchange_rate => 'Exchange rate';
	String get exchange_rates => 'Exchange rates';
	String get empty => 'Add exchange rates here so that if you have accounts in currencies other than your base currency our charts are more accurate';
	String get select_a_currency => 'Select a currency';
	String get search => 'Search by name or by currency code';
}

// Path: tags
class _TranslationsTagsEn {
	_TranslationsTagsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Label',
		other: 'Tags',
	);
	late final _TranslationsTagsFormEn form = _TranslationsTagsFormEn._(_root);
	String get empty_list => 'You haven\'t created any tags yet. Tags and categories are a great way to categorize your movements';
	String get without_tags => 'Without tags';
	String get select => 'Select tags';
	String get add => 'Add tag';
	String get create => 'Create label';
	String get create_success => 'Label created successfully';
	String get already_exists => 'This tag name already exists. You may want to edit it';
	String get edit => 'Edit tag';
	String get edit_success => 'Tag edited successfully';
	String get delete_success => 'Category deleted successfully';
	String get delete_warning_header => 'Delete tag?';
	String get delete_warning_message => 'This action will not delete transactions that have this tag.';
}

// Path: categories
class _TranslationsCategoriesEn {
	_TranslationsCategoriesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get unknown => 'Unknown category';
	String get create => 'Create category';
	String get create_success => 'Category created correctly';
	String get new_category => 'New category';
	String get already_exists => 'The name of this category already exists. Maybe you want to edit it';
	String get edit => 'Edit category';
	String get edit_success => 'Category edited correctly';
	String get name => 'Category name';
	String get type => 'Category type';
	String get both_types => 'Both types';
	String get subcategories => 'Subcategories';
	String get subcategories_add => 'Add subcategory';
	String get make_parent => 'Make to category';
	String get make_child => 'Make a subcategory';
	String make_child_warning1({required Object destiny}) => 'This category and its subcategories will become subcategories of <b>${destiny}</b>.';
	String make_child_warning2({required Object x, required Object destiny}) => 'Their transactions <b>(${x})</b> will be moved to the new subcategories created within the <b>${destiny}</b> category.';
	String get make_child_success => 'Subcategories created successfully';
	String get merge => 'Merge with another category';
	String merge_warning1({required Object x, required Object from, required Object destiny}) => 'All transactions (${x}) associated with the category <b>${from}</b> will be moved to the category <b>${destiny}</b>';
	String merge_warning2({required Object from}) => 'The category <b>${from}</b> will be irreversibly deleted.';
	String get merge_success => 'Category merged successfully';
	String get delete_success => 'Category deleted correctly';
	String get delete_warning_header => 'Delete category?';
	String delete_warning_message({required Object x}) => 'This action will irreversibly delete all transactions <b>(${x})</b> related to this category.';
	late final _TranslationsCategoriesSelectEn select = _TranslationsCategoriesSelectEn._(_root);
}

// Path: budgets
class _TranslationsBudgetsEn {
	_TranslationsBudgetsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Budgets';
	String get repeated => 'Recurring';
	String get one_time => 'Once';
	String get annual => 'Annuals';
	String get week => 'Weekly';
	String get month => 'Monthly';
	String get actives => 'Actives';
	String get pending => 'Pending start';
	String get finish => 'Finished';
	String get from_budgeted => 'left of ';
	String get days_left => 'days left';
	String get days_to_start => 'days to start';
	String get since_expiration => 'days since expiration';
	String get no_budgets => 'There seem to be no budgets to display in this section. Start by creating a budget by clicking the button below';
	String get delete => 'Delete budget';
	String get delete_warning => 'This action is irreversible. Categories and transactions referring to this quote will not be deleted';
	late final _TranslationsBudgetsFormEn form = _TranslationsBudgetsFormEn._(_root);
	late final _TranslationsBudgetsDetailsEn details = _TranslationsBudgetsDetailsEn._(_root);
}

// Path: backup
class _TranslationsBackupEn {
	_TranslationsBackupEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsBackupExportEn export = _TranslationsBackupExportEn._(_root);
	late final _TranslationsBackupImportEn import = _TranslationsBackupImportEn._(_root);
	late final _TranslationsBackupAboutEn about = _TranslationsBackupAboutEn._(_root);
}

// Path: settings
class _TranslationsSettingsEn {
	_TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title_long => 'Settings and appearance';
	String get title_short => 'Settings';
	String get description => 'App theme, texts and other general settings';
	String get edit_profile => 'Edit profile';
	String get lang_section => 'Language and texts';
	String get lang_title => 'App language';
	String get lang_descr => 'Language in which the texts will be displayed in the app';
	String get locale => 'Region';
	String get locale_descr => 'Set the format to use for dates, numbers...';
	String get locale_warn => 'When changing region the app will update';
	String get first_day_of_week => 'First day of week';
	String get theme_and_colors => 'Theme and colors';
	String get theme => 'Theme';
	String get theme_auto => 'Defined by the system';
	String get theme_light => 'Light';
	String get theme_dark => 'Dark';
	String get amoled_mode => 'AMOLED mode';
	String get amoled_mode_descr => 'Use a pure black wallpaper when possible. This will slightly help the battery of devices with AMOLED screens';
	String get dynamic_colors => 'Dynamic colors';
	String get dynamic_colors_descr => 'Use your system accent color whenever possible';
	String get accent_color => 'Accent color';
	String get accent_color_descr => 'Choose the color the app will use to emphasize certain parts of the interface';
	late final _TranslationsSettingsSecurityEn security = _TranslationsSettingsSecurityEn._(_root);
}

// Path: more
class _TranslationsMoreEn {
	_TranslationsMoreEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'More';
	String get title_long => 'More actions';
	late final _TranslationsMoreDataEn data = _TranslationsMoreDataEn._(_root);
	late final _TranslationsMoreAboutUsEn about_us = _TranslationsMoreAboutUsEn._(_root);
	late final _TranslationsMoreHelpUsEn help_us = _TranslationsMoreHelpUsEn._(_root);
}

// Path: general.clipboard
class _TranslationsGeneralClipboardEn {
	_TranslationsGeneralClipboardEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String success({required Object x}) => '${x} copied to the clipboard';
	String get error => 'Error copying';
}

// Path: general.time
class _TranslationsGeneralTimeEn {
	_TranslationsGeneralTimeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get start_date => 'Start date';
	String get end_date => 'End date';
	String get from_date => 'From date';
	String get until_date => 'Until date';
	String get date => 'Date';
	String get datetime => 'Datetime';
	String get time => 'Time';
	String get each => 'Each';
	String get after => 'After';
	late final _TranslationsGeneralTimeRangesEn ranges = _TranslationsGeneralTimeRangesEn._(_root);
	late final _TranslationsGeneralTimePeriodicityEn periodicity = _TranslationsGeneralTimePeriodicityEn._(_root);
	late final _TranslationsGeneralTimeCurrentEn current = _TranslationsGeneralTimeCurrentEn._(_root);
	late final _TranslationsGeneralTimeAllEn all = _TranslationsGeneralTimeAllEn._(_root);
}

// Path: general.transaction_order
class _TranslationsGeneralTransactionOrderEn {
	_TranslationsGeneralTransactionOrderEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Order transactions';
	String get category => 'By category';
	String get quantity => 'By quantity';
	String get date => 'By date';
}

// Path: general.validations
class _TranslationsGeneralValidationsEn {
	_TranslationsGeneralValidationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Required field';
	String get positive => 'Should be positive';
	String min_number({required Object x}) => 'Should be greater than ${x}';
	String max_number({required Object x}) => 'Should be less than ${x}';
}

// Path: financial_health.review
class _TranslationsFinancialHealthReviewEn {
	_TranslationsFinancialHealthReviewEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String very_good({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Very good!';
			case GenderContext.female:
				return 'Very good!';
		}
	}
	String good({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Good';
			case GenderContext.female:
				return 'Good';
		}
	}
	String normal({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Average';
			case GenderContext.female:
				return 'Average';
		}
	}
	String bad({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Fair';
			case GenderContext.female:
				return 'Fair';
		}
	}
	String very_bad({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Very Bad';
			case GenderContext.female:
				return 'Very Bad';
		}
	}
	String insufficient_data({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Insufficient data';
			case GenderContext.female:
				return 'Insufficient data';
		}
	}
	late final _TranslationsFinancialHealthReviewDescrEn descr = _TranslationsFinancialHealthReviewDescrEn._(_root);
}

// Path: financial_health.months_without_income
class _TranslationsFinancialHealthMonthsWithoutIncomeEn {
	_TranslationsFinancialHealthMonthsWithoutIncomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Survival rate';
	String get subtitle => 'Given your balance, amount of time you could go without income';
	String get text_zero => 'You couldn\'t survive a month without income at this rate of expenses!';
	String get text_one => 'You could barely survive approximately a month without income at this rate of expenses!';
	String text_other({required Object n}) => 'You could survive approximately <b>${n} months</b> without income at this rate of spending.';
	String get text_infinite => 'You could survive approximately <b>all your life</b> without income at this rate of spending.';
	String get suggestion => 'Remember that it is advisable to always keep this ratio above 5 months at least. If you see that you do not have a sufficient savings cushion, reduce unnecessary expenses.';
	String get insufficient_data => 'It looks like we don\'t have enough expenses to calculate how many months you could survive without income. Enter a few transactions and come back here to check your financial health';
}

// Path: financial_health.savings_percentage
class _TranslationsFinancialHealthSavingsPercentageEn {
	_TranslationsFinancialHealthSavingsPercentageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Savings percentage';
	String get subtitle => 'What part of your income is not spent in this period';
	late final _TranslationsFinancialHealthSavingsPercentageTextEn text = _TranslationsFinancialHealthSavingsPercentageTextEn._(_root);
	String get suggestion => 'Remember that it is advisable to save at least 15-20% of what you earn.';
}

// Path: icon_selector.scopes
class _TranslationsIconSelectorScopesEn {
	_TranslationsIconSelectorScopesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get transport => 'Transport';
	String get money => 'Money';
	String get food => 'Food';
	String get medical => 'Health';
	String get entertainment => 'Leisure';
	String get technology => 'Technology';
	String get other => 'Others';
	String get logos_financial_institutions => 'Financial institutions';
}

// Path: transaction.next_payments
class _TranslationsTransactionNextPaymentsEn {
	_TranslationsTransactionNextPaymentsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get accept => 'Accept';
	String get skip => 'Skip';
	String get skip_success => 'Successfully skipped transaction';
	String get skip_dialog_title => 'Skip transaction';
	String skip_dialog_msg({required Object date}) => 'This action is irreversible. We will move the date of the next move to ${date}';
	String get accept_today => 'Accept today';
	String accept_in_required_date({required Object date}) => 'Accept in required date (${date})';
	String get accept_dialog_title => 'Accept transaction';
	String get accept_dialog_msg_single => 'The new status of the transaction will be null. You can re-edit the status of this transaction whenever you want';
	String accept_dialog_msg({required Object date}) => 'This action will create a new transaction with date ${date}. You will be able to check the details of this transaction on the transaction page';
	String get recurrent_rule_finished => 'The recurring rule has been completed, there are no more payments to make!';
}

// Path: transaction.list
class _TranslationsTransactionListEn {
	_TranslationsTransactionListEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get empty => 'No transactions found to display here. Add a transaction by clicking the \'+\' button at the bottom';
	String get searcher_placeholder => 'Search by category, description...';
	String get searcher_no_results => 'No transactions found matching the search criteria';
	String get loading => 'Loading more transactions...';
	String selected_short({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} selected',
		other: '${n} selected',
	);
	String selected_long({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} transaction selected',
		other: '${n} transactions selected',
	);
	late final _TranslationsTransactionListBulkEditEn bulk_edit = _TranslationsTransactionListBulkEditEn._(_root);
}

// Path: transaction.filters
class _TranslationsTransactionFiltersEn {
	_TranslationsTransactionFiltersEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get from_value => 'From amount';
	String get to_value => 'Up to amount';
	String from_value_def({required Object x}) => 'From ${x}';
	String to_value_def({required Object x}) => 'Up to ${x}';
	String from_date_def({required Object date}) => 'From the ${date}';
	String to_date_def({required Object date}) => 'Up to the ${date}';
}

// Path: transaction.form
class _TranslationsTransactionFormEn {
	_TranslationsTransactionFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsTransactionFormValidatorsEn validators = _TranslationsTransactionFormValidatorsEn._(_root);
	String get title => 'Transaction title';
	String get title_short => 'Title';
	String get value => 'Value of the transaction';
	String get tap_to_see_more => 'Tap to see more details';
	String get no_tags => '-- No tags --';
	String get description => 'Description';
	String get description_info => 'Tap here to enter a more detailed description about this transaction';
	String exchange_to_preferred_title({required Object currency}) => 'Exchnage rate to ${currency}';
	String get exchange_to_preferred_in_date => 'On transaction date';
}

// Path: transaction.reversed
class _TranslationsTransactionReversedEn {
	_TranslationsTransactionReversedEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Inverse transaction';
	String get title_short => 'Inverse tr.';
	String get description_for_expenses => 'Despite being an expense transaction, it has a positive amount. These types of transactions can be used to represent the return of a previously recorded expense, such as a refund or having the payment of a debt.';
	String get description_for_incomes => 'Despite being an income transaction, it has a negative amount. These types of transactions can be used to void or correct an income that was incorrectly recorded, to reflect a return or refund of money or to record payment of debts.';
}

// Path: transaction.status
class _TranslationsTransactionStatusEn {
	_TranslationsTransactionStatusEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Status',
		other: 'Statuses',
	);
	String get display_long => 'Transaction status';
	String tr_status({required Object status}) => '${status} transaction';
	String get none => 'Stateless';
	String get none_descr => 'Transaction without a specific state';
	String get reconciled => 'Reconciled';
	String get reconciled_descr => 'This transaction has already been validated and corresponds to a real transaction from your bank';
	String get unreconciled => 'Unreconciled';
	String get unreconciled_descr => 'This transaction has not yet been validated and therefore does not yet appear in your real bank accounts. However, it counts for the calculation of balances and statistics in Parsa';
	String get pending => 'Pending';
	String get pending_descr => 'This transaction is pending and therefore it will not be taken into account when calculating balances and statistics';
	String get voided => 'Voided';
	String get voided_descr => 'Void/cancelled transaction due to payment error or any other reason. It will not be taken into account when calculating balances and statistics';
}

// Path: transaction.types
class _TranslationsTransactionTypesEn {
	_TranslationsTransactionTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Transaction type',
		other: 'Transaction types',
	);
	String income({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Income',
		other: 'Incomes',
	);
	String expense({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Expense',
		other: 'Expenses',
	);
	String transfer({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Transfer',
		other: 'Transfers',
	);
}

// Path: transfer.form
class _TranslationsTransferFormEn {
	_TranslationsTransferFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get from => 'Origin account';
	String get to => 'Destination account';
	late final _TranslationsTransferFormValueInDestinyEn value_in_destiny = _TranslationsTransferFormValueInDestinyEn._(_root);
}

// Path: recurrent_transactions.details
class _TranslationsRecurrentTransactionsDetailsEn {
	_TranslationsRecurrentTransactionsDetailsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Recurrent transaction';
	String get descr => 'The next moves for this transaction are shown below. You can accept the first move or skip this move';
	String get last_payment_info => 'This movement is the last of the recurring rule, so this rule will be automatically deleted when confirming this action';
	String get delete_header => 'Delete recurring transaction';
	String get delete_message => 'This action is irreversible and will not affect transactions you have already confirmed/paid for';
}

// Path: account.types
class _TranslationsAccountTypesEn {
	_TranslationsAccountTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Account type';
	String get warning => 'Once the type of account has been chosen, it cannot be changed in the future';
	String get normal => 'Checking account';
	String get normal_descr => 'Useful to record your day-to-day finances. It is the most common account, it allows you to add expenses, income...';
	String get saving => 'Savings account';
	String get saving_descr => 'You will only be able to add and withdraw money from it from other accounts. Perfect to start saving money';
}

// Path: account.form
class _TranslationsAccountFormEn {
	_TranslationsAccountFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Account name';
	String get name_placeholder => 'Ex: Savings account';
	String get notes => 'Notes';
	String get notes_placeholder => 'Type some notes/description about this account';
	String get initial_balance => 'Initial balance';
	String get current_balance => 'Current balance';
	String get create => 'Create account';
	String get edit => 'Edit account';
	String get currency_not_found_warn => 'You do not have information on exchange rates for this currency. 1.0 will be used as the default exchange rate. You can modify this in the settings';
	String get already_exists => 'There is already another one with the same name, please write another';
	String get tr_before_opening_date => 'There are transactions in this account with a date before the opening date';
	String get iban => 'IBAN';
	String get swift => 'SWIFT';
}

// Path: account.delete
class _TranslationsAccountDeleteEn {
	_TranslationsAccountDeleteEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get warning_header => 'Delete account?';
	String get warning_text => 'This action will delete this account and all its transactions';
	String get success => 'Account deleted successfully';
}

// Path: account.close
class _TranslationsAccountCloseEn {
	_TranslationsAccountCloseEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Close account';
	String get title_short => 'Close';
	String get warn => 'This account will no longer appear in certain listings and you will not be able to create transactions in it with a date later than the one specified below. This action does not affect any transactions or balance, and you can also reopen this account at any time. ';
	String get should_have_zero_balance => 'You must have a current balance of 0 in this account to close it. Please edit the account before continuing';
	String get should_have_no_transactions => 'This account has transactions after the specified close date. Delete them or edit the account close date before continuing';
	String get success => 'Account closed successfully';
	String get unarchive_succes => 'Account successfully re-opened';
}

// Path: account.select
class _TranslationsAccountSelectEn {
	_TranslationsAccountSelectEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get one => 'Select an account';
	String get all => 'All accounts';
	String get multiple => 'Select accounts';
}

// Path: currencies.form
class _TranslationsCurrenciesFormEn {
	_TranslationsCurrenciesFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get equal_to_preferred_warn => 'The currency cannot be equal to the user currency';
	String get specify_a_currency => 'Please specify a currency';
	String get add => 'Add exchange rate';
	String get add_success => 'Exchange rate added successfully';
	String get edit => 'Edit exchange rate';
	String get edit_success => 'Exchange rate edited successfully';
}

// Path: tags.form
class _TranslationsTagsFormEn {
	_TranslationsTagsFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Tag name';
	String get description => 'Description';
}

// Path: categories.select
class _TranslationsCategoriesSelectEn {
	_TranslationsCategoriesSelectEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Select categories';
	String get select_one => 'Select a category';
	String get select_subcategory => 'Choose a subcategory';
	String get without_subcategory => 'Without subcategory';
	String get all => 'All categories';
	String get all_short => 'All';
}

// Path: budgets.form
class _TranslationsBudgetsFormEn {
	_TranslationsBudgetsFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Add a budget';
	String get name => 'Budget name';
	String get value => 'Limit quantity';
	String get create => 'Add budget';
	String get edit => 'Edit budget';
	String get negative_warn => 'The budgets can not have a negative amount';
}

// Path: budgets.details
class _TranslationsBudgetsDetailsEn {
	_TranslationsBudgetsDetailsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Budget Details';
	String get statistics => 'Statistics';
	String get budget_value => 'Budgeted';
	String expend_diary_left({required Object dailyAmount, required Object remainingDays}) => 'You can spend ${dailyAmount}/day for ${remainingDays} remaining days';
	String get expend_evolution => 'Expenditure evolution';
	String get no_transactions => 'It seems that you have not made any expenses related to this budget';
}

// Path: backup.export
class _TranslationsBackupExportEn {
	_TranslationsBackupExportEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Export your data';
	String get title_short => 'Export';
	String get all => 'Full backup';
	String get all_descr => 'Export all your data (accounts, transactions, budgets, settings...). Import them again at any time so you don\'t lose anything.';
	String get transactions => 'Transactions backup';
	String get transactions_descr => 'Export your transactions in CSV so you can more easily analyze them in other programs or applications.';
	String get description => 'Download your data in different formats';
	String get dialog_title => 'Save/Send file';
	String success({required Object x}) => 'File saved/downloaded successfully in ${x}';
	String get error => 'Error downloading the file. Please contact the developer via lozin.technologies@gmail.com';
}

// Path: backup.import
class _TranslationsBackupImportEn {
	_TranslationsBackupImportEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Import your data';
	String get title_short => 'Import';
	String get restore_backup => 'Restore Backup';
	String get restore_backup_descr => 'Import a previously saved database from Parsa. This action will replace any current application data with the new data';
	String get restore_backup_warn_description => 'When importing a new database, you will lose all data currently saved in the app. It is recommended to make a backup before continuing. Do not upload here any file whose origin you do not know, upload only files that you have previously downloaded from Parsa';
	String get restore_backup_warn_title => 'Overwrite all data';
	String get select_other_file => 'Select other file';
	String get tap_to_select_file => 'Tap to select a file';
	late final _TranslationsBackupImportManualImportEn manual_import = _TranslationsBackupImportManualImportEn._(_root);
	String get success => 'Import performed successfully';
	String get cancelled => 'Import was cancelled by the user';
	String get error => 'Error importing file. Please contact developer via lozin.technologies@gmail.com';
}

// Path: backup.about
class _TranslationsBackupAboutEn {
	_TranslationsBackupAboutEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Information about your database';
	String get create_date => 'Creation date';
	String get modify_date => 'Last modified';
	String get last_backup => 'Last backup';
	String get size => 'Size';
}

// Path: settings.security
class _TranslationsSettingsSecurityEn {
	_TranslationsSettingsSecurityEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Seguridad';
	String get private_mode_at_launch => 'Private mode at launch';
	String get private_mode_at_launch_descr => 'Launch the app in private mode by default';
	String get private_mode => 'Private mode';
	String get private_mode_descr => 'Hide all monetary values';
	String get private_mode_activated => 'Private mode activated';
	String get private_mode_deactivated => 'Private mode disabled';
}

// Path: more.data
class _TranslationsMoreDataEn {
	_TranslationsMoreDataEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Data';
	String get display_descr => 'Export and import your data so you don\'t lose anything';
	String get delete_all => 'Delete my data';
	String get delete_all_header1 => 'Stop right there padawan ⚠️⚠️';
	String get delete_all_message1 => 'Are you sure you want to continue? All your data will be permanently deleted and cannot be recovered';
	String get delete_all_header2 => 'One last step ⚠️⚠️';
	String get delete_all_message2 => 'By deleting an account you will delete all your stored personal data. Your accounts, transactions, budgets and categories will be deleted and cannot be recovered. Do you agree?';
}

// Path: more.about_us
class _TranslationsMoreAboutUsEn {
	_TranslationsMoreAboutUsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'App information';
	String get description => 'Check out the terms and other relevant information about Parsa. Get in touch with the community by reporting bugs, leaving suggestions...';
	late final _TranslationsMoreAboutUsLegalEn legal = _TranslationsMoreAboutUsLegalEn._(_root);
	late final _TranslationsMoreAboutUsProjectEn project = _TranslationsMoreAboutUsProjectEn._(_root);
}

// Path: more.help_us
class _TranslationsMoreHelpUsEn {
	_TranslationsMoreHelpUsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Help us';
	String get description => 'Find out how you can help Parsa become better and better';
	String get rate_us => 'Rate us';
	String get rate_us_descr => 'Any rate is welcome!';
	String get share => 'Share Parsa';
	String get share_descr => 'Share our app to friends and family';
	String get share_text => 'Parsa! The best personal finance app. Download it here';
	String get thanks => 'Thank you!';
	String get thanks_long => 'Your contributions to Parsa and other open source projects, big and small, make great projects like this possible. Thank you for taking the time to contribute.';
	String get donate => 'Make a donation';
	String get donate_descr => 'With your donation you will help the app continue receiving improvements. What better way than to thank the work done by inviting me to a coffee?';
	String get donate_success => 'Donation made. Thank you very much for your contribution! ❤️';
	String get donate_err => 'Oops! It seems there was an error receiving your payment';
	String get report => 'Report bugs, leave suggestions...';
}

// Path: general.time.ranges
class _TranslationsGeneralTimeRangesEn {
	_TranslationsGeneralTimeRangesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Time range';
	String get it_repeat => 'Repeats';
	String get it_ends => 'Ends';
	String get forever => 'Forever';
	late final _TranslationsGeneralTimeRangesTypesEn types = _TranslationsGeneralTimeRangesTypesEn._(_root);
	String each_range({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Every ${range}',
		other: 'Every ${n} ${range}',
	);
	String each_range_until_date({required num n, required Object range, required Object day}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Every ${range} until ${day}',
		other: 'Every ${n} ${range} until ${day}',
	);
	String each_range_until_times({required num n, required Object range, required Object limit}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Every ${range} ${limit} times',
		other: 'Every ${n} ${range} ${limit} times',
	);
	String each_range_until_once({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Every ${range} once',
		other: 'Every ${n} ${range} once',
	);
	String month({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Month',
		other: 'Months',
	);
	String year({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Year',
		other: 'Years',
	);
	String day({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Day',
		other: 'Days',
	);
	String week({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Week',
		other: 'Weeks',
	);
}

// Path: general.time.periodicity
class _TranslationsGeneralTimePeriodicityEn {
	_TranslationsGeneralTimePeriodicityEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Recurrence';
	String get no_repeat => 'No repeat';
	String repeat({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Repetition',
		other: 'Repetitions',
	);
	String get diary => 'Daily';
	String get monthly => 'Monthly';
	String get annually => 'Annually';
	String get quaterly => 'Quarterly';
	String get weekly => 'Weekly';
	String get custom => 'Custom';
	String get infinite => 'Always';
}

// Path: general.time.current
class _TranslationsGeneralTimeCurrentEn {
	_TranslationsGeneralTimeCurrentEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get monthly => 'This month';
	String get annually => 'This year';
	String get quaterly => 'This quarter';
	String get weekly => 'This week';
	String get infinite => 'For ever';
	String get custom => 'Custom Range';
}

// Path: general.time.all
class _TranslationsGeneralTimeAllEn {
	_TranslationsGeneralTimeAllEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get diary => 'Every day';
	String get monthly => 'Every month';
	String get annually => 'Every year';
	String get quaterly => 'Every quarterly';
	String get weekly => 'Every week';
}

// Path: financial_health.review.descr
class _TranslationsFinancialHealthReviewDescrEn {
	_TranslationsFinancialHealthReviewDescrEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get insufficient_data => 'It looks like we don\'t have enough expenses to calculate your financial health. Add some expenses/incomes in this period to allow us to help you!';
	String get very_good => 'Congratulations! Your financial health is tremendous. We hope you continue your good streak and continue learning with Parsa';
	String get good => 'Great! Your financial health is good. Visit the analysis tab to see how to save even more!';
	String get normal => 'Your financial health is more or less in the average of the rest of the population for this period';
	String get bad => 'It seems that your financial situation is not the best yet. Explore the rest of the charts to learn more about your finances';
	String get very_bad => 'Hmm, your financial health is far below what it should be. Explore the rest of the charts to learn more about your finances';
}

// Path: financial_health.savings_percentage.text
class _TranslationsFinancialHealthSavingsPercentageTextEn {
	_TranslationsFinancialHealthSavingsPercentageTextEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String good({required Object value}) => 'Congratulations! You have managed to save <b>${value}%</b> of your income during this period. It seems that you are already an expert, keep up the good work!';
	String normal({required Object value}) => 'Congratulations, you have managed to save <b>${value}%</b> of your income during this period.';
	String bad({required Object value}) => 'You have managed to save <b>${value}%</b> of your income during this period. However, we think you can still do much more!';
	String get very_bad => 'Wow, you haven\'t managed to save anything during this period.';
}

// Path: transaction.list.bulk_edit
class _TranslationsTransactionListBulkEditEn {
	_TranslationsTransactionListBulkEditEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get dates => 'Edit dates';
	String get categories => 'Edit categories';
	String get status => 'Edit statuses';
}

// Path: transaction.form.validators
class _TranslationsTransactionFormValidatorsEn {
	_TranslationsTransactionFormValidatorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get zero => 'The value of a transaction cannot be equal to zero';
	String get date_max => 'The selected date is after the current one. The transaction will be added as pending';
	String get date_after_account_creation => 'You cannot create a transaction whose date is before the creation date of the account it belongs to';
	String get negative_transfer => 'The monetary value of a transfer cannot be negative';
	String get transfer_between_same_accounts => 'The origin and the destination account cannot be the same';
}

// Path: transfer.form.value_in_destiny
class _TranslationsTransferFormValueInDestinyEn {
	_TranslationsTransferFormValueInDestinyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Amount transferred at destination';
	String amount_short({required Object amount}) => '${amount} to target account';
}

// Path: backup.import.manual_import
class _TranslationsBackupImportManualImportEn {
	_TranslationsBackupImportManualImportEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Manual import';
	String get descr => 'Import transactions from a .csv file manually';
	String get default_account => 'Default account';
	String get remove_default_account => 'Remove default account';
	String get default_category => 'Default Category';
	String get select_a_column => 'Select a column from the .csv';
	List<String> get steps => [
		'Select your file',
		'Column for quantity',
		'Column for account',
		'Column for category',
		'Column for date',
		'other columns',
	];
	List<String> get steps_descr => [
		'Select a .csv file from your device. Make sure it has a first row that describes the name of each column',
		'Select the column where the value of each transaction is specified. Use negative values for expenses and positive values for income. Use a point as a decimal separator',
		'Select the column where the account to which each transaction belongs is specified. You can also select a default account in case we cannot find the account you want. If a default account is not specified, we will create one with the same name ',
		'Specify the column where the transaction category name is located. You must specify a default category so that we assign this category to transactions, in case the category cannot be found',
		'Select the column where the date of each transaction is specified. If not specified, transactions will be created with the current date',
		'Specifies the columns for other optional transaction attributes',
	];
	String success({required Object x}) => 'Successfully imported ${x} transactions';
}

// Path: more.about_us.legal
class _TranslationsMoreAboutUsLegalEn {
	_TranslationsMoreAboutUsLegalEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Legal information';
	String get privacy => 'Privacy policy';
	String get terms => 'Terms of use';
	String get licenses => 'Licenses';
}

// Path: more.about_us.project
class _TranslationsMoreAboutUsProjectEn {
	_TranslationsMoreAboutUsProjectEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get display => 'Project';
	String get contributors => 'Collaborators';
	String get contributors_descr => 'All the developers who have made Parsa grow';
	String get contact => 'Contact us';
}

// Path: general.time.ranges.types
class _TranslationsGeneralTimeRangesTypesEn {
	_TranslationsGeneralTimeRangesTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get cycle => 'Cycles';
	String get last_days => 'Last days';
	String last_days_form({required Object x}) => '${x} previous days';
	String get all => 'Always';
	String get date_range => 'Custom range';
}

// Path: <root>
class _TranslationsEs implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsEs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _TranslationsEs _root = this; // ignore: unused_field

	// Translations
	@override late final _TranslationsGeneralEs general = _TranslationsGeneralEs._(_root);
	@override late final _TranslationsIntroEs intro = _TranslationsIntroEs._(_root);
	@override late final _TranslationsHomeEs home = _TranslationsHomeEs._(_root);
	@override late final _TranslationsFinancialHealthEs financial_health = _TranslationsFinancialHealthEs._(_root);
	@override late final _TranslationsStatsEs stats = _TranslationsStatsEs._(_root);
	@override late final _TranslationsIconSelectorEs icon_selector = _TranslationsIconSelectorEs._(_root);
	@override late final _TranslationsTransactionEs transaction = _TranslationsTransactionEs._(_root);
	@override late final _TranslationsTransferEs transfer = _TranslationsTransferEs._(_root);
	@override late final _TranslationsRecurrentTransactionsEs recurrent_transactions = _TranslationsRecurrentTransactionsEs._(_root);
	@override late final _TranslationsAccountEs account = _TranslationsAccountEs._(_root);
	@override late final _TranslationsCurrenciesEs currencies = _TranslationsCurrenciesEs._(_root);
	@override late final _TranslationsTagsEs tags = _TranslationsTagsEs._(_root);
	@override late final _TranslationsCategoriesEs categories = _TranslationsCategoriesEs._(_root);
	@override late final _TranslationsBudgetsEs budgets = _TranslationsBudgetsEs._(_root);
	@override late final _TranslationsBackupEs backup = _TranslationsBackupEs._(_root);
	@override late final _TranslationsSettingsEs settings = _TranslationsSettingsEs._(_root);
	@override late final _TranslationsMoreEs more = _TranslationsMoreEs._(_root);
}

// Path: general
class _TranslationsGeneralEs implements _TranslationsGeneralEn {
	_TranslationsGeneralEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Cancelar';
	@override String get or => 'o';
	@override String get understood => 'Entendido';
	@override String get unspecified => 'Sin especificar';
	@override String get confirm => 'Confirmar';
	@override String get continue_text => 'Continuar';
	@override String get quick_actions => 'Acciones rápidas';
	@override String get save => 'Guardar';
	@override String get save_changes => 'Guardar cambios';
	@override String get close_and_save => 'Guardar y cerrar';
	@override String get add => 'Añadir';
	@override String get edit => 'Editar';
	@override String get delete => 'Eliminar';
	@override String get balance => 'Balance';
	@override String get account => 'Cuenta';
	@override String get accounts => 'Cuentas';
	@override String get categories => 'Categorías';
	@override String get category => 'Categoría';
	@override String get today => 'Hoy';
	@override String get yesterday => 'Ayer';
	@override String get filters => 'Filtros';
	@override String get select_all => 'Seleccionar todo';
	@override String get deselect_all => 'Deseleccionar todo';
	@override String get empty_warn => 'Ops! Esto esta muy vacio';
	@override String get insufficient_data => 'Datos insuficientes';
	@override String get show_more_fields => 'Show more fields';
	@override String get show_less_fields => 'Show less fields';
	@override String get tap_to_search => 'Toca para buscar';
	@override late final _TranslationsGeneralClipboardEs clipboard = _TranslationsGeneralClipboardEs._(_root);
	@override late final _TranslationsGeneralTimeEs time = _TranslationsGeneralTimeEs._(_root);
	@override late final _TranslationsGeneralTransactionOrderEs transaction_order = _TranslationsGeneralTransactionOrderEs._(_root);
	@override late final _TranslationsGeneralValidationsEs validations = _TranslationsGeneralValidationsEs._(_root);
}

// Path: intro
class _TranslationsIntroEs implements _TranslationsIntroEn {
	_TranslationsIntroEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get start => 'Empecemos';
	@override String get skip => 'Saltar';
	@override String get next => 'Siguiente';
	@override String get select_your_currency => 'Selecciona tu divisa';
	@override String get welcome_subtitle => 'Tu gestor de finanzas personales';
	@override String get welcome_subtitle2 => '100% libre, 100% gratis';
	@override String get welcome_footer => 'Al iniciar sesión aceptas la <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/PRIVACY_POLICY.md\'>Política de Privacidad</a> y los <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/TERMS_OF_USE.md\'>Términos de uso</a> de la aplicación';
	@override String get offline_descr_title => 'CUENTA SIN CONEXIÓN:';
	@override String get offline_descr => 'Tus datos serán guardados unicamente en tu dispositivo, y estarán seguros mientras no desinstales la app o cambies de telefono. Para prevenir la perdida de datos se recomienda realizar una copia de seguridad regularmente desde los ajustes de la app.';
	@override String get offline_start => 'Iniciar sesión offline';
	@override String get sl1_title => 'Selecciona tu divisa';
	@override String get sl1_descr => 'Para empezar, selecciona tu moneda. Podrás cambiar de divisa y de idioma mas adelante en todo momento en los ajustes de la aplicación';
	@override String get sl2_title => 'Seguro, privado y confiable';
	@override String get sl2_descr => 'Tus datos son solo tuyos. Almacenamos la información directamente en tu dispositivo, sin pasar por servidores externos. Esto hace que puedas usar la aplicación incluso sin Internet';
	@override String get sl2_descr2 => 'Además, el código fuente de la aplicación es público, cualquiera puede colaborar en el y ver como funciona';
	@override String get last_slide_title => 'Todo listo!';
	@override String get last_slide_descr => 'Con Parsa, podrás al fin lograr la independencia financiaria que tanto deseas. Podrás ver gráficas, presupuestos, consejos, estadisticas y mucho más sobre tu dinero.';
	@override String get last_slide_descr2 => 'Esperemos que disfrutes de tu experiencia! No dudes en contactar con nosotros en caso de dudas, sugerencias...';
}

// Path: home
class _TranslationsHomeEs implements _TranslationsHomeEn {
	_TranslationsHomeEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dashboard';
	@override String get filter_transactions => 'Filtrar transacciones';
	@override String get hello_day => 'Buenos días,';
	@override String get hello_night => 'Buenas noches,';
	@override String get total_balance => 'Saldo total';
	@override String get my_accounts => 'Mis cuentas';
	@override String get active_accounts => 'Cuentas activas';
	@override String get no_accounts => 'Aun no hay cuentas creadas';
	@override String get no_accounts_descr => 'Empieza a usar toda la magia de Parsa. Crea al menos una cuenta para empezar a añadir tranacciones';
	@override String get last_transactions => 'Últimas transacciones';
	@override String get should_create_account_header => 'Ops!';
	@override String get should_create_account_message => 'Debes tener al menos una cuenta no archivada que no sea de ahorros antes de empezar a crear transacciones';
}

// Path: financial_health
class _TranslationsFinancialHealthEs implements _TranslationsFinancialHealthEn {
	_TranslationsFinancialHealthEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Salud financiera';
	@override late final _TranslationsFinancialHealthReviewEs review = _TranslationsFinancialHealthReviewEs._(_root);
	@override late final _TranslationsFinancialHealthMonthsWithoutIncomeEs months_without_income = _TranslationsFinancialHealthMonthsWithoutIncomeEs._(_root);
	@override late final _TranslationsFinancialHealthSavingsPercentageEs savings_percentage = _TranslationsFinancialHealthSavingsPercentageEs._(_root);
}

// Path: stats
class _TranslationsStatsEs implements _TranslationsStatsEn {
	_TranslationsStatsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Estadísticas';
	@override String get balance => 'Saldo';
	@override String get final_balance => 'Saldo final';
	@override String get balance_by_account => 'Saldo por cuentas';
	@override String get balance_by_currency => 'Saldo por divisas';
	@override String get balance_evolution => 'Tendencia de saldo';
	@override String get compared_to_previous_period => 'Frente al periodo anterior';
	@override String get cash_flow => 'Flujo de caja';
	@override String get by_periods => 'Por periodos';
	@override String get by_categories => 'Por categorías';
	@override String get by_tags => 'Por etiquetas';
	@override String get distribution => 'Distribución';
	@override String get finance_health_resume => 'Resumen';
	@override String get finance_health_breakdown => 'Desglose';
}

// Path: icon_selector
class _TranslationsIconSelectorEs implements _TranslationsIconSelectorEn {
	_TranslationsIconSelectorEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nombre:';
	@override String get icon => 'Icono';
	@override String get color => 'Color';
	@override String get select_icon => 'Selecciona un icono';
	@override String get select_color => 'Selecciona un color';
	@override String get select_account_icon => 'Identifica tu cuenta';
	@override String get select_category_icon => 'Identifica tu categoría';
	@override late final _TranslationsIconSelectorScopesEs scopes = _TranslationsIconSelectorScopesEs._(_root);
}

// Path: transaction
class _TranslationsTransactionEs implements _TranslationsTransactionEn {
	_TranslationsTransactionEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Transacción',
		other: 'Transacciones',
	);
	@override String get create => 'Nueva transacción';
	@override String get new_income => 'Nuevo ingreso';
	@override String get new_expense => 'Nuevo gasto';
	@override String get new_success => 'Transacción creada correctamente';
	@override String get edit => 'Editar transacción';
	@override String get edit_success => 'Transacción editada correctamente';
	@override String get edit_multiple => 'Editar transacciones';
	@override String edit_multiple_success({required Object x}) => '${x} transacciones editadas correctamente';
	@override String get duplicate => 'Clonar transacción';
	@override String get duplicate_short => 'Clonar';
	@override String get duplicate_warning_message => 'Se creará una transacción identica a esta con su misma fecha, ¿deseas continuar?';
	@override String get duplicate_success => 'Transacción clonada con exito';
	@override String get delete => 'Eliminar transacción';
	@override String get delete_warning_message => 'Esta acción es irreversible. El balance actual de tus cuentas y todas tus estadisticas serán recalculadas';
	@override String get delete_success => 'Transacción eliminada correctamente';
	@override String get delete_multiple => 'Eliminar transacciones';
	@override String delete_multiple_warning_message({required Object x}) => 'Esta acción es irreversible y borrará definitivamente ${x} transacciones. El balance actual de tus cuentas y todas tus estadisticas serán recalculadas';
	@override String delete_multiple_success({required Object x}) => '${x} transacciones eliminadas correctamente';
	@override String get details => 'Detalles del movimiento';
	@override late final _TranslationsTransactionNextPaymentsEs next_payments = _TranslationsTransactionNextPaymentsEs._(_root);
	@override late final _TranslationsTransactionListEs list = _TranslationsTransactionListEs._(_root);
	@override late final _TranslationsTransactionFiltersEs filters = _TranslationsTransactionFiltersEs._(_root);
	@override late final _TranslationsTransactionFormEs form = _TranslationsTransactionFormEs._(_root);
	@override late final _TranslationsTransactionReversedEs reversed = _TranslationsTransactionReversedEs._(_root);
	@override late final _TranslationsTransactionStatusEs status = _TranslationsTransactionStatusEs._(_root);
	@override late final _TranslationsTransactionTypesEs types = _TranslationsTransactionTypesEs._(_root);
}

// Path: transfer
class _TranslationsTransferEs implements _TranslationsTransferEn {
	_TranslationsTransferEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Transferencia';
	@override String get transfers => 'Transferencias';
	@override String transfer_to({required Object account}) => 'Transferencia hacia ${account}';
	@override String get create => 'Nueva transferencia';
	@override String get need_two_accounts_warning_header => 'Ops!';
	@override String get need_two_accounts_warning_message => 'Se necesitan al menos dos cuentas para realizar esta acción. Si lo que necesitas es ajustar o editar el balance actual de esta cuenta pulsa el botón de editar';
	@override late final _TranslationsTransferFormEs form = _TranslationsTransferFormEs._(_root);
}

// Path: recurrent_transactions
class _TranslationsRecurrentTransactionsEs implements _TranslationsRecurrentTransactionsEn {
	_TranslationsRecurrentTransactionsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Movimientos recurrentes';
	@override String get title_short => 'Mov. recurrentes';
	@override String get empty => 'Parece que no posees ninguna transacción recurrente. Crea una transacción que se repita mensual, anual o semanalmente y aparecerá aquí';
	@override String get total_expense_title => 'Gasto total por periodo';
	@override String get total_expense_descr => '* Sin considerar la fecha de inicio y fin de cada recurrencia';
	@override late final _TranslationsRecurrentTransactionsDetailsEs details = _TranslationsRecurrentTransactionsDetailsEs._(_root);
}

// Path: account
class _TranslationsAccountEs implements _TranslationsAccountEn {
	_TranslationsAccountEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get details => 'Detalles de la cuenta';
	@override String get date => 'Fecha de apertura';
	@override String get close_date => 'Fecha de cierre';
	@override String get reopen_short => 'Reabrir';
	@override String get reopen => 'Reabrir cuenta';
	@override String get reopen_descr => '¿Seguro que quieres volver a abrir esta cuenta?';
	@override String get balance => 'Saldo de la cuenta';
	@override String get n_transactions => 'Número de transacciones';
	@override String get add_money => 'Añadir dinero';
	@override String get withdraw_money => 'Retirar dinero';
	@override String get no_accounts => 'No se han encontrado cuentas que mostrar aquí. Añade una transacción pulsando el botón \'+\' de la parte inferior';
	@override late final _TranslationsAccountTypesEs types = _TranslationsAccountTypesEs._(_root);
	@override late final _TranslationsAccountFormEs form = _TranslationsAccountFormEs._(_root);
	@override late final _TranslationsAccountDeleteEs delete = _TranslationsAccountDeleteEs._(_root);
	@override late final _TranslationsAccountCloseEs close = _TranslationsAccountCloseEs._(_root);
	@override late final _TranslationsAccountSelectEs select = _TranslationsAccountSelectEs._(_root);
}

// Path: currencies
class _TranslationsCurrenciesEs implements _TranslationsCurrenciesEn {
	_TranslationsCurrenciesEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get currency_converter => 'Conversor de divisas';
	@override String get currency_manager => 'Administrador de divisas';
	@override String get currency_manager_descr => 'Configura tu divisa y sus tipos de cambio con otras';
	@override String get currency => 'Divisa';
	@override String get preferred_currency => 'Divisa predeterminada/base';
	@override String get change_preferred_currency_title => 'Cambiar divisa predeterminada';
	@override String get change_preferred_currency_msg => 'Todas las estadisticas y presupuestos serán mostradas en esta divisa a partir de ahora. Las cuentas y transacciones mantendrán la divisa que tenían. Todos los tipos de cambios guardados serán eliminados si ejecutas esta acción, ¿Desea continuar?';
	@override late final _TranslationsCurrenciesFormEs form = _TranslationsCurrenciesFormEs._(_root);
	@override String get delete_all_success => 'Tipos de cambio borrados con exito';
	@override String get historical => 'Histórico de tasas';
	@override String get exchange_rate => 'Tipo de cambio';
	@override String get exchange_rates => 'Tipos de cambio';
	@override String get empty => 'Añade tipos de cambio aqui para que en caso de tener cuentas en otras divisas distintas a tu divisa base nuestros gráficos sean mas exactos';
	@override String get select_a_currency => 'Selecciona una divisa';
	@override String get search => 'Busca por nombre o por código de la divisa';
}

// Path: tags
class _TranslationsTagsEs implements _TranslationsTagsEn {
	_TranslationsTagsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Etiqueta',
		other: 'Etiquetas',
	);
	@override late final _TranslationsTagsFormEs form = _TranslationsTagsFormEs._(_root);
	@override String get empty_list => 'No has creado ninguna etiqueta aun. Las etiquetas y las categorías son una gran forma de categorizar tus movimientos';
	@override String get without_tags => 'Sin etiquetas';
	@override String get select => 'Selecionar etiquetas';
	@override String get create => 'Crear etiqueta';
	@override String get add => 'Añadir etiqueta';
	@override String get create_success => 'Etiqueta creada correctamente';
	@override String get already_exists => 'El nombre de esta etiqueta ya existe. Puede que quieras editarla';
	@override String get edit => 'Editar etiqueta';
	@override String get edit_success => 'Etiqueta editada correctamente';
	@override String get delete_success => 'Categoría eliminada correctamente';
	@override String get delete_warning_header => '¿Eliminar etiqueta?';
	@override String get delete_warning_message => 'Esta acción no borrará las transacciones que poseen esta etiqueta.';
}

// Path: categories
class _TranslationsCategoriesEs implements _TranslationsCategoriesEn {
	_TranslationsCategoriesEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get unknown => 'Categoría desconocida';
	@override String get create => 'Crear categoría';
	@override String get create_success => 'Categoría creada correctamente';
	@override String get new_category => 'Nueva categoría';
	@override String get already_exists => 'El nombre de esta categoría ya existe. Puede que quieras editarla';
	@override String get edit => 'Editar categoría';
	@override String get edit_success => 'Categoría editada correctamente';
	@override String get name => 'Nombre de la categoría';
	@override String get type => 'Tipo de categoría';
	@override String get both_types => 'Ambos tipos';
	@override String get subcategories => 'Subcategorías';
	@override String get subcategories_add => 'Añadir subcategoría';
	@override String get make_parent => 'Convertir en categoría';
	@override String get make_child => 'Convertir en subcategoría';
	@override String make_child_warning1({required Object destiny}) => 'Esta categoría y sus subcategorías pasarán a ser subcategorías de <b>${destiny}</b>.';
	@override String make_child_warning2({required Object x, required Object destiny}) => 'Sus transacciones <b>(${x})</b> pasarán a las nuevas subcategorías creadas dentro de la categoría <b>${destiny}</b>.';
	@override String get make_child_success => 'Subcategorías creadas con exito';
	@override String get merge => 'Fusionar con otra categoría';
	@override String merge_warning1({required Object x, required Object from, required Object destiny}) => 'Todas las transacciones (${x}) asocidadas con la categoría <b>${from}</b> serán movidas a la categoría <b>${destiny}</b>.';
	@override String merge_warning2({required Object from}) => 'La categoría <b>${from}</b> será eliminada de forma irreversible.';
	@override String get merge_success => 'Categoría fusionada correctamente';
	@override String get delete_success => 'Categoría eliminada correctamente';
	@override String get delete_warning_header => '¿Eliminar categoría?';
	@override String delete_warning_message({required Object x}) => 'Esta acción borrará de forma irreversible todas las transacciones <b>(${x})</b> relativas a esta categoría.';
	@override late final _TranslationsCategoriesSelectEs select = _TranslationsCategoriesSelectEs._(_root);
}

// Path: budgets
class _TranslationsBudgetsEs implements _TranslationsBudgetsEn {
	_TranslationsBudgetsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Presupuestos';
	@override String get repeated => 'Periódicos';
	@override String get one_time => 'Una vez';
	@override String get annual => 'Anuales';
	@override String get week => 'Semanales';
	@override String get month => 'Mensuales';
	@override String get actives => 'Activos';
	@override String get pending => 'Pendientes de comenzar';
	@override String get finish => 'Finalizados';
	@override String get from_budgeted => 'De un total de ';
	@override String get days_left => 'días restantes';
	@override String get days_to_start => 'días para empezar';
	@override String get since_expiration => 'días desde su expiración';
	@override String get no_budgets => 'Parece que no hay presupuestos que mostrar en esta sección. Empieza creando un presupuesto pulsando el botón inferior';
	@override String get delete => 'Eliminar presupuesto';
	@override String get delete_warning => 'Esta acción es irreversible. Categorías y transacciones referentes a este presupuesto no serán eliminados';
	@override late final _TranslationsBudgetsFormEs form = _TranslationsBudgetsFormEs._(_root);
	@override late final _TranslationsBudgetsDetailsEs details = _TranslationsBudgetsDetailsEs._(_root);
}

// Path: backup
class _TranslationsBackupEs implements _TranslationsBackupEn {
	_TranslationsBackupEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsBackupExportEs export = _TranslationsBackupExportEs._(_root);
	@override late final _TranslationsBackupImportEs import = _TranslationsBackupImportEs._(_root);
	@override late final _TranslationsBackupAboutEs about = _TranslationsBackupAboutEs._(_root);
}

// Path: settings
class _TranslationsSettingsEs implements _TranslationsSettingsEn {
	_TranslationsSettingsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title_long => 'Configuración y apariencia';
	@override String get title_short => 'Configuración';
	@override String get description => 'Tema de la aplicación, textos y otras configuraciones generales';
	@override String get edit_profile => 'Editar perfil';
	@override String get lang_section => 'Idioma y textos';
	@override String get lang_title => 'Idioma de la aplicación';
	@override String get lang_descr => 'Idioma en el que se mostrarán los textos en la aplicación';
	@override String get locale => 'Región';
	@override String get locale_descr => 'Establecer el formato a utilizar para fechas, números...';
	@override String get locale_warn => 'Al cambiar la región, la aplicación se actualizará';
	@override String get first_day_of_week => 'Primer día de la semana';
	@override String get theme_and_colors => 'Tema y colores';
	@override String get theme => 'Tema';
	@override String get theme_auto => 'Definido por el sistema';
	@override String get theme_light => 'Claro';
	@override String get theme_dark => 'Oscuro';
	@override String get amoled_mode => 'Modo AMOLED';
	@override String get amoled_mode_descr => 'Usar un fondo negro puro cuando sea posible. Esto ayudará ligeramente a la batería de dispositivos con pantallas AMOLED';
	@override String get dynamic_colors => 'Colores dinámicos';
	@override String get dynamic_colors_descr => 'Usar el color de acento de su sistema siempre que sea posible';
	@override String get accent_color => 'Color de acento';
	@override String get accent_color_descr => 'Elegir el color que la aplicación usará para enfatizar ciertas partes de la interfaz';
	@override late final _TranslationsSettingsSecurityEs security = _TranslationsSettingsSecurityEs._(_root);
}

// Path: more
class _TranslationsMoreEs implements _TranslationsMoreEn {
	_TranslationsMoreEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Más';
	@override String get title_long => 'Más acciones';
	@override late final _TranslationsMoreDataEs data = _TranslationsMoreDataEs._(_root);
	@override late final _TranslationsMoreAboutUsEs about_us = _TranslationsMoreAboutUsEs._(_root);
	@override late final _TranslationsMoreHelpUsEs help_us = _TranslationsMoreHelpUsEs._(_root);
}

// Path: general.clipboard
class _TranslationsGeneralClipboardEs implements _TranslationsGeneralClipboardEn {
	_TranslationsGeneralClipboardEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String success({required Object x}) => '${x} copiado al portapapeles';
	@override String get error => 'Error al copiar';
}

// Path: general.time
class _TranslationsGeneralTimeEs implements _TranslationsGeneralTimeEn {
	_TranslationsGeneralTimeEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get start_date => 'Fecha de inicio';
	@override String get end_date => 'Fecha de fin';
	@override String get from_date => 'Desde fecha';
	@override String get until_date => 'Hasta fecha';
	@override String get date => 'Fecha';
	@override String get datetime => 'Fecha y hora';
	@override String get time => 'Hora';
	@override String get each => 'Cada';
	@override String get after => 'Tras';
	@override late final _TranslationsGeneralTimeRangesEs ranges = _TranslationsGeneralTimeRangesEs._(_root);
	@override late final _TranslationsGeneralTimePeriodicityEs periodicity = _TranslationsGeneralTimePeriodicityEs._(_root);
	@override late final _TranslationsGeneralTimeCurrentEs current = _TranslationsGeneralTimeCurrentEs._(_root);
	@override late final _TranslationsGeneralTimeAllEs all = _TranslationsGeneralTimeAllEs._(_root);
}

// Path: general.transaction_order
class _TranslationsGeneralTransactionOrderEs implements _TranslationsGeneralTransactionOrderEn {
	_TranslationsGeneralTransactionOrderEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Ordenar transacciones';
	@override String get category => 'Por categoría';
	@override String get quantity => 'Por cantidad';
	@override String get date => 'Por fecha';
}

// Path: general.validations
class _TranslationsGeneralValidationsEs implements _TranslationsGeneralValidationsEn {
	_TranslationsGeneralValidationsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get required => 'Campo obligatorio';
	@override String get positive => 'Debe ser positivo';
	@override String min_number({required Object x}) => 'Debe ser mayor que ${x}';
	@override String max_number({required Object x}) => 'Debe ser menor que ${x}';
}

// Path: financial_health.review
class _TranslationsFinancialHealthReviewEs implements _TranslationsFinancialHealthReviewEn {
	_TranslationsFinancialHealthReviewEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String very_good({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Excelente!';
			case GenderContext.female:
				return 'Excelente!';
		}
	}
	@override String good({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Bueno';
			case GenderContext.female:
				return 'Buena';
		}
	}
	@override String normal({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'En la media';
			case GenderContext.female:
				return 'En la media';
		}
	}
	@override String bad({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Regular';
			case GenderContext.female:
				return 'Regular';
		}
	}
	@override String very_bad({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Muy malo';
			case GenderContext.female:
				return 'Muy mala';
		}
	}
	@override String insufficient_data({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Datos insuficientes';
			case GenderContext.female:
				return 'Datos insuficientes';
		}
	}
	@override late final _TranslationsFinancialHealthReviewDescrEs descr = _TranslationsFinancialHealthReviewDescrEs._(_root);
}

// Path: financial_health.months_without_income
class _TranslationsFinancialHealthMonthsWithoutIncomeEs implements _TranslationsFinancialHealthMonthsWithoutIncomeEn {
	_TranslationsFinancialHealthMonthsWithoutIncomeEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ratio de supervivencia';
	@override String get subtitle => 'Dado tu saldo, cantidad de tiempo que podrías pasar sin ingresos';
	@override String get text_zero => '¡No podrías sobrevivir un mes sin ingresos con este ritmo de gastos!';
	@override String get text_one => '¡Apenas podrías sobrevivir aproximadamente un mes sin ingresos con este ritmo de gastos!';
	@override String text_other({required Object n}) => 'Podrías sobrevivir aproximadamente <b>${n} meses</b> sin ingresos a este ritmo de gasto.';
	@override String get text_infinite => 'Podrías sobrevivir aproximadamente <b>casi toda tu vida</b> sin ingresos a este ritmo de gasto.';
	@override String get suggestion => 'Recuerda que es recomendable mantener este ratio siempre por encima de 5 meses como mínimo. Si ves que no tienes un colchon de ahorro suficiente, reduce los gastos no necesarios.';
	@override String get insufficient_data => 'Parece que no tenemos gastos suficientes para calcular cuantos meses podrías sobrevivir sin ingresos. Introduce unas pocas transacciones y regresa aquí para consultar tu salud financiera';
}

// Path: financial_health.savings_percentage
class _TranslationsFinancialHealthSavingsPercentageEs implements _TranslationsFinancialHealthSavingsPercentageEn {
	_TranslationsFinancialHealthSavingsPercentageEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Porcentaje de ahorro';
	@override String get subtitle => 'Que parte de tus ingresos no son gastados en este periodo';
	@override late final _TranslationsFinancialHealthSavingsPercentageTextEs text = _TranslationsFinancialHealthSavingsPercentageTextEs._(_root);
	@override String get suggestion => 'Recuerda que es recomendable ahorrar al menos un 15-20% de lo que ingresas.';
}

// Path: icon_selector.scopes
class _TranslationsIconSelectorScopesEs implements _TranslationsIconSelectorScopesEn {
	_TranslationsIconSelectorScopesEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get transport => 'Transporte';
	@override String get money => 'Dinero';
	@override String get food => 'Comida';
	@override String get medical => 'Salud';
	@override String get entertainment => 'Entretenimiento';
	@override String get technology => 'Technología';
	@override String get other => 'Otros';
	@override String get logos_financial_institutions => 'Financial institutions';
}

// Path: transaction.next_payments
class _TranslationsTransactionNextPaymentsEs implements _TranslationsTransactionNextPaymentsEn {
	_TranslationsTransactionNextPaymentsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get skip => 'Saltar';
	@override String get skip_success => 'Transacción saltada con exito';
	@override String get skip_dialog_title => 'Saltar transacción';
	@override String skip_dialog_msg({required Object date}) => 'Esta acción es irreversible. Desplazaremos la fecha del proximo movimiento al día ${date}';
	@override String get accept => 'Aceptar';
	@override String get accept_today => 'Aceptar hoy';
	@override String accept_in_required_date({required Object date}) => 'Aceptar en la fecha requerida (${date})';
	@override String get accept_dialog_title => 'Aceptar transacción';
	@override String get accept_dialog_msg_single => 'El estado de la transacción pasará a ser nulo. Puedes volver a editar el estado de esta transacción cuando lo desees';
	@override String accept_dialog_msg({required Object date}) => 'Esta acción creará una transacción nueva con fecha ${date}. Podrás consultar los detalles de esta transacción en la página de transacciones';
	@override String get recurrent_rule_finished => 'La regla recurrente se ha completado, ya no hay mas pagos a realizar!';
}

// Path: transaction.list
class _TranslationsTransactionListEs implements _TranslationsTransactionListEn {
	_TranslationsTransactionListEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get empty => 'No se han encontrado transacciones que mostrar aquí. Añade una transacción pulsando el botón \'+\' de la parte inferior';
	@override String get searcher_placeholder => 'Busca por categoría, descripción...';
	@override String get searcher_no_results => 'No se han encontrado transacciones que coincidan con los criterios de busqueda';
	@override String get loading => 'Cargando más transacciones...';
	@override String selected_short({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: '${n} seleccionada',
		other: '${n} seleccionadas',
	);
	@override String selected_long({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: '${n} transacción seleccionada',
		other: '${n} transacciones seleccionadas',
	);
	@override late final _TranslationsTransactionListBulkEditEs bulk_edit = _TranslationsTransactionListBulkEditEs._(_root);
}

// Path: transaction.filters
class _TranslationsTransactionFiltersEs implements _TranslationsTransactionFiltersEn {
	_TranslationsTransactionFiltersEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get from_value => 'Desde monto';
	@override String get to_value => 'Hasta monto';
	@override String from_value_def({required Object x}) => 'Desde ${x}';
	@override String to_value_def({required Object x}) => 'Hasta ${x}';
	@override String from_date_def({required Object date}) => 'Desde el ${date}';
	@override String to_date_def({required Object date}) => 'Hasta el ${date}';
}

// Path: transaction.form
class _TranslationsTransactionFormEs implements _TranslationsTransactionFormEn {
	_TranslationsTransactionFormEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTransactionFormValidatorsEs validators = _TranslationsTransactionFormValidatorsEs._(_root);
	@override String get title => 'Título de la transacción';
	@override String get title_short => 'Título';
	@override String get no_tags => '-- Sin etiquetas --';
	@override String get value => 'Valor de la transacción';
	@override String get tap_to_see_more => 'Toca para ver más detalles';
	@override String get description => 'Descripción';
	@override String get description_info => 'Toca aquí para escribir una descripción mas detallada sobre esta transacción';
	@override String exchange_to_preferred_title({required Object currency}) => 'Cambio a ${currency}';
	@override String get exchange_to_preferred_in_date => 'El día de la transacción';
}

// Path: transaction.reversed
class _TranslationsTransactionReversedEs implements _TranslationsTransactionReversedEn {
	_TranslationsTransactionReversedEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transacción invertida';
	@override String get title_short => 'Tr. invertida';
	@override String get description_for_expenses => 'A pesar de ser una transacción de tipo gasto, esta transacción tiene un monto positivo. Este tipo de transacciones pueden usarse para representar la devolución de un gasto previamente registrado, como un reembolso o que te realicen el pago de una deuda.';
	@override String get description_for_incomes => 'A pesar de ser una transacción de tipo ingreso, esta transacción tiene un monto negativo. Este tipo de transacciones pueden usarse para anular o corregir un ingreso que fue registrado incorrectamente, para reflejar una devolución o reembolso de dinero o para registrar el pago de deudas.';
}

// Path: transaction.status
class _TranslationsTransactionStatusEs implements _TranslationsTransactionStatusEn {
	_TranslationsTransactionStatusEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Estado',
		other: 'Estados',
	);
	@override String get display_long => 'Estado de la transacción';
	@override String tr_status({required Object status}) => 'Transacción ${status}';
	@override String get none => 'Sin estado';
	@override String get none_descr => 'Transacción sin un estado concreto';
	@override String get reconciled => 'Reconciliada';
	@override String get reconciled_descr => 'Esta transacción ha sido validada ya y se corresponde con una transacción real de su banco';
	@override String get unreconciled => 'No reconciliada';
	@override String get unreconciled_descr => 'Esta transacción aun no ha sido validada y por tanto aun no figura en sus cuentas bancarias reales. Sin embargo, es tenida en cuenta para el calculo de balances y estadisticas en Parsa';
	@override String get pending => 'Pendiente';
	@override String get pending_descr => 'Esta transacción esta pendiente y por tanto no será tenida en cuenta a la hora de calcular balances y estadísticas';
	@override String get voided => 'Nula';
	@override String get voided_descr => 'Transacción nula/cancelada debido a un error en el pago o cualquier otro motivo. No será tenida en cuenta a la hora de calcular balances y estadísticas';
}

// Path: transaction.types
class _TranslationsTransactionTypesEs implements _TranslationsTransactionTypesEn {
	_TranslationsTransactionTypesEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Tipo de transacción',
		other: 'Tipos de transacción',
	);
	@override String income({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Ingreso',
		other: 'Ingresos',
	);
	@override String expense({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Gasto',
		other: 'Gastos',
	);
	@override String transfer({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Transferencia',
		other: 'Transferencias',
	);
}

// Path: transfer.form
class _TranslationsTransferFormEs implements _TranslationsTransferFormEn {
	_TranslationsTransferFormEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get from => 'Cuenta origen';
	@override String get to => 'Cuenta destino';
	@override late final _TranslationsTransferFormValueInDestinyEs value_in_destiny = _TranslationsTransferFormValueInDestinyEs._(_root);
}

// Path: recurrent_transactions.details
class _TranslationsRecurrentTransactionsDetailsEs implements _TranslationsRecurrentTransactionsDetailsEn {
	_TranslationsRecurrentTransactionsDetailsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transaccion recurrente';
	@override String get descr => 'A continuación se muestran próximos movimientos de esta transacción. Podrás aceptar el primero de ellos o saltar este movimiento';
	@override String get last_payment_info => 'Este movimiento es el último de la regla recurrente, por lo que se eliminará esta regla de forma automática al confirmar esta acción';
	@override String get delete_header => 'Eliminar transacción recurrente';
	@override String get delete_message => 'Esta acción es irreversible y no afectará a transacciones que ya hayas confirmado/pagado';
}

// Path: account.types
class _TranslationsAccountTypesEs implements _TranslationsAccountTypesEn {
	_TranslationsAccountTypesEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tipo de cuenta';
	@override String get warning => 'Una vez elegido el tipo de cuenta este no podrá cambiarse en un futuro';
	@override String get normal => 'Cuenta corriente';
	@override String get normal_descr => 'Útil para registrar tus finanzas del día a día. Es la cuenta mas común, permite añadir gastos, ingresos...';
	@override String get saving => 'Cuenta de ahorros';
	@override String get saving_descr => 'Solo podrás añadir y retirar dinero de ella desde otras cuentas. Perfecta para empezar a ahorrar';
}

// Path: account.form
class _TranslationsAccountFormEs implements _TranslationsAccountFormEn {
	_TranslationsAccountFormEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nombre de la cuenta';
	@override String get name_placeholder => 'Ej: Cuenta de ahorros';
	@override String get notes => 'Notas';
	@override String get notes_placeholder => 'Escribe algunas notas/descripciones sobre esta cuenta';
	@override String get initial_balance => 'Balance inicial';
	@override String get current_balance => 'Balance actual';
	@override String get create => 'Crear cuenta';
	@override String get edit => 'Editar cuenta';
	@override String get tr_before_opening_date => 'Existen transacciones en esta cuenta con fecha anterior a la fecha de apertura';
	@override String get currency_not_found_warn => 'No posees información sobre tipos de cambio para esta divisa. Se usará 1.0 como tipo de cambio por defecto. Puedes modificar esto en los ajustes';
	@override String get already_exists => 'Ya existe otra cuenta con el mismo nombre. Por favor, escriba otro';
	@override String get iban => 'IBAN';
	@override String get swift => 'SWIFT';
}

// Path: account.delete
class _TranslationsAccountDeleteEs implements _TranslationsAccountDeleteEn {
	_TranslationsAccountDeleteEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get warning_header => '¿Eliminar cuenta?';
	@override String get warning_text => 'Esta acción borrara esta cuenta y todas sus transacciones. No podrás volver a recuperar esta información tras el borrado.';
	@override String get success => 'Cuenta eliminada correctamente';
}

// Path: account.close
class _TranslationsAccountCloseEs implements _TranslationsAccountCloseEn {
	_TranslationsAccountCloseEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cerrar cuenta';
	@override String get title_short => 'Cerrar';
	@override String get warn => 'Esta cuenta ya no aparecerá en ciertos listados y no podrá crear transacciones en ella con fecha posterior a la especificada debajo. Esta acción no afecta a ninguna transacción ni balance, y además, podrás volver a abrir esta cuenta cuando quieras';
	@override String get should_have_zero_balance => 'Debes tener un saldo actual en la cuenta de 0 para poder cerrarla. Edita esta cuenta antes de continuar';
	@override String get should_have_no_transactions => 'Esta cuenta posee transacciones posteriores a la fecha de cierre especificada. Borralas o edita la fecha de cierre de la cuenta antes de continuar';
	@override String get success => 'Cuenta cerrada exitosamente';
	@override String get unarchive_succes => 'Cuenta re-abierta exitosamente';
}

// Path: account.select
class _TranslationsAccountSelectEs implements _TranslationsAccountSelectEn {
	_TranslationsAccountSelectEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get one => 'Selecciona una cuenta';
	@override String get multiple => 'Selecciona cuentas';
	@override String get all => 'Todas las cuentas';
}

// Path: currencies.form
class _TranslationsCurrenciesFormEs implements _TranslationsCurrenciesFormEn {
	_TranslationsCurrenciesFormEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get equal_to_preferred_warn => 'The currency can not be equal to the user currency';
	@override String get specify_a_currency => 'Por favor, especifica una divisa';
	@override String get add => 'Añadir tipo de cambio';
	@override String get add_success => 'Tipo de cambio añadido correctamente';
	@override String get edit => 'Editar tipo de cambio';
	@override String get edit_success => 'Tipo de cambio editado correctamente';
}

// Path: tags.form
class _TranslationsTagsFormEs implements _TranslationsTagsFormEn {
	_TranslationsTagsFormEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nombre de la etiqueta';
	@override String get description => 'Descripción';
}

// Path: categories.select
class _TranslationsCategoriesSelectEs implements _TranslationsCategoriesSelectEn {
	_TranslationsCategoriesSelectEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Selecciona categorías';
	@override String get select_one => 'Selecciona una categoría';
	@override String get select_subcategory => 'Elige una subcategoría';
	@override String get without_subcategory => 'Sin subcategoría';
	@override String get all => 'Todas las categorías';
	@override String get all_short => 'Todas';
}

// Path: budgets.form
class _TranslationsBudgetsFormEs implements _TranslationsBudgetsFormEn {
	_TranslationsBudgetsFormEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Añade un presupuesto';
	@override String get name => 'Nombre del presupuesto';
	@override String get value => 'Cantidad límite';
	@override String get create => 'Añade el presupuesto';
	@override String get edit => 'Editar presupuesto';
	@override String get negative_warn => 'Los presupuestos no pueden tener un valor límite negativo';
}

// Path: budgets.details
class _TranslationsBudgetsDetailsEs implements _TranslationsBudgetsDetailsEn {
	_TranslationsBudgetsDetailsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Detalles del presupuesto';
	@override String get budget_value => 'Presupuestado';
	@override String get statistics => 'Estadísticas';
	@override String expend_diary_left({required Object dailyAmount, required Object remainingDays}) => 'Puedes gastar ${dailyAmount}/día por los ${remainingDays} días restantes';
	@override String get expend_evolution => 'Evolución del gasto';
	@override String get no_transactions => 'Parece que no has realizado ningún gasto relativo a este presupuesto';
}

// Path: backup.export
class _TranslationsBackupExportEs implements _TranslationsBackupExportEn {
	_TranslationsBackupExportEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Exportar datos';
	@override String get title_short => 'Exportar';
	@override String get all => 'Respaldo total';
	@override String get all_descr => 'Exporta todos tus datos (cuentas, transacciones, presupuestos, ajustes...). Importalos de nuevo en cualquier momento para no perder nada.';
	@override String get transactions => 'Respaldo de transacciones';
	@override String get transactions_descr => 'Exporta tus transacciones en CSV para que puedas analizarlas mas facilmente en otros programas o aplicaciones.';
	@override String get description => 'Exporta tus datos en diferentes formatos';
	@override String get dialog_title => 'Guardar/Enviar archivo';
	@override String success({required Object x}) => 'Archivo guardado/enviado correctamente en ${x}';
	@override String get error => 'Error al descargar el archivo. Por favor contacte con el desarrollador via lozin.technologies@gmail.com';
}

// Path: backup.import
class _TranslationsBackupImportEs implements _TranslationsBackupImportEn {
	_TranslationsBackupImportEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Importar tus datos';
	@override String get title_short => 'Importar';
	@override String get restore_backup => 'Restaurar copia de seguridad';
	@override String get restore_backup_descr => 'Importa una base de datos anteriormente guardada desde Parsa. Esta acción remplazará cualquier dato actual de la aplicación por los nuevos datos';
	@override String get restore_backup_warn_title => 'Sobreescribir todos los datos';
	@override String get restore_backup_warn_description => 'Al importar una nueva base de datos, perderas toda la información actualmente guardada en la app. Se recomienda hacer una copia de seguridad antes de continuar. No subas aquí ningún fichero cuyo origen no conozcas, sube solo ficheros que hayas descargado previamente desde Parsa';
	@override String get tap_to_select_file => 'Pulsa para seleccionar un archivo';
	@override String get select_other_file => 'Selecciona otro fichero';
	@override late final _TranslationsBackupImportManualImportEs manual_import = _TranslationsBackupImportManualImportEs._(_root);
	@override String get success => 'Importación realizada con exito';
	@override String get cancelled => 'La importación fue cancelada por el usuario';
	@override String get error => 'Error al importar el archivo. Por favor contacte con el desarrollador via lozin.technologies@gmail.com';
}

// Path: backup.about
class _TranslationsBackupAboutEs implements _TranslationsBackupAboutEn {
	_TranslationsBackupAboutEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Información sobre tu base de datos';
	@override String get create_date => 'Fecha de creación';
	@override String get modify_date => 'Última modificación';
	@override String get last_backup => 'Última copia de seguridad';
	@override String get size => 'Tamaño';
}

// Path: settings.security
class _TranslationsSettingsSecurityEs implements _TranslationsSettingsSecurityEn {
	_TranslationsSettingsSecurityEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Seguridad';
	@override String get private_mode_at_launch => 'Modo privado al arrancar';
	@override String get private_mode_at_launch_descr => 'Arranca la app en modo privado por defecto';
	@override String get private_mode => 'Modo privado';
	@override String get private_mode_descr => 'Oculta todos los valores monetarios';
	@override String get private_mode_activated => 'Modo privado activado';
	@override String get private_mode_deactivated => 'Modo privado desactivado';
}

// Path: more.data
class _TranslationsMoreDataEs implements _TranslationsMoreDataEn {
	_TranslationsMoreDataEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Datos';
	@override String get display_descr => 'Exporta y importa tus datos para no perder nada';
	@override String get delete_all => 'Eliminar mis datos';
	@override String get delete_all_header1 => 'Alto ahí padawan ⚠️⚠️';
	@override String get delete_all_message1 => '¿Estas seguro de que quieres continuar? Todos tus datos serán borrados permanentemente y no podrán ser recuperados';
	@override String get delete_all_header2 => 'Un último paso ⚠️⚠️';
	@override String get delete_all_message2 => 'Al eliminar una cuenta eliminarás todos tus datos personales almacenados. Tus cuentas, transacciones, presupuestos y categorías serán borrados y no podrán ser recuperados. ¿Estas de acuerdo?';
}

// Path: more.about_us
class _TranslationsMoreAboutUsEs implements _TranslationsMoreAboutUsEn {
	_TranslationsMoreAboutUsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Información de la app';
	@override String get description => 'Consulta los terminos y otra información relevante sobre Parsa. Ponte en contacto con la comunidad reportando errores, dejando sugerencias...';
	@override late final _TranslationsMoreAboutUsLegalEs legal = _TranslationsMoreAboutUsLegalEs._(_root);
	@override late final _TranslationsMoreAboutUsProjectEs project = _TranslationsMoreAboutUsProjectEs._(_root);
}

// Path: more.help_us
class _TranslationsMoreHelpUsEs implements _TranslationsMoreHelpUsEn {
	_TranslationsMoreHelpUsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Ayúdanos';
	@override String get description => 'Descubre de que formas puedes ayudar a que Parsa sea cada vez mejor';
	@override String get rate_us => 'Califícanos';
	@override String get rate_us_descr => '¡Cualquier valoración es bienvenida!';
	@override String get share => 'Comparte Parsa';
	@override String get share_descr => 'Comparte nuestra app a amigos y familiares';
	@override String get share_text => 'Parsa! La mejor app de finanzas personales. Descargala aquí';
	@override String get thanks => '¡Gracias!';
	@override String get thanks_long => 'Tus contribuciones a Parsa y otros proyectos de código abierto, grandes o pequeños, hacen posibles grandes proyectos como este. Gracias por tomarse el tiempo para contribuir.';
	@override String get donate => 'Haz una donación';
	@override String get donate_descr => 'Con tu donación ayudaras a que la app siga recibiendo mejoras. ¿Que mejor forma que agradecer el trabajo realizado invitandome a un cafe?';
	@override String get donate_success => 'Donación realizada. Muchas gracias por tu contribución! ❤️';
	@override String get donate_err => 'Ups! Parece que ha habido un error a la hora de recibir tu pago';
	@override String get report => 'Reporta errores, deja sugerencias...';
}

// Path: general.time.ranges
class _TranslationsGeneralTimeRangesEs implements _TranslationsGeneralTimeRangesEn {
	_TranslationsGeneralTimeRangesEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Rango temporal';
	@override String get it_repeat => 'Se repite';
	@override String get it_ends => 'Termina';
	@override late final _TranslationsGeneralTimeRangesTypesEs types = _TranslationsGeneralTimeRangesTypesEs._(_root);
	@override String each_range({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Cada ${range}',
		other: 'Cada ${n} ${range}',
	);
	@override String each_range_until_date({required num n, required Object range, required Object day}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Cada ${range} hasta el ${day}',
		other: 'Cada ${n} ${range} hasta el ${day}',
	);
	@override String each_range_until_times({required num n, required Object range, required Object limit}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Cada ${range} ${limit} veces',
		other: 'Cada ${n} ${range} ${limit} veces',
	);
	@override String each_range_until_once({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Cada ${range} una vez',
		other: 'Cada ${n} ${range} una vez',
	);
	@override String get forever => 'Para siempre';
	@override String month({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Mes',
		other: 'Meses',
	);
	@override String year({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Año',
		other: 'Años',
	);
	@override String day({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Día',
		other: 'Días',
	);
	@override String week({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Semana',
		other: 'Semanas',
	);
}

// Path: general.time.periodicity
class _TranslationsGeneralTimePeriodicityEs implements _TranslationsGeneralTimePeriodicityEn {
	_TranslationsGeneralTimePeriodicityEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Periodicidad';
	@override String get no_repeat => 'Sin repetición';
	@override String repeat({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'Repetición',
		other: 'Repeticiones',
	);
	@override String get diary => 'Diaría';
	@override String get monthly => 'Mensual';
	@override String get annually => 'Anual';
	@override String get quaterly => 'Trimestral';
	@override String get weekly => 'Semanal';
	@override String get custom => 'Personalizado';
	@override String get infinite => 'Siempre';
}

// Path: general.time.current
class _TranslationsGeneralTimeCurrentEs implements _TranslationsGeneralTimeCurrentEn {
	_TranslationsGeneralTimeCurrentEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get diary => 'Este día';
	@override String get monthly => 'Este mes';
	@override String get annually => 'Este año';
	@override String get quaterly => 'Este trimestre';
	@override String get weekly => 'Esta semana';
	@override String get infinite => 'Desde siempre';
	@override String get custom => 'Rango personalizado';
}

// Path: general.time.all
class _TranslationsGeneralTimeAllEs implements _TranslationsGeneralTimeAllEn {
	_TranslationsGeneralTimeAllEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get diary => 'Todos los días';
	@override String get monthly => 'Todos los meses';
	@override String get annually => 'Todos los años';
	@override String get quaterly => 'Todos los trimestres';
	@override String get weekly => 'Todas las semanas';
}

// Path: financial_health.review.descr
class _TranslationsFinancialHealthReviewDescrEs implements _TranslationsFinancialHealthReviewDescrEn {
	_TranslationsFinancialHealthReviewDescrEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get insufficient_data => 'Parece que no tenemos gastos suficientes para calcular tu salud financiera. Añade unos pocos gastos e ingresos para que podamos ayudarte mas!';
	@override String get very_good => 'Enhorabuena! Tu salud financiera es formidable. Esperamos que sigas con tu buena racha y que continues aprendiendo con Parsa';
	@override String get good => 'Genial! Tu salud financiera es buena. Visita la pestaña de análisis para ver como ahorrar aun mas!';
	@override String get normal => 'Tu salud financiera se encuentra mas o menos en la media del resto de la población para este periodo';
	@override String get bad => 'Parece que tu situación financiera no es la mejor aun. Explora el resto de pestañas de análisis para conocer mas sobre tus finanzas';
	@override String get very_bad => 'Mmm, tu salud financera esta muy por debajo de lo que debería. Trata de ver donde esta el problema gracias a los distintos gráficos y estadisticas que te proporcionamos';
}

// Path: financial_health.savings_percentage.text
class _TranslationsFinancialHealthSavingsPercentageTextEs implements _TranslationsFinancialHealthSavingsPercentageTextEn {
	_TranslationsFinancialHealthSavingsPercentageTextEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String good({required Object value}) => 'Enhorabuena! Has conseguido ahorrar un <b>${value}%</b> de tus ingresos durante este periodo. Parece que ya eres todo un expert@, sigue asi!';
	@override String normal({required Object value}) => 'Enhorabuena, has conseguido ahorrar un <b>${value}%</b> de tus ingresos durante este periodo.';
	@override String bad({required Object value}) => 'Has conseguido ahorrar un <b>${value}%</b> de tus ingresos durante este periodo. Sin embargo, creemos que aun puedes hacer mucho mas!';
	@override String get very_bad => 'Vaya, no has conseguido ahorrar nada durante este periodo.';
}

// Path: transaction.list.bulk_edit
class _TranslationsTransactionListBulkEditEs implements _TranslationsTransactionListBulkEditEn {
	_TranslationsTransactionListBulkEditEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get dates => 'Editar fechas';
	@override String get categories => 'Editar categorías';
	@override String get status => 'Editar estados';
}

// Path: transaction.form.validators
class _TranslationsTransactionFormValidatorsEs implements _TranslationsTransactionFormValidatorsEn {
	_TranslationsTransactionFormValidatorsEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get zero => 'El valor de una transacción no puede ser igual a cero';
	@override String get date_max => 'La fecha seleccionada es posterior a la actual. Se añadirá la transacción como pendiente';
	@override String get date_after_account_creation => 'No puedes crear una transacción cuya fecha es anterior a la fecha de creación de la cuenta a la que pertenece';
	@override String get negative_transfer => 'El valor monetario de una transferencia no puede ser negativo';
	@override String get transfer_between_same_accounts => 'Las cuentas de origen y destino no pueden coincidir';
}

// Path: transfer.form.value_in_destiny
class _TranslationsTransferFormValueInDestinyEs implements _TranslationsTransferFormValueInDestinyEn {
	_TranslationsTransferFormValueInDestinyEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cantidad transferida en destino';
	@override String amount_short({required Object amount}) => '${amount} a cuenta de destino';
}

// Path: backup.import.manual_import
class _TranslationsBackupImportManualImportEs implements _TranslationsBackupImportManualImportEn {
	_TranslationsBackupImportManualImportEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Importación manual';
	@override String get descr => 'Importa transacciones desde un fichero .csv de forma manual';
	@override String get default_account => 'Cuenta por defecto';
	@override String get remove_default_account => 'Eliminar cuenta por defecto';
	@override String get default_category => 'Categoría por defecto';
	@override String get select_a_column => 'Selecciona una columna del .csv';
	@override String success({required Object x}) => 'Se han importado correctamente ${x} transacciones';
	@override List<String> get steps => [
		'Selecciona tu fichero',
		'Columna para la cantidad',
		'Columna para la cuenta',
		'Columna para la categoría',
		'Columna para la fecha',
		'Otras columnas',
	];
	@override List<String> get steps_descr => [
		'Selecciona un fichero .csv de tu dispositivo. Asegurate de que este tenga una primera fila que describa el nombre de cada columna',
		'Selecciona la columna donde se especifica el valor de cada transacción. Usa valores negativos para los gastos y positivos para los ingresos. Usa un punto como separador decimal',
		'Selecciona la columna donde se especifica la cuenta a la que pertenece cada transacción. Podrás también seleccionar una cuenta por defecto en el caso de que no encontremos la cuenta que desea. Si no se especifica una cuenta por defecto, crearemos una con el mismo nombre',
		'Especifica la columna donde se encuentra el nombre de la categoría de la transacción. Debes especificar una categoría por defecto para que asignemos esta categoría a las transacciones, en caso de que la categoría no se pueda encontrar',
		'Selecciona la columna donde se especifica la fecha de cada transacción. En caso de no especificarse, se crearan transacciones con la fecha actual',
		'Especifica las columnas para otros atributos optativos de las transacciones',
	];
}

// Path: more.about_us.legal
class _TranslationsMoreAboutUsLegalEs implements _TranslationsMoreAboutUsLegalEn {
	_TranslationsMoreAboutUsLegalEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Información legal';
	@override String get privacy => 'Política de privacidad';
	@override String get terms => 'Términos de uso';
	@override String get licenses => 'Licencias';
}

// Path: more.about_us.project
class _TranslationsMoreAboutUsProjectEs implements _TranslationsMoreAboutUsProjectEn {
	_TranslationsMoreAboutUsProjectEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get display => 'Proyecto';
	@override String get contributors => 'Colaboradores';
	@override String get contributors_descr => 'Todos los desarrolladores que han hecho que Parsa crezca';
	@override String get contact => 'Contacta con nosotros';
}

// Path: general.time.ranges.types
class _TranslationsGeneralTimeRangesTypesEs implements _TranslationsGeneralTimeRangesTypesEn {
	_TranslationsGeneralTimeRangesTypesEs._(this._root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get cycle => 'Ciclos';
	@override String get last_days => 'Últimos días';
	@override String last_days_form({required Object x}) => '${x} días anteriores';
	@override String get all => 'Siempre';
	@override String get date_range => 'Rango personalizado';
}

// Path: <root>
class _TranslationsPt implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsPt.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
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
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _TranslationsPt _root = this; // ignore: unused_field

	// Translations
	@override late final _TranslationsGeneralPt general = _TranslationsGeneralPt._(_root);
	@override late final _TranslationsIntroPt intro = _TranslationsIntroPt._(_root);
	@override late final _TranslationsHomePt home = _TranslationsHomePt._(_root);
	@override late final _TranslationsFinancialHealthPt financial_health = _TranslationsFinancialHealthPt._(_root);
	@override late final _TranslationsStatsPt stats = _TranslationsStatsPt._(_root);
	@override late final _TranslationsIconSelectorPt icon_selector = _TranslationsIconSelectorPt._(_root);
	@override late final _TranslationsTransactionPt transaction = _TranslationsTransactionPt._(_root);
	@override late final _TranslationsTransferPt transfer = _TranslationsTransferPt._(_root);
	@override late final _TranslationsRecurrentTransactionsPt recurrent_transactions = _TranslationsRecurrentTransactionsPt._(_root);
	@override late final _TranslationsAccountPt account = _TranslationsAccountPt._(_root);
	@override late final _TranslationsCurrenciesPt currencies = _TranslationsCurrenciesPt._(_root);
	@override late final _TranslationsTagsPt tags = _TranslationsTagsPt._(_root);
	@override late final _TranslationsCategoriesPt categories = _TranslationsCategoriesPt._(_root);
	@override late final _TranslationsBudgetsPt budgets = _TranslationsBudgetsPt._(_root);
	@override late final _TranslationsBackupPt backup = _TranslationsBackupPt._(_root);
	@override late final _TranslationsSettingsPt settings = _TranslationsSettingsPt._(_root);
	@override late final _TranslationsMorePt more = _TranslationsMorePt._(_root);
}

// Path: general
class _TranslationsGeneralPt implements _TranslationsGeneralEn {
	_TranslationsGeneralPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Cancelar';
	@override String get or => 'ou';
	@override String get understood => 'Entendido';
	@override String get unspecified => 'Não especificado';
	@override String get confirm => 'Confirmar';
	@override String get continue_text => 'Continuar';
	@override String get quick_actions => 'Ações rápidas';
	@override String get save => 'Salvar';
	@override String get save_changes => 'Salvar alterações';
	@override String get close_and_save => 'Salvar e fechar';
	@override String get add => 'Adicionar';
	@override String get edit => 'Editar';
	@override String get balance => 'Saldo';
	@override String get delete => 'Excluir';
	@override String get account => 'Conta';
	@override String get accounts => 'Contas';
	@override String get categories => 'Categorias';
	@override String get category => 'Categoria';
	@override String get today => 'Hoje';
	@override String get yesterday => 'Ontem';
	@override String get filters => 'Filtros';
	@override String get select_all => 'Selecionar tudo';
	@override String get deselect_all => 'Desmarcar tudo';
	@override String get empty_warn => 'Ops! Isso está muito vazio';
	@override String get insufficient_data => 'Dados insuficientes';
	@override String get show_more_fields => 'Mostrar mais campos';
	@override String get show_less_fields => 'Mostrar menos campos';
	@override String get tap_to_search => 'Toque para pesquisar';
	@override late final _TranslationsGeneralClipboardPt clipboard = _TranslationsGeneralClipboardPt._(_root);
	@override late final _TranslationsGeneralTimePt time = _TranslationsGeneralTimePt._(_root);
	@override late final _TranslationsGeneralTransactionOrderPt transaction_order = _TranslationsGeneralTransactionOrderPt._(_root);
	@override late final _TranslationsGeneralValidationsPt validations = _TranslationsGeneralValidationsPt._(_root);
}

// Path: intro
class _TranslationsIntroPt implements _TranslationsIntroEn {
	_TranslationsIntroPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get start => 'Começar';
	@override String get skip => 'Pular';
	@override String get next => 'Próximo';
	@override String get select_your_currency => 'Selecione sua moeda';
	@override String get welcome_subtitle => 'Seu gerente financeiro pessoal';
	@override String get welcome_subtitle2 => '100% aberto, 100% grátis';
	@override String get welcome_footer => 'Ao entrar, você concorda com a <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/PRIVACY_POLICY.md\'>Política de Privacidade</a> e os <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/TERMS_OF_USE.md\'>Termos de Uso</a> do aplicativo';
	@override String get offline_descr_title => 'CONTA OFFLINE:';
	@override String get offline_descr => 'Seus dados serão armazenados apenas no seu dispositivo e estarão seguros enquanto você não desinstalar o aplicativo ou trocar de telefone. Para evitar a perda de dados, é recomendável fazer backup regularmente nas configurações do aplicativo.';
	@override String get offline_start => 'Iniciar sessão offline';
	@override String get sl1_title => 'Selecione sua moeda';
	@override String get sl1_descr => 'Sua moeda padrão será usada em relatórios e gráficos gerais. Você poderá alterar a moeda e o idioma do aplicativo mais tarde a qualquer momento nas configurações do aplicativo';
	@override String get sl2_title => 'Seguro, privado e confiável';
	@override String get sl2_descr => 'Seus dados são apenas seus. Armazenamos as informações diretamente no seu dispositivo, sem passar por servidores externos. Isso possibilita o uso do aplicativo mesmo sem internet';
	@override String get sl2_descr2 => 'Além disso, o código-fonte do aplicativo é público, qualquer pessoa pode colaborar e ver como ele funciona';
	@override String get last_slide_title => 'Tudo pronto';
	@override String get last_slide_descr => 'Com o Parsa, você finalmente pode alcançar a independência financeira que tanto deseja. Você terá gráficos, orçamentos, dicas, insights e muito mais sobre seu dinheiro.';
	@override String get last_slide_descr2 => 'Esperamos que aproveite sua experiência! Não hesite em nos contatar em caso de dúvidas, sugestões...';
}

// Path: home
class _TranslationsHomePt implements _TranslationsHomeEn {
	_TranslationsHomePt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Início';
	@override String get filter_transactions => 'Filtrar transações';
	@override String get hello_day => 'Bom dia,';
	@override String get hello_night => 'Boa noite,';
	@override String get total_balance => 'Saldo total';
	@override String get my_accounts => 'Minhas contas';
	@override String get active_accounts => 'Contas ativas';
	@override String get no_accounts => 'Nenhuma conta criada ainda';
	@override String get no_accounts_descr => 'Comece a usar toda a magia do Parsa. Crie pelo menos uma conta para começar a adicionar transações';
	@override String get last_transactions => 'Últimas transações';
	@override String get should_create_account_header => 'Ops!';
	@override String get should_create_account_message => 'Você deve ter pelo menos uma conta não arquivada antes de começar a criar transações';
}

// Path: financial_health
class _TranslationsFinancialHealthPt implements _TranslationsFinancialHealthEn {
	_TranslationsFinancialHealthPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Saúde financeira';
	@override late final _TranslationsFinancialHealthReviewPt review = _TranslationsFinancialHealthReviewPt._(_root);
	@override late final _TranslationsFinancialHealthMonthsWithoutIncomePt months_without_income = _TranslationsFinancialHealthMonthsWithoutIncomePt._(_root);
	@override late final _TranslationsFinancialHealthSavingsPercentagePt savings_percentage = _TranslationsFinancialHealthSavingsPercentagePt._(_root);
}

// Path: stats
class _TranslationsStatsPt implements _TranslationsStatsEn {
	_TranslationsStatsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Insights';
	@override String get balance => 'Saldo';
	@override String get final_balance => 'Saldo final';
	@override String get balance_by_account => 'Saldo por contas';
	@override String get balance_by_currency => 'Saldo por moeda';
	@override String get cash_flow => 'Fluxo de caixa';
	@override String get balance_evolution => 'Evolução do saldo';
	@override String get compared_to_previous_period => 'Comparado ao período anterior';
	@override String get by_periods => 'Por períodos';
	@override String get by_categories => 'Por categorias';
	@override String get by_tags => 'Por tags';
	@override String get distribution => 'Distribuição';
	@override String get finance_health_resume => 'Resumo';
	@override String get finance_health_breakdown => 'Detalhamento';
}

// Path: icon_selector
class _TranslationsIconSelectorPt implements _TranslationsIconSelectorEn {
	_TranslationsIconSelectorPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nome:';
	@override String get icon => 'Ícone';
	@override String get color => 'Cor';
	@override String get select_icon => 'Selecione um ícone';
	@override String get select_color => 'Selecione uma cor';
	@override String get select_account_icon => 'Identifique sua conta';
	@override String get select_category_icon => 'Identifique sua categoria';
	@override late final _TranslationsIconSelectorScopesPt scopes = _TranslationsIconSelectorScopesPt._(_root);
}

// Path: transaction
class _TranslationsTransactionPt implements _TranslationsTransactionEn {
	_TranslationsTransactionPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Transações',
		other: 'Transações',
	);
	@override String get create => 'Nova transação';
	@override String get new_income => 'Nova receita';
	@override String get new_expense => 'Nova despesa';
	@override String get new_success => 'Transação criada com sucesso';
	@override String get edit => 'Editar transação';
	@override String get edit_success => 'Transação editada com sucesso';
	@override String get edit_multiple => 'Editar transações';
	@override String edit_multiple_success({required Object x}) => '${x} transações editadas com sucesso';
	@override String get duplicate => 'Clonar transação';
	@override String get duplicate_short => 'Clonar';
	@override String get duplicate_warning_message => 'Uma transação idêntica a esta será criada com a mesma data, deseja continuar?';
	@override String get duplicate_success => 'Transação clonada com sucesso';
	@override String get delete => 'Excluir transação';
	@override String get delete_warning_message => 'Essa ação é irreversível. O saldo atual de suas contas e todas as suas Parsaísticas serão recalculados';
	@override String get delete_success => 'Transação excluída corretamente';
	@override String get delete_multiple => 'Excluir transações';
	@override String delete_multiple_warning_message({required Object x}) => 'Essa ação é irreversível e removerá ${x} transações. O saldo atual de suas contas e todas as suas Parsaísticas serão recalculados';
	@override String delete_multiple_success({required Object x}) => '${x} transações excluídas corretamente';
	@override String get details => 'Detalhes do movimento';
	@override late final _TranslationsTransactionNextPaymentsPt next_payments = _TranslationsTransactionNextPaymentsPt._(_root);
	@override late final _TranslationsTransactionListPt list = _TranslationsTransactionListPt._(_root);
	@override late final _TranslationsTransactionFiltersPt filters = _TranslationsTransactionFiltersPt._(_root);
	@override late final _TranslationsTransactionFormPt form = _TranslationsTransactionFormPt._(_root);
	@override late final _TranslationsTransactionReversedPt reversed = _TranslationsTransactionReversedPt._(_root);
	@override late final _TranslationsTransactionStatusPt status = _TranslationsTransactionStatusPt._(_root);
	@override late final _TranslationsTransactionTypesPt types = _TranslationsTransactionTypesPt._(_root);
}

// Path: transfer
class _TranslationsTransferPt implements _TranslationsTransferEn {
	_TranslationsTransferPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Transferência';
	@override String get transfers => 'Transferências';
	@override String transfer_to({required Object account}) => 'Transferir para ${account}';
	@override String get create => 'Nova Transferência';
	@override String get need_two_accounts_warning_header => 'Ops!';
	@override String get need_two_accounts_warning_message => 'São necessárias pelo menos duas contas para realizar esta ação. Se precisar ajustar ou editar o saldo atual desta conta, clique no botão de edição';
	@override late final _TranslationsTransferFormPt form = _TranslationsTransferFormPt._(_root);
}

// Path: recurrent_transactions
class _TranslationsRecurrentTransactionsPt implements _TranslationsRecurrentTransactionsEn {
	_TranslationsRecurrentTransactionsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transações recorrentes';
	@override String get title_short => 'Trans. recorrentes';
	@override String get empty => 'Parece que você não tem nenhuma transação recorrente. Crie uma transação recorrente mensal, anual ou semanal e ela aparecerá aqui';
	@override String get total_expense_title => 'Despesa total por período';
	@override String get total_expense_descr => '* Sem considerar a data de início e término de cada recorrência';
	@override late final _TranslationsRecurrentTransactionsDetailsPt details = _TranslationsRecurrentTransactionsDetailsPt._(_root);
}

// Path: account
class _TranslationsAccountPt implements _TranslationsAccountEn {
	_TranslationsAccountPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get details => 'Detalhes da conta';
	@override String get date => 'Data de abertura';
	@override String get close_date => 'Data de fechamento';
	@override String get reopen => 'Reabrir conta';
	@override String get reopen_short => 'Reabrir';
	@override String get reopen_descr => 'Tem certeza de que deseja reabrir esta conta?';
	@override String get balance => 'Saldo da conta';
	@override String get n_transactions => 'Número de transações';
	@override String get add_money => 'Adicionar dinheiro';
	@override String get withdraw_money => 'Retirar dinheiro';
	@override String get no_accounts => 'Nenhuma transação encontrada para exibir aqui. Adicione uma transação clicando no botão \'+\' na parte inferior';
	@override late final _TranslationsAccountTypesPt types = _TranslationsAccountTypesPt._(_root);
	@override late final _TranslationsAccountFormPt form = _TranslationsAccountFormPt._(_root);
	@override late final _TranslationsAccountDeletePt delete = _TranslationsAccountDeletePt._(_root);
	@override late final _TranslationsAccountClosePt close = _TranslationsAccountClosePt._(_root);
	@override late final _TranslationsAccountSelectPt select = _TranslationsAccountSelectPt._(_root);
}

// Path: currencies
class _TranslationsCurrenciesPt implements _TranslationsCurrenciesEn {
	_TranslationsCurrenciesPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get currency_converter => 'Conversor de moedas';
	@override String get currency => 'Moeda';
	@override String get currency_manager => 'Gerenciador de moedas';
	@override String get currency_manager_descr => 'Configure sua moeda e suas taxas de câmbio com outras';
	@override String get preferred_currency => 'Moeda preferida/base';
	@override String get change_preferred_currency_title => 'Alterar moeda preferida';
	@override String get change_preferred_currency_msg => 'Todas as insights e orçamentos serão exibidos nesta moeda a partir de agora. Contas e transações manterão a moeda que possuíam. Todas as taxas de câmbio salvas serão excluídas se você executar esta ação. Deseja continuar?';
	@override late final _TranslationsCurrenciesFormPt form = _TranslationsCurrenciesFormPt._(_root);
	@override String get delete_all_success => 'Taxas de câmbio excluídas com sucesso';
	@override String get historical => 'Taxas históricas';
	@override String get exchange_rate => 'Taxa de câmbio';
	@override String get exchange_rates => 'Taxas de câmbio';
	@override String get empty => 'Adicione taxas de câmbio aqui para que se você tiver contas em moedas diferentes da sua moeda base, nossos gráficos sejam mais precisos';
	@override String get select_a_currency => 'Selecione uma moeda';
	@override String get search => 'Pesquise por nome ou código da moeda';
}

// Path: tags
class _TranslationsTagsPt implements _TranslationsTagsEn {
	_TranslationsTagsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Etiqueta',
		other: 'Etiquetas',
	);
	@override late final _TranslationsTagsFormPt form = _TranslationsTagsFormPt._(_root);
	@override String get empty_list => 'Você ainda não criou nenhuma etiqueta. Etiquetas e categorias são uma ótima maneira de categorizar seus movimentos';
	@override String get without_tags => 'Sem etiquetas';
	@override String get select => 'Selecionar etiquetas';
	@override String get add => 'Adicionar etiqueta';
	@override String get create => 'Criar etiqueta';
	@override String get create_success => 'Etiqueta criada com sucesso';
	@override String get already_exists => 'Este nome de etiqueta já existe. Talvez você queira editá-lo';
	@override String get edit => 'Editar etiqueta';
	@override String get edit_success => 'Etiqueta editada com sucesso';
	@override String get delete_success => 'Etiqueta excluída com sucesso';
	@override String get delete_warning_header => 'Excluir etiqueta?';
	@override String get delete_warning_message => 'Essa ação não excluirá as transações que possuem essa etiqueta.';
}

// Path: categories
class _TranslationsCategoriesPt implements _TranslationsCategoriesEn {
	_TranslationsCategoriesPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get unknown => 'Categoria desconhecida';
	@override String get create => 'Criar categoria';
	@override String get create_success => 'Categoria criada corretamente';
	@override String get new_category => 'Nova categoria';
	@override String get already_exists => 'O nome desta categoria já existe. Talvez você queira editá-la';
	@override String get edit => 'Editar categoria';
	@override String get edit_success => 'Categoria editada corretamente';
	@override String get name => 'Nome da categoria';
	@override String get type => 'Tipo de categoria';
	@override String get both_types => 'Ambos os tipos';
	@override String get subcategories => 'Subcategorias';
	@override String get subcategories_add => 'Adicionar subcategoria';
	@override String get make_parent => 'Tornar categoria';
	@override String get make_child => 'Tornar subcategoria';
	@override String make_child_warning1({required Object destiny}) => 'Esta categoria e suas subcategorias se tornarão subcategorias de <b>${destiny}</b>.';
	@override String make_child_warning2({required Object x, required Object destiny}) => 'Suas transações <b>(${x})</b> serão movidas para as novas subcategorias criadas dentro da categoria <b>${destiny}</b>.';
	@override String get make_child_success => 'Subcategorias criadas com sucesso';
	@override String get merge => 'Mesclar com outra categoria';
	@override String merge_warning1({required Object x, required Object from, required Object destiny}) => 'Todas as transações (${x}) associadas à categoria <b>${from}</b> serão movidas para a categoria <b>${destiny}</b>';
	@override String merge_warning2({required Object from}) => 'A categoria <b>${from}</b> será excluída de forma irreversível.';
	@override String get merge_success => 'Categoria mesclada com sucesso';
	@override String get delete_success => 'Categoria excluída corretamente';
	@override String get delete_warning_header => 'Excluir categoria?';
	@override String delete_warning_message({required Object x}) => 'Essa ação excluirá de forma irreversível todas as transações <b>(${x})</b> relacionadas a esta categoria.';
	@override late final _TranslationsCategoriesSelectPt select = _TranslationsCategoriesSelectPt._(_root);
}

// Path: budgets
class _TranslationsBudgetsPt implements _TranslationsBudgetsEn {
	_TranslationsBudgetsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Orçamentos';
	@override String get repeated => 'Recorrente';
	@override String get one_time => 'Único';
	@override String get annual => 'Anuais';
	@override String get week => 'Semanal';
	@override String get month => 'Mensal';
	@override String get actives => 'Ativos';
	@override String get pending => 'Aguardando início';
	@override String get finish => 'Finalizado';
	@override String get from_budgeted => 'restante de ';
	@override String get days_left => 'dias restantes';
	@override String get days_to_start => 'dias para começar';
	@override String get since_expiration => 'dias desde a expiração';
	@override String get no_budgets => 'Parece não haver orçamentos para exibir nesta seção. Comece criando um orçamento clicando no botão abaixo';
	@override String get delete => 'Excluir orçamento';
	@override String get delete_warning => 'Essa ação é irreversível. Categorias e transações referentes a esta cota não serão excluídas';
	@override late final _TranslationsBudgetsFormPt form = _TranslationsBudgetsFormPt._(_root);
	@override late final _TranslationsBudgetsDetailsPt details = _TranslationsBudgetsDetailsPt._(_root);
}

// Path: backup
class _TranslationsBackupPt implements _TranslationsBackupEn {
	_TranslationsBackupPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsBackupExportPt export = _TranslationsBackupExportPt._(_root);
	@override late final _TranslationsBackupImportPt import = _TranslationsBackupImportPt._(_root);
	@override late final _TranslationsBackupAboutPt about = _TranslationsBackupAboutPt._(_root);
}

// Path: settings
class _TranslationsSettingsPt implements _TranslationsSettingsEn {
	_TranslationsSettingsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title_long => 'Configurações e aparência';
	@override String get title_short => 'Configurações';
	@override String get description => 'Tema do aplicativo, textos e outras configurações gerais';
	@override String get edit_profile => 'Editar perfil';
	@override String get lang_section => 'Idioma e textos';
	@override String get lang_title => 'Idioma do aplicativo';
	@override String get lang_descr => 'Idioma em que os textos serão exibidos no aplicativo';
	@override String get locale => 'Região';
	@override String get locale_descr => 'Defina o formato a ser usado para datas, números...';
	@override String get locale_warn => 'Ao mudar de região, o aplicativo será atualizado';
	@override String get first_day_of_week => 'Primeiro dia da semana';
	@override String get theme_and_colors => 'Tema e cores';
	@override String get theme => 'Tema';
	@override String get theme_auto => 'Definido pelo sistema';
	@override String get theme_light => 'Claro';
	@override String get theme_dark => 'Escuro';
	@override String get amoled_mode => 'Modo AMOLED';
	@override String get amoled_mode_descr => 'Use um papel de parede preto puro sempre que possível. Isso ajudará um pouco na bateria de dispositivos com telas AMOLED';
	@override String get dynamic_colors => 'Cores dinâmicas';
	@override String get dynamic_colors_descr => 'Use a cor de destaque do sistema sempre que possível';
	@override String get accent_color => 'Cor de destaque';
	@override String get accent_color_descr => 'Escolha a cor que o aplicativo usará para destacar certas partes da interface';
	@override late final _TranslationsSettingsSecurityPt security = _TranslationsSettingsSecurityPt._(_root);
}

// Path: more
class _TranslationsMorePt implements _TranslationsMoreEn {
	_TranslationsMorePt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mais';
	@override String get title_long => 'Mais ações';
	@override late final _TranslationsMoreDataPt data = _TranslationsMoreDataPt._(_root);
	@override late final _TranslationsMoreAboutUsPt about_us = _TranslationsMoreAboutUsPt._(_root);
	@override late final _TranslationsMoreHelpUsPt help_us = _TranslationsMoreHelpUsPt._(_root);
}

// Path: general.clipboard
class _TranslationsGeneralClipboardPt implements _TranslationsGeneralClipboardEn {
	_TranslationsGeneralClipboardPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String success({required Object x}) => '${x} copiado para a área de transferência';
	@override String get error => 'Erro ao copiar';
}

// Path: general.time
class _TranslationsGeneralTimePt implements _TranslationsGeneralTimeEn {
	_TranslationsGeneralTimePt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get start_date => 'Data de início';
	@override String get end_date => 'Data de término';
	@override String get from_date => 'A partir da data';
	@override String get until_date => 'Até a data';
	@override String get date => 'Data';
	@override String get datetime => 'Data e hora';
	@override String get time => 'Hora';
	@override String get each => 'Cada';
	@override String get after => 'Após';
	@override late final _TranslationsGeneralTimeRangesPt ranges = _TranslationsGeneralTimeRangesPt._(_root);
	@override late final _TranslationsGeneralTimePeriodicityPt periodicity = _TranslationsGeneralTimePeriodicityPt._(_root);
	@override late final _TranslationsGeneralTimeCurrentPt current = _TranslationsGeneralTimeCurrentPt._(_root);
	@override late final _TranslationsGeneralTimeAllPt all = _TranslationsGeneralTimeAllPt._(_root);
}

// Path: general.transaction_order
class _TranslationsGeneralTransactionOrderPt implements _TranslationsGeneralTransactionOrderEn {
	_TranslationsGeneralTransactionOrderPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Ordenar transações';
	@override String get category => 'Por categoria';
	@override String get quantity => 'Por quantidade';
	@override String get date => 'Por data';
}

// Path: general.validations
class _TranslationsGeneralValidationsPt implements _TranslationsGeneralValidationsEn {
	_TranslationsGeneralValidationsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get required => 'Campo obrigatório';
	@override String get positive => 'Deve ser positivo';
	@override String min_number({required Object x}) => 'Deve ser maior que ${x}';
	@override String max_number({required Object x}) => 'Deve ser menor que ${x}';
}

// Path: financial_health.review
class _TranslationsFinancialHealthReviewPt implements _TranslationsFinancialHealthReviewEn {
	_TranslationsFinancialHealthReviewPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String very_good({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Muito bom!';
			case GenderContext.female:
				return 'Muito bom!';
		}
	}
	@override String good({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Bom';
			case GenderContext.female:
				return 'Bom';
		}
	}
	@override String normal({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Razoável';
			case GenderContext.female:
				return 'Razoável';
		}
	}
	@override String bad({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Ruim';
			case GenderContext.female:
				return 'Ruim';
		}
	}
	@override String very_bad({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Muito ruim';
			case GenderContext.female:
				return 'Muito ruim';
		}
	}
	@override String insufficient_data({required GenderContext context}) {
		switch (context) {
			case GenderContext.male:
				return 'Dados insuficientes';
			case GenderContext.female:
				return 'Dados insuficientes';
		}
	}
	@override late final _TranslationsFinancialHealthReviewDescrPt descr = _TranslationsFinancialHealthReviewDescrPt._(_root);
}

// Path: financial_health.months_without_income
class _TranslationsFinancialHealthMonthsWithoutIncomePt implements _TranslationsFinancialHealthMonthsWithoutIncomeEn {
	_TranslationsFinancialHealthMonthsWithoutIncomePt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Taxa de sobrevivência';
	@override String get subtitle => 'Dado seu saldo, tempo que você poderia viver sem renda';
	@override String get text_zero => 'Você não conseguiria sobreviver um mês sem renda neste ritmo de despesas!';
	@override String get text_one => 'Você mal conseguiria sobreviver aproximadamente um mês sem renda neste ritmo de despesas!';
	@override String text_other({required Object n}) => 'Você conseguiria sobreviver aproximadamente <b>${n} meses</b> sem renda neste ritmo de despesas.';
	@override String get text_infinite => 'Você conseguiria sobreviver aproximadamente <b>toda a vida</b> sem renda neste ritmo de despesas.';
	@override String get suggestion => 'Lembre-se de que é aconselhável sempre manter essa proporção acima de 5 meses, pelo menos. Se você perceber que não tem uma reserva de emergência suficiente, reduza as despesas desnecessárias.';
	@override String get insufficient_data => 'Parece que não temos despesas suficientes para calcular quantos meses você poderia sobreviver sem renda. Insira algumas transações e volte aqui para verificar sua saúde financeira';
}

// Path: financial_health.savings_percentage
class _TranslationsFinancialHealthSavingsPercentagePt implements _TranslationsFinancialHealthSavingsPercentageEn {
	_TranslationsFinancialHealthSavingsPercentagePt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Porcentagem de economia';
	@override String get subtitle => 'Qual parte da sua renda não foi gasta neste período';
	@override late final _TranslationsFinancialHealthSavingsPercentageTextPt text = _TranslationsFinancialHealthSavingsPercentageTextPt._(_root);
	@override String get suggestion => 'Lembre-se de que é aconselhável economizar pelo menos 15-20% do que você ganha.';
}

// Path: icon_selector.scopes
class _TranslationsIconSelectorScopesPt implements _TranslationsIconSelectorScopesEn {
	_TranslationsIconSelectorScopesPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get transport => 'Transporte';
	@override String get money => 'Dinheiro';
	@override String get food => 'Alimentação';
	@override String get medical => 'Saúde';
	@override String get entertainment => 'Lazer';
	@override String get technology => 'Tecnologia';
	@override String get other => 'Outros';
	@override String get logos_financial_institutions => 'Instituições financeiras';
}

// Path: transaction.next_payments
class _TranslationsTransactionNextPaymentsPt implements _TranslationsTransactionNextPaymentsEn {
	_TranslationsTransactionNextPaymentsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get accept => 'Aceitar';
	@override String get skip => 'Pular';
	@override String get skip_success => 'Transação pulada com sucesso';
	@override String get skip_dialog_title => 'Pular transação';
	@override String skip_dialog_msg({required Object date}) => 'Essa ação é irreversível. Vamos mover a data do próximo movimento para ${date}';
	@override String get accept_today => 'Aceitar hoje';
	@override String accept_in_required_date({required Object date}) => 'Aceitar na data requerida (${date})';
	@override String get accept_dialog_title => 'Aceitar transação';
	@override String get accept_dialog_msg_single => 'O novo status da transação será nulo. Você pode re-editar o status dessa transação sempre que quiser';
	@override String accept_dialog_msg({required Object date}) => 'Essa ação criará uma nova transação com data ${date}. Você poderá verificar os detalhes desta transação na página de transações';
	@override String get recurrent_rule_finished => 'A regra recorrente foi concluída, não há mais pagamentos a serem feitos!';
}

// Path: transaction.list
class _TranslationsTransactionListPt implements _TranslationsTransactionListEn {
	_TranslationsTransactionListPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Nenhuma transação encontrada para exibir aqui. Adicione uma transação clicando no botão \'+\' na parte inferior';
	@override String get searcher_placeholder => 'Pesquisar por categoria, descrição...';
	@override String get searcher_no_results => 'Nenhuma transação encontrada correspondente aos critérios de pesquisa';
	@override String get loading => 'Carregando mais transações...';
	@override String selected_short({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: '${n} selecionada',
		other: '${n} selecionadas',
	);
	@override String selected_long({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: '${n} transação selecionada',
		other: '${n} transações selecionadas',
	);
	@override late final _TranslationsTransactionListBulkEditPt bulk_edit = _TranslationsTransactionListBulkEditPt._(_root);
}

// Path: transaction.filters
class _TranslationsTransactionFiltersPt implements _TranslationsTransactionFiltersEn {
	_TranslationsTransactionFiltersPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get from_value => 'A partir do valor';
	@override String get to_value => 'Até o valor';
	@override String from_value_def({required Object x}) => 'A partir de ${x}';
	@override String to_value_def({required Object x}) => 'Até ${x}';
	@override String from_date_def({required Object date}) => 'A partir de ${date}';
	@override String to_date_def({required Object date}) => 'Até ${date}';
}

// Path: transaction.form
class _TranslationsTransactionFormPt implements _TranslationsTransactionFormEn {
	_TranslationsTransactionFormPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTransactionFormValidatorsPt validators = _TranslationsTransactionFormValidatorsPt._(_root);
	@override String get title => 'Título da transação';
	@override String get title_short => 'Título';
	@override String get value => 'Valor da transação';
	@override String get tap_to_see_more => 'Toque para ver mais detalhes';
	@override String get no_tags => '-- Sem tags --';
	@override String get description => 'Descrição';
	@override String get description_info => 'Toque aqui para inserir uma descrição mais detalhada sobre esta transação';
	@override String exchange_to_preferred_title({required Object currency}) => 'Taxa de câmbio para ${currency}';
	@override String get exchange_to_preferred_in_date => 'Na data da transação';
}

// Path: transaction.reversed
class _TranslationsTransactionReversedPt implements _TranslationsTransactionReversedEn {
	_TranslationsTransactionReversedPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transação inversa';
	@override String get title_short => 'Trans. inversa';
	@override String get description_for_expenses => 'Apesar de ser uma transação de despesa, ela tem um valor positivo. Esses tipos de transações podem ser usados para representar o retorno de uma despesa previamente registrada, como um reembolso ou o pagamento de uma dívida.';
	@override String get description_for_incomes => 'Apesar de ser uma transação de receita, ela tem um valor negativo. Esses tipos de transações podem ser usados para anular ou corrigir uma receita que foi registrada incorretamente, para refletir um retorno ou reembolso de dinheiro ou para registrar o pagamento de dívidas.';
}

// Path: transaction.status
class _TranslationsTransactionStatusPt implements _TranslationsTransactionStatusEn {
	_TranslationsTransactionStatusPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Status',
		other: 'Status',
	);
	@override String get display_long => 'Status da transação';
	@override String tr_status({required Object status}) => 'Transação ${status}';
	@override String get none => 'Sem status';
	@override String get none_descr => 'Transação sem status específico';
	@override String get reconciled => 'Conciliada';
	@override String get reconciled_descr => 'Esta transação já foi validada e corresponde a uma transação real do seu banco';
	@override String get unreconciled => 'Não conciliada';
	@override String get unreconciled_descr => 'Esta transação ainda não foi validada e, portanto, ainda não aparece em suas contas bancárias reais. No entanto, ela conta para o cálculo de saldos e insights no Parsa';
	@override String get pending => 'Pendente';
	@override String get pending_descr => 'Esta transação está pendente e, portanto, não será considerada no cálculo de saldos e insights';
	@override String get voided => 'Anulada';
	@override String get voided_descr => 'Transação anulada/cancelada devido a erro de pagamento ou qualquer outro motivo. Ela não será considerada no cálculo de saldos e insights';
}

// Path: transaction.types
class _TranslationsTransactionTypesPt implements _TranslationsTransactionTypesEn {
	_TranslationsTransactionTypesPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String display({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Tipo de transação',
		other: 'Tipos de transações',
	);
	@override String income({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Receitas',
		other: 'Receitas',
	);
	@override String expense({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Despesas',
		other: 'Despesas',
	);
	@override String transfer({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Transferência',
		other: 'Transferências',
	);
}

// Path: transfer.form
class _TranslationsTransferFormPt implements _TranslationsTransferFormEn {
	_TranslationsTransferFormPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get from => 'Conta de origem';
	@override String get to => 'Conta de destino';
	@override late final _TranslationsTransferFormValueInDestinyPt value_in_destiny = _TranslationsTransferFormValueInDestinyPt._(_root);
}

// Path: recurrent_transactions.details
class _TranslationsRecurrentTransactionsDetailsPt implements _TranslationsRecurrentTransactionsDetailsEn {
	_TranslationsRecurrentTransactionsDetailsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transação recorrente';
	@override String get descr => 'Os próximos movimentos para esta transação estão listados abaixo. Você pode aceitar o primeiro movimento ou pular este movimento';
	@override String get last_payment_info => 'Este movimento é o último da regra recorrente, então essa regra será automaticamente excluída ao confirmar esta ação';
	@override String get delete_header => 'Excluir transação recorrente';
	@override String get delete_message => 'Esta ação é irreversível e não afetará as transações que você já confirmou/pagou';
}

// Path: account.types
class _TranslationsAccountTypesPt implements _TranslationsAccountTypesEn {
	_TranslationsAccountTypesPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tipo de conta';
	@override String get warning => 'Uma vez escolhido o tipo de conta, ele não poderá ser alterado no futuro';
	@override String get normal => 'Conta corrente';
	@override String get normal_descr => 'Útil para registrar suas finanças do dia a dia. É a conta mais comum, permite adicionar despesas, receitas...';
	@override String get saving => 'Conta poupança';
	@override String get saving_descr => 'Você só poderá adicionar e retirar dinheiro dela a partir de outras contas. Perfeito para começar a economizar';
}

// Path: account.form
class _TranslationsAccountFormPt implements _TranslationsAccountFormEn {
	_TranslationsAccountFormPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nome da conta';
	@override String get name_placeholder => 'Ex: Conta poupança';
	@override String get notes => 'Notas';
	@override String get notes_placeholder => 'Digite algumas notas/descrição sobre esta conta';
	@override String get initial_balance => 'Saldo inicial';
	@override String get current_balance => 'Saldo atual';
	@override String get create => 'Criar conta';
	@override String get edit => 'Editar conta';
	@override String get currency_not_found_warn => 'Você não tem informações sobre taxas de câmbio para esta moeda. 1.0 será usado como a taxa de câmbio padrão. Você pode modificar isso nas configurações';
	@override String get already_exists => 'Já existe outra com o mesmo nome, por favor escreva outro';
	@override String get tr_before_opening_date => 'Existem transações nesta conta com uma data anterior à data de abertura';
	@override String get iban => 'Número de Conta';
	@override String get swift => 'Agencia';
}

// Path: account.delete
class _TranslationsAccountDeletePt implements _TranslationsAccountDeleteEn {
	_TranslationsAccountDeletePt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get warning_header => 'Excluir conta?';
	@override String get warning_text => 'Essa ação excluirá essa conta e todas as suas transações';
	@override String get success => 'Conta excluída com sucesso';
}

// Path: account.close
class _TranslationsAccountClosePt implements _TranslationsAccountCloseEn {
	_TranslationsAccountClosePt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Fechar conta';
	@override String get title_short => 'Fechar';
	@override String get warn => 'Esta conta não aparecerá mais em determinados listagens e você não poderá criar transações nela com uma data posterior à especificada abaixo. Esta ação não afeta nenhuma transação ou saldo, e você também pode reabrir esta conta a qualquer momento.';
	@override String get should_have_zero_balance => 'Você deve ter um saldo atual de 0 nesta conta para fechá-la. Por favor, edite a conta antes de continuar';
	@override String get should_have_no_transactions => 'Esta conta possui transações após a data de fechamento especificada. Exclua-as ou edite a data de fechamento da conta antes de continuar';
	@override String get success => 'Conta fechada com sucesso';
	@override String get unarchive_succes => 'Conta reaberta com sucesso';
}

// Path: account.select
class _TranslationsAccountSelectPt implements _TranslationsAccountSelectEn {
	_TranslationsAccountSelectPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get one => 'Selecione uma conta';
	@override String get all => 'Todas as contas';
	@override String get multiple => 'Selecionar contas';
}

// Path: currencies.form
class _TranslationsCurrenciesFormPt implements _TranslationsCurrenciesFormEn {
	_TranslationsCurrenciesFormPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get equal_to_preferred_warn => 'A moeda não pode ser igual à moeda do usuário';
	@override String get specify_a_currency => 'Por favor, especifique uma moeda';
	@override String get add => 'Adicionar taxa de câmbio';
	@override String get add_success => 'Taxa de câmbio adicionada com sucesso';
	@override String get edit => 'Editar taxa de câmbio';
	@override String get edit_success => 'Taxa de câmbio editada com sucesso';
}

// Path: tags.form
class _TranslationsTagsFormPt implements _TranslationsTagsFormEn {
	_TranslationsTagsFormPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nome da etiqueta';
	@override String get description => 'Descrição';
}

// Path: categories.select
class _TranslationsCategoriesSelectPt implements _TranslationsCategoriesSelectEn {
	_TranslationsCategoriesSelectPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Selecione categorias';
	@override String get select_one => 'Selecione uma categoria';
	@override String get select_subcategory => 'Escolha uma subcategoria';
	@override String get without_subcategory => 'Sem subcategoria';
	@override String get all => 'Todas as categorias';
	@override String get all_short => 'Todas';
}

// Path: budgets.form
class _TranslationsBudgetsFormPt implements _TranslationsBudgetsFormEn {
	_TranslationsBudgetsFormPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Adicionar um orçamento';
	@override String get name => 'Nome do orçamento';
	@override String get value => 'Quantidade limite';
	@override String get create => 'Adicionar orçamento';
	@override String get edit => 'Editar orçamento';
	@override String get negative_warn => 'Os orçamentos não podem ter um valor negativo';
}

// Path: budgets.details
class _TranslationsBudgetsDetailsPt implements _TranslationsBudgetsDetailsEn {
	_TranslationsBudgetsDetailsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Detalhes do orçamento';
	@override String get statistics => 'Insights';
	@override String get budget_value => 'Orçado';
	@override String expend_diary_left({required Object dailyAmount, required Object remainingDays}) => 'Você pode gastar ${dailyAmount}/dia pelos ${remainingDays} dias restantes';
	@override String get expend_evolution => 'Evolução dos gastos';
	@override String get no_transactions => 'Parece que você não fez nenhuma despesa relacionada a este orçamento';
}

// Path: backup.export
class _TranslationsBackupExportPt implements _TranslationsBackupExportEn {
	_TranslationsBackupExportPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Exportar seus dados';
	@override String get title_short => 'Exportar';
	@override String get all => 'Backup completo';
	@override String get all_descr => 'Exporte todos os seus dados (contas, transações, orçamentos, configurações...). Importe-os novamente a qualquer momento para não perder nada.';
	@override String get transactions => 'Backup de transações';
	@override String get transactions_descr => 'Exporte suas transações em CSV para que você possa analisá-las mais facilmente em outros programas ou aplicativos.';
	@override String get description => 'Baixe seus dados em diferentes formatos';
	@override String get dialog_title => 'Salvar/Enviar arquivo';
	@override String success({required Object x}) => 'Arquivo salvo/baixado com sucesso em ${x}';
	@override String get error => 'Erro ao baixar o arquivo. Entre em contato com o desenvolvedor via lozin.technologies@gmail.com';
}

// Path: backup.import
class _TranslationsBackupImportPt implements _TranslationsBackupImportEn {
	_TranslationsBackupImportPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Importar seus dados';
	@override String get title_short => 'Importar';
	@override String get restore_backup => 'Restaurar backup';
	@override String get restore_backup_descr => 'Importe um banco de dados salvo anteriormente do Parsa. Esta ação substituirá todos os dados atuais do aplicativo pelos novos dados';
	@override String get restore_backup_warn_description => 'Ao importar um novo banco de dados, você perderá todos os dados atualmente salvos no aplicativo. Recomenda-se fazer um backup antes de continuar. Não carregue aqui nenhum arquivo cuja origem você não conheça, carregue apenas arquivos que você tenha baixado anteriormente do Parsa';
	@override String get restore_backup_warn_title => 'Sobrescrever todos os dados';
	@override String get select_other_file => 'Selecionar outro arquivo';
	@override String get tap_to_select_file => 'Toque para selecionar um arquivo';
	@override late final _TranslationsBackupImportManualImportPt manual_import = _TranslationsBackupImportManualImportPt._(_root);
	@override String get success => 'Importação realizada com sucesso';
	@override String get cancelled => 'A importação foi cancelada pelo usuário';
	@override String get error => 'Erro ao importar arquivo. Entre em contato com o desenvolvedor via lozin.technologies@gmail.com';
}

// Path: backup.about
class _TranslationsBackupAboutPt implements _TranslationsBackupAboutEn {
	_TranslationsBackupAboutPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Informações sobre seu banco de dados';
	@override String get create_date => 'Data de criação';
	@override String get modify_date => 'Última modificação';
	@override String get last_backup => 'Último backup';
	@override String get size => 'Tamanho';
}

// Path: settings.security
class _TranslationsSettingsSecurityPt implements _TranslationsSettingsSecurityEn {
	_TranslationsSettingsSecurityPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Segurança';
	@override String get private_mode_at_launch => 'Modo privado ao iniciar';
	@override String get private_mode_at_launch_descr => 'Inicie o aplicativo no modo privado por padrão';
	@override String get private_mode => 'Modo privado';
	@override String get private_mode_descr => 'Oculte todos os valores monetários';
	@override String get private_mode_activated => 'Modo privado ativado';
	@override String get private_mode_deactivated => 'Modo privado desativado';
}

// Path: more.data
class _TranslationsMoreDataPt implements _TranslationsMoreDataEn {
	_TranslationsMoreDataPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Dados';
	@override String get display_descr => 'Exporte e importe seus dados para não perder nada';
	@override String get delete_all => 'Excluir meus dados';
	@override String get delete_all_header1 => 'Pare aí, padawan ⚠️⚠️';
	@override String get delete_all_message1 => 'Tem certeza de que deseja continuar? Todos os seus dados serão excluídos permanentemente e não poderão ser recuperados';
	@override String get delete_all_header2 => 'Último passo ⚠️⚠️';
	@override String get delete_all_message2 => 'Ao excluir uma conta, você excluirá todos os seus dados pessoais armazenados. Suas contas, transações, orçamentos e categorias serão excluídos e não poderão ser recuperados. Você concorda?';
}

// Path: more.about_us
class _TranslationsMoreAboutUsPt implements _TranslationsMoreAboutUsEn {
	_TranslationsMoreAboutUsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Informações do aplicativo';
	@override String get description => 'Confira os termos e outras informações relevantes sobre o Parsa. Entre em contato com a comunidade relatando bugs, deixando sugestões...';
	@override late final _TranslationsMoreAboutUsLegalPt legal = _TranslationsMoreAboutUsLegalPt._(_root);
	@override late final _TranslationsMoreAboutUsProjectPt project = _TranslationsMoreAboutUsProjectPt._(_root);
}

// Path: more.help_us
class _TranslationsMoreHelpUsPt implements _TranslationsMoreHelpUsEn {
	_TranslationsMoreHelpUsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Ajude-nos';
	@override String get description => 'Descubra como você pode ajudar o Parsa a ficar cada vez melhor';
	@override String get rate_us => 'Nos avalie';
	@override String get rate_us_descr => 'Qualquer avaliação é bem-vinda!';
	@override String get share => 'Compartilhar o Parsa';
	@override String get share_descr => 'Compartilhe nosso aplicativo com amigos e familiares';
	@override String get share_text => 'Parsa! O melhor aplicativo de finanças pessoais. Baixe aqui';
	@override String get thanks => 'Obrigado!';
	@override String get thanks_long => 'Suas contribuições para o Parsa e outros projetos de código aberto, grandes e pequenos, tornam possíveis grandes projetos como este. Obrigado por dedicar seu tempo para contribuir.';
	@override String get donate => 'Faça uma doação';
	@override String get donate_descr => 'Com sua doação, você ajudará o aplicativo a continuar recebendo melhorias. Que melhor maneira de agradecer pelo trabalho feito do que me convidar para um café?';
	@override String get donate_success => 'Doação realizada. Muito obrigado pela sua contribuição! ❤️';
	@override String get donate_err => 'Oops! Parece que houve um erro ao receber seu pagamento';
	@override String get report => 'Relatar bugs, deixar sugestões...';
}

// Path: general.time.ranges
class _TranslationsGeneralTimeRangesPt implements _TranslationsGeneralTimeRangesEn {
	_TranslationsGeneralTimeRangesPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Intervalo de tempo';
	@override String get it_repeat => 'Repete';
	@override String get it_ends => 'Termina';
	@override String get forever => 'Para sempre';
	@override late final _TranslationsGeneralTimeRangesTypesPt types = _TranslationsGeneralTimeRangesTypesPt._(_root);
	@override String each_range({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Todo ${range}',
		other: 'Todo ${n} ${range}',
	);
	@override String each_range_until_date({required num n, required Object range, required Object day}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Todo ${range} até ${day}',
		other: 'Todo ${n} ${range} até ${day}',
	);
	@override String each_range_until_times({required num n, required Object range, required Object limit}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Todo ${range} ${limit} vezes',
		other: 'Todo ${n} ${range} ${limit} vezes',
	);
	@override String each_range_until_once({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Todo ${range} uma vez',
		other: 'Todo ${n} ${range} uma vez',
	);
	@override String month({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Mês',
		other: 'Meses',
	);
	@override String year({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Ano',
		other: 'Anos',
	);
	@override String day({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Dia',
		other: 'Dias',
	);
	@override String week({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Semana',
		other: 'Semanas',
	);
}

// Path: general.time.periodicity
class _TranslationsGeneralTimePeriodicityPt implements _TranslationsGeneralTimePeriodicityEn {
	_TranslationsGeneralTimePeriodicityPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Recorrência';
	@override String get no_repeat => 'Sem repetição';
	@override String repeat({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Repetição',
		other: 'Repetições',
	);
	@override String get diary => 'Diariamente';
	@override String get monthly => 'Mensalmente';
	@override String get annually => 'Anualmente';
	@override String get quaterly => 'Trimestralmente';
	@override String get weekly => 'Semanalmente';
	@override String get custom => 'Personalizado';
	@override String get infinite => 'Sempre';
}

// Path: general.time.current
class _TranslationsGeneralTimeCurrentPt implements _TranslationsGeneralTimeCurrentEn {
	_TranslationsGeneralTimeCurrentPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get monthly => 'Este mês';
	@override String get annually => 'Este ano';
	@override String get quaterly => 'Este trimestre';
	@override String get weekly => 'Esta semana';
	@override String get infinite => 'Para sempre';
	@override String get custom => 'Intervalo personalizado';
}

// Path: general.time.all
class _TranslationsGeneralTimeAllPt implements _TranslationsGeneralTimeAllEn {
	_TranslationsGeneralTimeAllPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get diary => 'Todos os dias';
	@override String get monthly => 'Todos os meses';
	@override String get annually => 'Todos os anos';
	@override String get quaterly => 'Todos os trimestres';
	@override String get weekly => 'Todas as semanas';
}

// Path: financial_health.review.descr
class _TranslationsFinancialHealthReviewDescrPt implements _TranslationsFinancialHealthReviewDescrEn {
	_TranslationsFinancialHealthReviewDescrPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get insufficient_data => 'Parece que não temos despesas suficientes para calcular sua saúde financeira. Adicione algumas despesas/receitas neste período para que possamos ajudá-lo!';
	@override String get very_good => 'Parabéns! Sua saúde financeira está excelente. Esperamos que continue em sua boa fase e continue aprendendo com o Parsa';
	@override String get good => 'Ótimo! Sua saúde financeira está boa. Visite a aba de análise para ver como economizar ainda mais!';
	@override String get normal => 'Sua saúde financeira está mais ou menos na média do restante da população para este período';
	@override String get bad => 'Parece que sua situação financeira ainda não é das melhores. Explore o restante dos gráficos para aprender mais sobre suas finanças';
	@override String get very_bad => 'Hmm, sua saúde financeira está muito abaixo do esperado. Explore o restante dos gráficos para aprender mais sobre suas finanças';
}

// Path: financial_health.savings_percentage.text
class _TranslationsFinancialHealthSavingsPercentageTextPt implements _TranslationsFinancialHealthSavingsPercentageTextEn {
	_TranslationsFinancialHealthSavingsPercentageTextPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String good({required Object value}) => 'Parabéns! Você conseguiu economizar <b>${value}%</b> da sua renda durante este período. Parece que você já é um especialista, continue assim!';
	@override String normal({required Object value}) => 'Parabéns, você conseguiu economizar <b>${value}%</b> da sua renda durante este período.';
	@override String bad({required Object value}) => 'Você conseguiu economizar <b>${value}%</b> da sua renda durante este período. No entanto, achamos que você ainda pode fazer muito mais!';
	@override String get very_bad => 'Uau, você não conseguiu economizar nada durante este período.';
}

// Path: transaction.list.bulk_edit
class _TranslationsTransactionListBulkEditPt implements _TranslationsTransactionListBulkEditEn {
	_TranslationsTransactionListBulkEditPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get dates => 'Editar datas';
	@override String get categories => 'Editar categorias';
	@override String get status => 'Editar status';
}

// Path: transaction.form.validators
class _TranslationsTransactionFormValidatorsPt implements _TranslationsTransactionFormValidatorsEn {
	_TranslationsTransactionFormValidatorsPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get zero => 'O valor de uma transação não pode ser igual a zero';
	@override String get date_max => 'A data selecionada é posterior à atual. A transação será adicionada como pendente';
	@override String get date_after_account_creation => 'Você não pode criar uma transação cuja data seja anterior à data de criação da conta a que pertence';
	@override String get negative_transfer => 'O valor monetário de uma transferência não pode ser negativo';
	@override String get transfer_between_same_accounts => 'A conta de origem e a conta de destino não podem ser a mesma';
}

// Path: transfer.form.value_in_destiny
class _TranslationsTransferFormValueInDestinyPt implements _TranslationsTransferFormValueInDestinyEn {
	_TranslationsTransferFormValueInDestinyPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Valor transferido no destino';
	@override String amount_short({required Object amount}) => '${amount} para conta de destino';
}

// Path: backup.import.manual_import
class _TranslationsBackupImportManualImportPt implements _TranslationsBackupImportManualImportEn {
	_TranslationsBackupImportManualImportPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Importação manual';
	@override String get descr => 'Importe transações de um arquivo .csv manualmente';
	@override String get default_account => 'Conta padrão';
	@override String get remove_default_account => 'Remover conta padrão';
	@override String get default_category => 'Categoria padrão';
	@override String get select_a_column => 'Selecione uma coluna do .csv';
	@override List<String> get steps => [
		'Selecione seu arquivo',
		'Coluna para quantidade',
		'Coluna para conta',
		'Coluna para categoria',
		'Coluna para data',
		'outras colunas',
	];
	@override List<String> get steps_descr => [
		'Selecione um arquivo .csv do seu dispositivo. Certifique-se de que ele tenha uma primeira linha que descreva o nome de cada coluna',
		'Selecione a coluna onde o valor de cada transação é especificado. Use valores negativos para despesas e valores positivos para receitas. Use ponto como separador decimal',
		'Selecione a coluna onde a conta à qual cada transação pertence é especificada. Você também pode selecionar uma conta padrão caso não consigamos encontrar a conta que deseja. Se uma conta padrão não for especificada, criaremos uma com o mesmo nome',
		'Especifique a coluna onde o nome da categoria da transação está localizado. Você deve especificar uma categoria padrão para que possamos atribuir essa categoria às transações, caso a categoria não possa ser encontrada',
		'Selecione a coluna onde a data de cada transação é especificada. Se não for especificado, as transações serão criadas na data atual',
		'Especifique as colunas para outros atributos opcionais da transação',
	];
	@override String success({required Object x}) => 'Importado com sucesso ${x} transações';
}

// Path: more.about_us.legal
class _TranslationsMoreAboutUsLegalPt implements _TranslationsMoreAboutUsLegalEn {
	_TranslationsMoreAboutUsLegalPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Informações legais';
	@override String get privacy => 'Política de privacidade';
	@override String get terms => 'Termos de uso';
	@override String get licenses => 'Licenças';
}

// Path: more.about_us.project
class _TranslationsMoreAboutUsProjectPt implements _TranslationsMoreAboutUsProjectEn {
	_TranslationsMoreAboutUsProjectPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get display => 'Projeto';
	@override String get contributors => 'Colaboradores';
	@override String get contributors_descr => 'Todos os desenvolvedores que ajudaram o Parsa a crescer';
	@override String get contact => 'Entre em contato';
}

// Path: general.time.ranges.types
class _TranslationsGeneralTimeRangesTypesPt implements _TranslationsGeneralTimeRangesTypesEn {
	_TranslationsGeneralTimeRangesTypesPt._(this._root);

	@override final _TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get cycle => 'Ciclos';
	@override String get last_days => 'Últimos dias';
	@override String last_days_form({required Object x}) => '${x} dias anteriores';
	@override String get all => 'Sempre';
	@override String get date_range => 'Intervalo personalizado';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'general.cancel': return 'Cancel';
			case 'general.or': return 'or';
			case 'general.understood': return 'Understood';
			case 'general.unspecified': return 'Unspecified';
			case 'general.confirm': return 'Confirm';
			case 'general.continue_text': return 'Continue';
			case 'general.quick_actions': return 'Quick actions';
			case 'general.save': return 'Save';
			case 'general.save_changes': return 'Save changes';
			case 'general.close_and_save': return 'Save and close';
			case 'general.add': return 'Add';
			case 'general.edit': return 'Edit';
			case 'general.balance': return 'Balance';
			case 'general.delete': return 'Delete';
			case 'general.account': return 'Account';
			case 'general.accounts': return 'Accounts';
			case 'general.categories': return 'Categories';
			case 'general.category': return 'Category';
			case 'general.today': return 'Today';
			case 'general.yesterday': return 'Yesterday';
			case 'general.filters': return 'Filters';
			case 'general.select_all': return 'Select all';
			case 'general.deselect_all': return 'Deselect all';
			case 'general.empty_warn': return 'Ops! This is very empty';
			case 'general.insufficient_data': return 'Insufficient data';
			case 'general.show_more_fields': return 'Show more fields';
			case 'general.show_less_fields': return 'Show less fields';
			case 'general.tap_to_search': return 'Tap to search';
			case 'general.clipboard.success': return ({required Object x}) => '${x} copied to the clipboard';
			case 'general.clipboard.error': return 'Error copying';
			case 'general.time.start_date': return 'Start date';
			case 'general.time.end_date': return 'End date';
			case 'general.time.from_date': return 'From date';
			case 'general.time.until_date': return 'Until date';
			case 'general.time.date': return 'Date';
			case 'general.time.datetime': return 'Datetime';
			case 'general.time.time': return 'Time';
			case 'general.time.each': return 'Each';
			case 'general.time.after': return 'After';
			case 'general.time.ranges.display': return 'Time range';
			case 'general.time.ranges.it_repeat': return 'Repeats';
			case 'general.time.ranges.it_ends': return 'Ends';
			case 'general.time.ranges.forever': return 'Forever';
			case 'general.time.ranges.types.cycle': return 'Cycles';
			case 'general.time.ranges.types.last_days': return 'Last days';
			case 'general.time.ranges.types.last_days_form': return ({required Object x}) => '${x} previous days';
			case 'general.time.ranges.types.all': return 'Always';
			case 'general.time.ranges.types.date_range': return 'Custom range';
			case 'general.time.ranges.each_range': return ({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Every ${range}',
				other: 'Every ${n} ${range}',
			);
			case 'general.time.ranges.each_range_until_date': return ({required num n, required Object range, required Object day}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Every ${range} until ${day}',
				other: 'Every ${n} ${range} until ${day}',
			);
			case 'general.time.ranges.each_range_until_times': return ({required num n, required Object range, required Object limit}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Every ${range} ${limit} times',
				other: 'Every ${n} ${range} ${limit} times',
			);
			case 'general.time.ranges.each_range_until_once': return ({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Every ${range} once',
				other: 'Every ${n} ${range} once',
			);
			case 'general.time.ranges.month': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Month',
				other: 'Months',
			);
			case 'general.time.ranges.year': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Year',
				other: 'Years',
			);
			case 'general.time.ranges.day': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Day',
				other: 'Days',
			);
			case 'general.time.ranges.week': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Week',
				other: 'Weeks',
			);
			case 'general.time.periodicity.display': return 'Recurrence';
			case 'general.time.periodicity.no_repeat': return 'No repeat';
			case 'general.time.periodicity.repeat': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Repetition',
				other: 'Repetitions',
			);
			case 'general.time.periodicity.diary': return 'Daily';
			case 'general.time.periodicity.monthly': return 'Monthly';
			case 'general.time.periodicity.annually': return 'Annually';
			case 'general.time.periodicity.quaterly': return 'Quarterly';
			case 'general.time.periodicity.weekly': return 'Weekly';
			case 'general.time.periodicity.custom': return 'Custom';
			case 'general.time.periodicity.infinite': return 'Always';
			case 'general.time.current.monthly': return 'This month';
			case 'general.time.current.annually': return 'This year';
			case 'general.time.current.quaterly': return 'This quarter';
			case 'general.time.current.weekly': return 'This week';
			case 'general.time.current.infinite': return 'For ever';
			case 'general.time.current.custom': return 'Custom Range';
			case 'general.time.all.diary': return 'Every day';
			case 'general.time.all.monthly': return 'Every month';
			case 'general.time.all.annually': return 'Every year';
			case 'general.time.all.quaterly': return 'Every quarterly';
			case 'general.time.all.weekly': return 'Every week';
			case 'general.transaction_order.display': return 'Order transactions';
			case 'general.transaction_order.category': return 'By category';
			case 'general.transaction_order.quantity': return 'By quantity';
			case 'general.transaction_order.date': return 'By date';
			case 'general.validations.required': return 'Required field';
			case 'general.validations.positive': return 'Should be positive';
			case 'general.validations.min_number': return ({required Object x}) => 'Should be greater than ${x}';
			case 'general.validations.max_number': return ({required Object x}) => 'Should be less than ${x}';
			case 'intro.start': return 'Start';
			case 'intro.skip': return 'Skip';
			case 'intro.next': return 'Next';
			case 'intro.select_your_currency': return 'Select your currency';
			case 'intro.welcome_subtitle': return 'Your personal finance manager';
			case 'intro.welcome_subtitle2': return '100% open, 100% free';
			case 'intro.welcome_footer': return 'By logging in you agree to the <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/PRIVACY_POLICY.md\'>Privacy Policy</a> and the <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/TERMS_OF_USE.md\'>Terms of Use</a> of the application';
			case 'intro.offline_descr_title': return 'OFFLINE ACCOUNT:';
			case 'intro.offline_descr': return 'Your data will only be stored on your device, and will be safe as long as you don\'t uninstall the app or change phone. To prevent data loss, it is recommended to make a backup regularly from the app settings.';
			case 'intro.offline_start': return 'Start session offline';
			case 'intro.sl1_title': return 'Select your currency';
			case 'intro.sl1_descr': return 'Your default currency will be used in reports and general charts. You will be able to change the currency and the app language later at any time in the application settings';
			case 'intro.sl2_title': return 'Safe, private and reliable';
			case 'intro.sl2_descr': return 'Your data is only yours. We store the information directly on your device, without going through external servers. This makes it possible to use the app even without internet';
			case 'intro.sl2_descr2': return 'Also, the source code of the application is public, anyone can collaborate on it and see how it works';
			case 'intro.last_slide_title': return 'All ready';
			case 'intro.last_slide_descr': return 'With Parsa, you can finally achieve the financial independence you want so much. You will have graphs, budgets, tips, statistics and much more about your money.';
			case 'intro.last_slide_descr2': return 'We hope you enjoy your experience! Do not hesitate to contact us in case of doubts, suggestions...';
			case 'home.title': return 'Dashboard';
			case 'home.filter_transactions': return 'Filter transactions';
			case 'home.hello_day': return 'Good morning,';
			case 'home.hello_night': return 'Good night,';
			case 'home.total_balance': return 'Total balance';
			case 'home.my_accounts': return 'My accounts';
			case 'home.active_accounts': return 'Active accounts';
			case 'home.no_accounts': return 'No accounts created yet';
			case 'home.no_accounts_descr': return 'Start using all the magic of Parsa. Create at least one account to start adding transactions';
			case 'home.last_transactions': return 'Last transactions';
			case 'home.should_create_account_header': return 'Oops!';
			case 'home.should_create_account_message': return 'You must have at least one no-archived account before you can start creating transactions';
			case 'financial_health.display': return 'Financial health';
			case 'financial_health.review.very_good': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Very good!';
					case GenderContext.female:
						return 'Very good!';
				}
			};
			case 'financial_health.review.good': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Good';
					case GenderContext.female:
						return 'Good';
				}
			};
			case 'financial_health.review.normal': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Average';
					case GenderContext.female:
						return 'Average';
				}
			};
			case 'financial_health.review.bad': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Fair';
					case GenderContext.female:
						return 'Fair';
				}
			};
			case 'financial_health.review.very_bad': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Very Bad';
					case GenderContext.female:
						return 'Very Bad';
				}
			};
			case 'financial_health.review.insufficient_data': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Insufficient data';
					case GenderContext.female:
						return 'Insufficient data';
				}
			};
			case 'financial_health.review.descr.insufficient_data': return 'It looks like we don\'t have enough expenses to calculate your financial health. Add some expenses/incomes in this period to allow us to help you!';
			case 'financial_health.review.descr.very_good': return 'Congratulations! Your financial health is tremendous. We hope you continue your good streak and continue learning with Parsa';
			case 'financial_health.review.descr.good': return 'Great! Your financial health is good. Visit the analysis tab to see how to save even more!';
			case 'financial_health.review.descr.normal': return 'Your financial health is more or less in the average of the rest of the population for this period';
			case 'financial_health.review.descr.bad': return 'It seems that your financial situation is not the best yet. Explore the rest of the charts to learn more about your finances';
			case 'financial_health.review.descr.very_bad': return 'Hmm, your financial health is far below what it should be. Explore the rest of the charts to learn more about your finances';
			case 'financial_health.months_without_income.title': return 'Survival rate';
			case 'financial_health.months_without_income.subtitle': return 'Given your balance, amount of time you could go without income';
			case 'financial_health.months_without_income.text_zero': return 'You couldn\'t survive a month without income at this rate of expenses!';
			case 'financial_health.months_without_income.text_one': return 'You could barely survive approximately a month without income at this rate of expenses!';
			case 'financial_health.months_without_income.text_other': return ({required Object n}) => 'You could survive approximately <b>${n} months</b> without income at this rate of spending.';
			case 'financial_health.months_without_income.text_infinite': return 'You could survive approximately <b>all your life</b> without income at this rate of spending.';
			case 'financial_health.months_without_income.suggestion': return 'Remember that it is advisable to always keep this ratio above 5 months at least. If you see that you do not have a sufficient savings cushion, reduce unnecessary expenses.';
			case 'financial_health.months_without_income.insufficient_data': return 'It looks like we don\'t have enough expenses to calculate how many months you could survive without income. Enter a few transactions and come back here to check your financial health';
			case 'financial_health.savings_percentage.title': return 'Savings percentage';
			case 'financial_health.savings_percentage.subtitle': return 'What part of your income is not spent in this period';
			case 'financial_health.savings_percentage.text.good': return ({required Object value}) => 'Congratulations! You have managed to save <b>${value}%</b> of your income during this period. It seems that you are already an expert, keep up the good work!';
			case 'financial_health.savings_percentage.text.normal': return ({required Object value}) => 'Congratulations, you have managed to save <b>${value}%</b> of your income during this period.';
			case 'financial_health.savings_percentage.text.bad': return ({required Object value}) => 'You have managed to save <b>${value}%</b> of your income during this period. However, we think you can still do much more!';
			case 'financial_health.savings_percentage.text.very_bad': return 'Wow, you haven\'t managed to save anything during this period.';
			case 'financial_health.savings_percentage.suggestion': return 'Remember that it is advisable to save at least 15-20% of what you earn.';
			case 'stats.title': return 'Statistics';
			case 'stats.balance': return 'Balance';
			case 'stats.final_balance': return 'Final balance';
			case 'stats.balance_by_account': return 'Balance by accounts';
			case 'stats.balance_by_currency': return 'Balance by currency';
			case 'stats.cash_flow': return 'Cash flow';
			case 'stats.balance_evolution': return 'Balance evolution';
			case 'stats.compared_to_previous_period': return 'Compared to the previous period';
			case 'stats.by_periods': return 'By periods';
			case 'stats.by_categories': return 'By categories';
			case 'stats.by_tags': return 'By tags';
			case 'stats.distribution': return 'Distribution';
			case 'stats.finance_health_resume': return 'Resume';
			case 'stats.finance_health_breakdown': return 'Breakdown';
			case 'icon_selector.name': return 'Name:';
			case 'icon_selector.icon': return 'Icon';
			case 'icon_selector.color': return 'Color';
			case 'icon_selector.select_icon': return 'Select an icon';
			case 'icon_selector.select_color': return 'Select a color';
			case 'icon_selector.select_account_icon': return 'Identify your account';
			case 'icon_selector.select_category_icon': return 'Identify your category';
			case 'icon_selector.scopes.transport': return 'Transport';
			case 'icon_selector.scopes.money': return 'Money';
			case 'icon_selector.scopes.food': return 'Food';
			case 'icon_selector.scopes.medical': return 'Health';
			case 'icon_selector.scopes.entertainment': return 'Leisure';
			case 'icon_selector.scopes.technology': return 'Technology';
			case 'icon_selector.scopes.other': return 'Others';
			case 'icon_selector.scopes.logos_financial_institutions': return 'Financial institutions';
			case 'transaction.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Transaction',
				other: 'Transactions',
			);
			case 'transaction.create': return 'New transaction';
			case 'transaction.new_income': return 'New income';
			case 'transaction.new_expense': return 'New expense';
			case 'transaction.new_success': return 'Transaction created successfully';
			case 'transaction.edit': return 'Edit transaction';
			case 'transaction.edit_success': return 'Transaction edited successfully';
			case 'transaction.edit_multiple': return 'Edit transactions';
			case 'transaction.edit_multiple_success': return ({required Object x}) => '${x} transactions edited successfully';
			case 'transaction.duplicate': return 'Clone transaction';
			case 'transaction.duplicate_short': return 'Clone';
			case 'transaction.duplicate_warning_message': return 'A transaction identical to this will be created with the same date, do you want to continue?';
			case 'transaction.duplicate_success': return 'Transaction cloned successfully';
			case 'transaction.delete': return 'Delete transaction';
			case 'transaction.delete_warning_message': return 'This action is irreversible. The current balance of your accounts and all your statistics will be recalculated';
			case 'transaction.delete_success': return 'Transaction deleted correctly';
			case 'transaction.delete_multiple': return 'Delete transactions';
			case 'transaction.delete_multiple_warning_message': return ({required Object x}) => 'This action is irreversible and will remove ${x} transactions. The current balance of your accounts and all your statistics will be recalculated';
			case 'transaction.delete_multiple_success': return ({required Object x}) => '${x} transactions deleted correctly';
			case 'transaction.details': return 'Movement details';
			case 'transaction.next_payments.accept': return 'Accept';
			case 'transaction.next_payments.skip': return 'Skip';
			case 'transaction.next_payments.skip_success': return 'Successfully skipped transaction';
			case 'transaction.next_payments.skip_dialog_title': return 'Skip transaction';
			case 'transaction.next_payments.skip_dialog_msg': return ({required Object date}) => 'This action is irreversible. We will move the date of the next move to ${date}';
			case 'transaction.next_payments.accept_today': return 'Accept today';
			case 'transaction.next_payments.accept_in_required_date': return ({required Object date}) => 'Accept in required date (${date})';
			case 'transaction.next_payments.accept_dialog_title': return 'Accept transaction';
			case 'transaction.next_payments.accept_dialog_msg_single': return 'The new status of the transaction will be null. You can re-edit the status of this transaction whenever you want';
			case 'transaction.next_payments.accept_dialog_msg': return ({required Object date}) => 'This action will create a new transaction with date ${date}. You will be able to check the details of this transaction on the transaction page';
			case 'transaction.next_payments.recurrent_rule_finished': return 'The recurring rule has been completed, there are no more payments to make!';
			case 'transaction.list.empty': return 'No transactions found to display here. Add a transaction by clicking the \'+\' button at the bottom';
			case 'transaction.list.searcher_placeholder': return 'Search by category, description...';
			case 'transaction.list.searcher_no_results': return 'No transactions found matching the search criteria';
			case 'transaction.list.loading': return 'Loading more transactions...';
			case 'transaction.list.selected_short': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: '${n} selected',
				other: '${n} selected',
			);
			case 'transaction.list.selected_long': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: '${n} transaction selected',
				other: '${n} transactions selected',
			);
			case 'transaction.list.bulk_edit.dates': return 'Edit dates';
			case 'transaction.list.bulk_edit.categories': return 'Edit categories';
			case 'transaction.list.bulk_edit.status': return 'Edit statuses';
			case 'transaction.filters.from_value': return 'From amount';
			case 'transaction.filters.to_value': return 'Up to amount';
			case 'transaction.filters.from_value_def': return ({required Object x}) => 'From ${x}';
			case 'transaction.filters.to_value_def': return ({required Object x}) => 'Up to ${x}';
			case 'transaction.filters.from_date_def': return ({required Object date}) => 'From the ${date}';
			case 'transaction.filters.to_date_def': return ({required Object date}) => 'Up to the ${date}';
			case 'transaction.form.validators.zero': return 'The value of a transaction cannot be equal to zero';
			case 'transaction.form.validators.date_max': return 'The selected date is after the current one. The transaction will be added as pending';
			case 'transaction.form.validators.date_after_account_creation': return 'You cannot create a transaction whose date is before the creation date of the account it belongs to';
			case 'transaction.form.validators.negative_transfer': return 'The monetary value of a transfer cannot be negative';
			case 'transaction.form.validators.transfer_between_same_accounts': return 'The origin and the destination account cannot be the same';
			case 'transaction.form.title': return 'Transaction title';
			case 'transaction.form.title_short': return 'Title';
			case 'transaction.form.value': return 'Value of the transaction';
			case 'transaction.form.tap_to_see_more': return 'Tap to see more details';
			case 'transaction.form.no_tags': return '-- No tags --';
			case 'transaction.form.description': return 'Description';
			case 'transaction.form.description_info': return 'Tap here to enter a more detailed description about this transaction';
			case 'transaction.form.exchange_to_preferred_title': return ({required Object currency}) => 'Exchnage rate to ${currency}';
			case 'transaction.form.exchange_to_preferred_in_date': return 'On transaction date';
			case 'transaction.reversed.title': return 'Inverse transaction';
			case 'transaction.reversed.title_short': return 'Inverse tr.';
			case 'transaction.reversed.description_for_expenses': return 'Despite being an expense transaction, it has a positive amount. These types of transactions can be used to represent the return of a previously recorded expense, such as a refund or having the payment of a debt.';
			case 'transaction.reversed.description_for_incomes': return 'Despite being an income transaction, it has a negative amount. These types of transactions can be used to void or correct an income that was incorrectly recorded, to reflect a return or refund of money or to record payment of debts.';
			case 'transaction.status.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Status',
				other: 'Statuses',
			);
			case 'transaction.status.display_long': return 'Transaction status';
			case 'transaction.status.tr_status': return ({required Object status}) => '${status} transaction';
			case 'transaction.status.none': return 'Stateless';
			case 'transaction.status.none_descr': return 'Transaction without a specific state';
			case 'transaction.status.reconciled': return 'Reconciled';
			case 'transaction.status.reconciled_descr': return 'This transaction has already been validated and corresponds to a real transaction from your bank';
			case 'transaction.status.unreconciled': return 'Unreconciled';
			case 'transaction.status.unreconciled_descr': return 'This transaction has not yet been validated and therefore does not yet appear in your real bank accounts. However, it counts for the calculation of balances and statistics in Parsa';
			case 'transaction.status.pending': return 'Pending';
			case 'transaction.status.pending_descr': return 'This transaction is pending and therefore it will not be taken into account when calculating balances and statistics';
			case 'transaction.status.voided': return 'Voided';
			case 'transaction.status.voided_descr': return 'Void/cancelled transaction due to payment error or any other reason. It will not be taken into account when calculating balances and statistics';
			case 'transaction.types.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Transaction type',
				other: 'Transaction types',
			);
			case 'transaction.types.income': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Income',
				other: 'Incomes',
			);
			case 'transaction.types.expense': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Expense',
				other: 'Expenses',
			);
			case 'transaction.types.transfer': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Transfer',
				other: 'Transfers',
			);
			case 'transfer.display': return 'Transfer';
			case 'transfer.transfers': return 'Transfers';
			case 'transfer.transfer_to': return ({required Object account}) => 'Transfer to ${account}';
			case 'transfer.create': return 'New Transfer';
			case 'transfer.need_two_accounts_warning_header': return 'Ops!';
			case 'transfer.need_two_accounts_warning_message': return 'At least two accounts are needed to perform this action. If you need to adjust or edit the current balance of this account, click the edit button';
			case 'transfer.form.from': return 'Origin account';
			case 'transfer.form.to': return 'Destination account';
			case 'transfer.form.value_in_destiny.title': return 'Amount transferred at destination';
			case 'transfer.form.value_in_destiny.amount_short': return ({required Object amount}) => '${amount} to target account';
			case 'recurrent_transactions.title': return 'Recurrent transactions';
			case 'recurrent_transactions.title_short': return 'Rec. transactions';
			case 'recurrent_transactions.empty': return 'It looks like you don\'t have any recurring transactions. Create a monthly, yearly, or weekly recurring transaction and it will appear here';
			case 'recurrent_transactions.total_expense_title': return 'Total expense per period';
			case 'recurrent_transactions.total_expense_descr': return '* Without considering the start and end date of each recurrence';
			case 'recurrent_transactions.details.title': return 'Recurrent transaction';
			case 'recurrent_transactions.details.descr': return 'The next moves for this transaction are shown below. You can accept the first move or skip this move';
			case 'recurrent_transactions.details.last_payment_info': return 'This movement is the last of the recurring rule, so this rule will be automatically deleted when confirming this action';
			case 'recurrent_transactions.details.delete_header': return 'Delete recurring transaction';
			case 'recurrent_transactions.details.delete_message': return 'This action is irreversible and will not affect transactions you have already confirmed/paid for';
			case 'account.details': return 'Account details';
			case 'account.date': return 'Opening date';
			case 'account.close_date': return 'Closing date';
			case 'account.reopen': return 'Re-open account';
			case 'account.reopen_short': return 'Re-open';
			case 'account.reopen_descr': return 'Are you sure you want to reopen this account?';
			case 'account.balance': return 'Account balance';
			case 'account.n_transactions': return 'Number of transactions';
			case 'account.add_money': return 'Add money';
			case 'account.withdraw_money': return 'Withdraw money';
			case 'account.no_accounts': return 'No transactions found to display here. Add a transaction by clicking the \'+\' button at the bottom';
			case 'account.types.title': return 'Account type';
			case 'account.types.warning': return 'Once the type of account has been chosen, it cannot be changed in the future';
			case 'account.types.normal': return 'Checking account';
			case 'account.types.normal_descr': return 'Useful to record your day-to-day finances. It is the most common account, it allows you to add expenses, income...';
			case 'account.types.saving': return 'Savings account';
			case 'account.types.saving_descr': return 'You will only be able to add and withdraw money from it from other accounts. Perfect to start saving money';
			case 'account.form.name': return 'Account name';
			case 'account.form.name_placeholder': return 'Ex: Savings account';
			case 'account.form.notes': return 'Notes';
			case 'account.form.notes_placeholder': return 'Type some notes/description about this account';
			case 'account.form.initial_balance': return 'Initial balance';
			case 'account.form.current_balance': return 'Current balance';
			case 'account.form.create': return 'Create account';
			case 'account.form.edit': return 'Edit account';
			case 'account.form.currency_not_found_warn': return 'You do not have information on exchange rates for this currency. 1.0 will be used as the default exchange rate. You can modify this in the settings';
			case 'account.form.already_exists': return 'There is already another one with the same name, please write another';
			case 'account.form.tr_before_opening_date': return 'There are transactions in this account with a date before the opening date';
			case 'account.form.iban': return 'IBAN';
			case 'account.form.swift': return 'SWIFT';
			case 'account.delete.warning_header': return 'Delete account?';
			case 'account.delete.warning_text': return 'This action will delete this account and all its transactions';
			case 'account.delete.success': return 'Account deleted successfully';
			case 'account.close.title': return 'Close account';
			case 'account.close.title_short': return 'Close';
			case 'account.close.warn': return 'This account will no longer appear in certain listings and you will not be able to create transactions in it with a date later than the one specified below. This action does not affect any transactions or balance, and you can also reopen this account at any time. ';
			case 'account.close.should_have_zero_balance': return 'You must have a current balance of 0 in this account to close it. Please edit the account before continuing';
			case 'account.close.should_have_no_transactions': return 'This account has transactions after the specified close date. Delete them or edit the account close date before continuing';
			case 'account.close.success': return 'Account closed successfully';
			case 'account.close.unarchive_succes': return 'Account successfully re-opened';
			case 'account.select.one': return 'Select an account';
			case 'account.select.all': return 'All accounts';
			case 'account.select.multiple': return 'Select accounts';
			case 'currencies.currency_converter': return 'Currency converter';
			case 'currencies.currency': return 'Currency';
			case 'currencies.currency_manager': return 'Currency manager';
			case 'currencies.currency_manager_descr': return 'Configure your currency and its exchange rates with others';
			case 'currencies.preferred_currency': return 'Preferred/base currency';
			case 'currencies.change_preferred_currency_title': return 'Change preferred currency';
			case 'currencies.change_preferred_currency_msg': return 'All stats and budgets will be displayed in this currency from now on. Accounts and transactions will keep the currency they had. All saved exchange rates will be deleted if you execute this action. Do you wish to continue?';
			case 'currencies.form.equal_to_preferred_warn': return 'The currency cannot be equal to the user currency';
			case 'currencies.form.specify_a_currency': return 'Please specify a currency';
			case 'currencies.form.add': return 'Add exchange rate';
			case 'currencies.form.add_success': return 'Exchange rate added successfully';
			case 'currencies.form.edit': return 'Edit exchange rate';
			case 'currencies.form.edit_success': return 'Exchange rate edited successfully';
			case 'currencies.delete_all_success': return 'Deleted exchange rates successfully';
			case 'currencies.historical': return 'Historical rates';
			case 'currencies.exchange_rate': return 'Exchange rate';
			case 'currencies.exchange_rates': return 'Exchange rates';
			case 'currencies.empty': return 'Add exchange rates here so that if you have accounts in currencies other than your base currency our charts are more accurate';
			case 'currencies.select_a_currency': return 'Select a currency';
			case 'currencies.search': return 'Search by name or by currency code';
			case 'tags.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Label',
				other: 'Tags',
			);
			case 'tags.form.name': return 'Tag name';
			case 'tags.form.description': return 'Description';
			case 'tags.empty_list': return 'You haven\'t created any tags yet. Tags and categories are a great way to categorize your movements';
			case 'tags.without_tags': return 'Without tags';
			case 'tags.select': return 'Select tags';
			case 'tags.add': return 'Add tag';
			case 'tags.create': return 'Create label';
			case 'tags.create_success': return 'Label created successfully';
			case 'tags.already_exists': return 'This tag name already exists. You may want to edit it';
			case 'tags.edit': return 'Edit tag';
			case 'tags.edit_success': return 'Tag edited successfully';
			case 'tags.delete_success': return 'Category deleted successfully';
			case 'tags.delete_warning_header': return 'Delete tag?';
			case 'tags.delete_warning_message': return 'This action will not delete transactions that have this tag.';
			case 'categories.unknown': return 'Unknown category';
			case 'categories.create': return 'Create category';
			case 'categories.create_success': return 'Category created correctly';
			case 'categories.new_category': return 'New category';
			case 'categories.already_exists': return 'The name of this category already exists. Maybe you want to edit it';
			case 'categories.edit': return 'Edit category';
			case 'categories.edit_success': return 'Category edited correctly';
			case 'categories.name': return 'Category name';
			case 'categories.type': return 'Category type';
			case 'categories.both_types': return 'Both types';
			case 'categories.subcategories': return 'Subcategories';
			case 'categories.subcategories_add': return 'Add subcategory';
			case 'categories.make_parent': return 'Make to category';
			case 'categories.make_child': return 'Make a subcategory';
			case 'categories.make_child_warning1': return ({required Object destiny}) => 'This category and its subcategories will become subcategories of <b>${destiny}</b>.';
			case 'categories.make_child_warning2': return ({required Object x, required Object destiny}) => 'Their transactions <b>(${x})</b> will be moved to the new subcategories created within the <b>${destiny}</b> category.';
			case 'categories.make_child_success': return 'Subcategories created successfully';
			case 'categories.merge': return 'Merge with another category';
			case 'categories.merge_warning1': return ({required Object x, required Object from, required Object destiny}) => 'All transactions (${x}) associated with the category <b>${from}</b> will be moved to the category <b>${destiny}</b>';
			case 'categories.merge_warning2': return ({required Object from}) => 'The category <b>${from}</b> will be irreversibly deleted.';
			case 'categories.merge_success': return 'Category merged successfully';
			case 'categories.delete_success': return 'Category deleted correctly';
			case 'categories.delete_warning_header': return 'Delete category?';
			case 'categories.delete_warning_message': return ({required Object x}) => 'This action will irreversibly delete all transactions <b>(${x})</b> related to this category.';
			case 'categories.select.title': return 'Select categories';
			case 'categories.select.select_one': return 'Select a category';
			case 'categories.select.select_subcategory': return 'Choose a subcategory';
			case 'categories.select.without_subcategory': return 'Without subcategory';
			case 'categories.select.all': return 'All categories';
			case 'categories.select.all_short': return 'All';
			case 'budgets.title': return 'Budgets';
			case 'budgets.repeated': return 'Recurring';
			case 'budgets.one_time': return 'Once';
			case 'budgets.annual': return 'Annuals';
			case 'budgets.week': return 'Weekly';
			case 'budgets.month': return 'Monthly';
			case 'budgets.actives': return 'Actives';
			case 'budgets.pending': return 'Pending start';
			case 'budgets.finish': return 'Finished';
			case 'budgets.from_budgeted': return 'left of ';
			case 'budgets.days_left': return 'days left';
			case 'budgets.days_to_start': return 'days to start';
			case 'budgets.since_expiration': return 'days since expiration';
			case 'budgets.no_budgets': return 'There seem to be no budgets to display in this section. Start by creating a budget by clicking the button below';
			case 'budgets.delete': return 'Delete budget';
			case 'budgets.delete_warning': return 'This action is irreversible. Categories and transactions referring to this quote will not be deleted';
			case 'budgets.form.title': return 'Add a budget';
			case 'budgets.form.name': return 'Budget name';
			case 'budgets.form.value': return 'Limit quantity';
			case 'budgets.form.create': return 'Add budget';
			case 'budgets.form.edit': return 'Edit budget';
			case 'budgets.form.negative_warn': return 'The budgets can not have a negative amount';
			case 'budgets.details.title': return 'Budget Details';
			case 'budgets.details.statistics': return 'Statistics';
			case 'budgets.details.budget_value': return 'Budgeted';
			case 'budgets.details.expend_diary_left': return ({required Object dailyAmount, required Object remainingDays}) => 'You can spend ${dailyAmount}/day for ${remainingDays} remaining days';
			case 'budgets.details.expend_evolution': return 'Expenditure evolution';
			case 'budgets.details.no_transactions': return 'It seems that you have not made any expenses related to this budget';
			case 'backup.export.title': return 'Export your data';
			case 'backup.export.title_short': return 'Export';
			case 'backup.export.all': return 'Full backup';
			case 'backup.export.all_descr': return 'Export all your data (accounts, transactions, budgets, settings...). Import them again at any time so you don\'t lose anything.';
			case 'backup.export.transactions': return 'Transactions backup';
			case 'backup.export.transactions_descr': return 'Export your transactions in CSV so you can more easily analyze them in other programs or applications.';
			case 'backup.export.description': return 'Download your data in different formats';
			case 'backup.export.dialog_title': return 'Save/Send file';
			case 'backup.export.success': return ({required Object x}) => 'File saved/downloaded successfully in ${x}';
			case 'backup.export.error': return 'Error downloading the file. Please contact the developer via lozin.technologies@gmail.com';
			case 'backup.import.title': return 'Import your data';
			case 'backup.import.title_short': return 'Import';
			case 'backup.import.restore_backup': return 'Restore Backup';
			case 'backup.import.restore_backup_descr': return 'Import a previously saved database from Parsa. This action will replace any current application data with the new data';
			case 'backup.import.restore_backup_warn_description': return 'When importing a new database, you will lose all data currently saved in the app. It is recommended to make a backup before continuing. Do not upload here any file whose origin you do not know, upload only files that you have previously downloaded from Parsa';
			case 'backup.import.restore_backup_warn_title': return 'Overwrite all data';
			case 'backup.import.select_other_file': return 'Select other file';
			case 'backup.import.tap_to_select_file': return 'Tap to select a file';
			case 'backup.import.manual_import.title': return 'Manual import';
			case 'backup.import.manual_import.descr': return 'Import transactions from a .csv file manually';
			case 'backup.import.manual_import.default_account': return 'Default account';
			case 'backup.import.manual_import.remove_default_account': return 'Remove default account';
			case 'backup.import.manual_import.default_category': return 'Default Category';
			case 'backup.import.manual_import.select_a_column': return 'Select a column from the .csv';
			case 'backup.import.manual_import.steps.0': return 'Select your file';
			case 'backup.import.manual_import.steps.1': return 'Column for quantity';
			case 'backup.import.manual_import.steps.2': return 'Column for account';
			case 'backup.import.manual_import.steps.3': return 'Column for category';
			case 'backup.import.manual_import.steps.4': return 'Column for date';
			case 'backup.import.manual_import.steps.5': return 'other columns';
			case 'backup.import.manual_import.steps_descr.0': return 'Select a .csv file from your device. Make sure it has a first row that describes the name of each column';
			case 'backup.import.manual_import.steps_descr.1': return 'Select the column where the value of each transaction is specified. Use negative values for expenses and positive values for income. Use a point as a decimal separator';
			case 'backup.import.manual_import.steps_descr.2': return 'Select the column where the account to which each transaction belongs is specified. You can also select a default account in case we cannot find the account you want. If a default account is not specified, we will create one with the same name ';
			case 'backup.import.manual_import.steps_descr.3': return 'Specify the column where the transaction category name is located. You must specify a default category so that we assign this category to transactions, in case the category cannot be found';
			case 'backup.import.manual_import.steps_descr.4': return 'Select the column where the date of each transaction is specified. If not specified, transactions will be created with the current date';
			case 'backup.import.manual_import.steps_descr.5': return 'Specifies the columns for other optional transaction attributes';
			case 'backup.import.manual_import.success': return ({required Object x}) => 'Successfully imported ${x} transactions';
			case 'backup.import.success': return 'Import performed successfully';
			case 'backup.import.cancelled': return 'Import was cancelled by the user';
			case 'backup.import.error': return 'Error importing file. Please contact developer via lozin.technologies@gmail.com';
			case 'backup.about.title': return 'Information about your database';
			case 'backup.about.create_date': return 'Creation date';
			case 'backup.about.modify_date': return 'Last modified';
			case 'backup.about.last_backup': return 'Last backup';
			case 'backup.about.size': return 'Size';
			case 'settings.title_long': return 'Settings and appearance';
			case 'settings.title_short': return 'Settings';
			case 'settings.description': return 'App theme, texts and other general settings';
			case 'settings.edit_profile': return 'Edit profile';
			case 'settings.lang_section': return 'Language and texts';
			case 'settings.lang_title': return 'App language';
			case 'settings.lang_descr': return 'Language in which the texts will be displayed in the app';
			case 'settings.locale': return 'Region';
			case 'settings.locale_descr': return 'Set the format to use for dates, numbers...';
			case 'settings.locale_warn': return 'When changing region the app will update';
			case 'settings.first_day_of_week': return 'First day of week';
			case 'settings.theme_and_colors': return 'Theme and colors';
			case 'settings.theme': return 'Theme';
			case 'settings.theme_auto': return 'Defined by the system';
			case 'settings.theme_light': return 'Light';
			case 'settings.theme_dark': return 'Dark';
			case 'settings.amoled_mode': return 'AMOLED mode';
			case 'settings.amoled_mode_descr': return 'Use a pure black wallpaper when possible. This will slightly help the battery of devices with AMOLED screens';
			case 'settings.dynamic_colors': return 'Dynamic colors';
			case 'settings.dynamic_colors_descr': return 'Use your system accent color whenever possible';
			case 'settings.accent_color': return 'Accent color';
			case 'settings.accent_color_descr': return 'Choose the color the app will use to emphasize certain parts of the interface';
			case 'settings.security.title': return 'Seguridad';
			case 'settings.security.private_mode_at_launch': return 'Private mode at launch';
			case 'settings.security.private_mode_at_launch_descr': return 'Launch the app in private mode by default';
			case 'settings.security.private_mode': return 'Private mode';
			case 'settings.security.private_mode_descr': return 'Hide all monetary values';
			case 'settings.security.private_mode_activated': return 'Private mode activated';
			case 'settings.security.private_mode_deactivated': return 'Private mode disabled';
			case 'more.title': return 'More';
			case 'more.title_long': return 'More actions';
			case 'more.data.display': return 'Data';
			case 'more.data.display_descr': return 'Export and import your data so you don\'t lose anything';
			case 'more.data.delete_all': return 'Delete my data';
			case 'more.data.delete_all_header1': return 'Stop right there padawan ⚠️⚠️';
			case 'more.data.delete_all_message1': return 'Are you sure you want to continue? All your data will be permanently deleted and cannot be recovered';
			case 'more.data.delete_all_header2': return 'One last step ⚠️⚠️';
			case 'more.data.delete_all_message2': return 'By deleting an account you will delete all your stored personal data. Your accounts, transactions, budgets and categories will be deleted and cannot be recovered. Do you agree?';
			case 'more.about_us.display': return 'App information';
			case 'more.about_us.description': return 'Check out the terms and other relevant information about Parsa. Get in touch with the community by reporting bugs, leaving suggestions...';
			case 'more.about_us.legal.display': return 'Legal information';
			case 'more.about_us.legal.privacy': return 'Privacy policy';
			case 'more.about_us.legal.terms': return 'Terms of use';
			case 'more.about_us.legal.licenses': return 'Licenses';
			case 'more.about_us.project.display': return 'Project';
			case 'more.about_us.project.contributors': return 'Collaborators';
			case 'more.about_us.project.contributors_descr': return 'All the developers who have made Parsa grow';
			case 'more.about_us.project.contact': return 'Contact us';
			case 'more.help_us.display': return 'Help us';
			case 'more.help_us.description': return 'Find out how you can help Parsa become better and better';
			case 'more.help_us.rate_us': return 'Rate us';
			case 'more.help_us.rate_us_descr': return 'Any rate is welcome!';
			case 'more.help_us.share': return 'Share Parsa';
			case 'more.help_us.share_descr': return 'Share our app to friends and family';
			case 'more.help_us.share_text': return 'Parsa! The best personal finance app. Download it here';
			case 'more.help_us.thanks': return 'Thank you!';
			case 'more.help_us.thanks_long': return 'Your contributions to Parsa and other open source projects, big and small, make great projects like this possible. Thank you for taking the time to contribute.';
			case 'more.help_us.donate': return 'Make a donation';
			case 'more.help_us.donate_descr': return 'With your donation you will help the app continue receiving improvements. What better way than to thank the work done by inviting me to a coffee?';
			case 'more.help_us.donate_success': return 'Donation made. Thank you very much for your contribution! ❤️';
			case 'more.help_us.donate_err': return 'Oops! It seems there was an error receiving your payment';
			case 'more.help_us.report': return 'Report bugs, leave suggestions...';
			default: return null;
		}
	}
}

extension on _TranslationsEs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'general.cancel': return 'Cancelar';
			case 'general.or': return 'o';
			case 'general.understood': return 'Entendido';
			case 'general.unspecified': return 'Sin especificar';
			case 'general.confirm': return 'Confirmar';
			case 'general.continue_text': return 'Continuar';
			case 'general.quick_actions': return 'Acciones rápidas';
			case 'general.save': return 'Guardar';
			case 'general.save_changes': return 'Guardar cambios';
			case 'general.close_and_save': return 'Guardar y cerrar';
			case 'general.add': return 'Añadir';
			case 'general.edit': return 'Editar';
			case 'general.delete': return 'Eliminar';
			case 'general.balance': return 'Balance';
			case 'general.account': return 'Cuenta';
			case 'general.accounts': return 'Cuentas';
			case 'general.categories': return 'Categorías';
			case 'general.category': return 'Categoría';
			case 'general.today': return 'Hoy';
			case 'general.yesterday': return 'Ayer';
			case 'general.filters': return 'Filtros';
			case 'general.select_all': return 'Seleccionar todo';
			case 'general.deselect_all': return 'Deseleccionar todo';
			case 'general.empty_warn': return 'Ops! Esto esta muy vacio';
			case 'general.insufficient_data': return 'Datos insuficientes';
			case 'general.show_more_fields': return 'Show more fields';
			case 'general.show_less_fields': return 'Show less fields';
			case 'general.tap_to_search': return 'Toca para buscar';
			case 'general.clipboard.success': return ({required Object x}) => '${x} copiado al portapapeles';
			case 'general.clipboard.error': return 'Error al copiar';
			case 'general.time.start_date': return 'Fecha de inicio';
			case 'general.time.end_date': return 'Fecha de fin';
			case 'general.time.from_date': return 'Desde fecha';
			case 'general.time.until_date': return 'Hasta fecha';
			case 'general.time.date': return 'Fecha';
			case 'general.time.datetime': return 'Fecha y hora';
			case 'general.time.time': return 'Hora';
			case 'general.time.each': return 'Cada';
			case 'general.time.after': return 'Tras';
			case 'general.time.ranges.display': return 'Rango temporal';
			case 'general.time.ranges.it_repeat': return 'Se repite';
			case 'general.time.ranges.it_ends': return 'Termina';
			case 'general.time.ranges.types.cycle': return 'Ciclos';
			case 'general.time.ranges.types.last_days': return 'Últimos días';
			case 'general.time.ranges.types.last_days_form': return ({required Object x}) => '${x} días anteriores';
			case 'general.time.ranges.types.all': return 'Siempre';
			case 'general.time.ranges.types.date_range': return 'Rango personalizado';
			case 'general.time.ranges.each_range': return ({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Cada ${range}',
				other: 'Cada ${n} ${range}',
			);
			case 'general.time.ranges.each_range_until_date': return ({required num n, required Object range, required Object day}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Cada ${range} hasta el ${day}',
				other: 'Cada ${n} ${range} hasta el ${day}',
			);
			case 'general.time.ranges.each_range_until_times': return ({required num n, required Object range, required Object limit}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Cada ${range} ${limit} veces',
				other: 'Cada ${n} ${range} ${limit} veces',
			);
			case 'general.time.ranges.each_range_until_once': return ({required num n, required Object range}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Cada ${range} una vez',
				other: 'Cada ${n} ${range} una vez',
			);
			case 'general.time.ranges.forever': return 'Para siempre';
			case 'general.time.ranges.month': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Mes',
				other: 'Meses',
			);
			case 'general.time.ranges.year': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Año',
				other: 'Años',
			);
			case 'general.time.ranges.day': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Día',
				other: 'Días',
			);
			case 'general.time.ranges.week': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Semana',
				other: 'Semanas',
			);
			case 'general.time.periodicity.display': return 'Periodicidad';
			case 'general.time.periodicity.no_repeat': return 'Sin repetición';
			case 'general.time.periodicity.repeat': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Repetición',
				other: 'Repeticiones',
			);
			case 'general.time.periodicity.diary': return 'Diaría';
			case 'general.time.periodicity.monthly': return 'Mensual';
			case 'general.time.periodicity.annually': return 'Anual';
			case 'general.time.periodicity.quaterly': return 'Trimestral';
			case 'general.time.periodicity.weekly': return 'Semanal';
			case 'general.time.periodicity.custom': return 'Personalizado';
			case 'general.time.periodicity.infinite': return 'Siempre';
			case 'general.time.current.diary': return 'Este día';
			case 'general.time.current.monthly': return 'Este mes';
			case 'general.time.current.annually': return 'Este año';
			case 'general.time.current.quaterly': return 'Este trimestre';
			case 'general.time.current.weekly': return 'Esta semana';
			case 'general.time.current.infinite': return 'Desde siempre';
			case 'general.time.current.custom': return 'Rango personalizado';
			case 'general.time.all.diary': return 'Todos los días';
			case 'general.time.all.monthly': return 'Todos los meses';
			case 'general.time.all.annually': return 'Todos los años';
			case 'general.time.all.quaterly': return 'Todos los trimestres';
			case 'general.time.all.weekly': return 'Todas las semanas';
			case 'general.transaction_order.display': return 'Ordenar transacciones';
			case 'general.transaction_order.category': return 'Por categoría';
			case 'general.transaction_order.quantity': return 'Por cantidad';
			case 'general.transaction_order.date': return 'Por fecha';
			case 'general.validations.required': return 'Campo obligatorio';
			case 'general.validations.positive': return 'Debe ser positivo';
			case 'general.validations.min_number': return ({required Object x}) => 'Debe ser mayor que ${x}';
			case 'general.validations.max_number': return ({required Object x}) => 'Debe ser menor que ${x}';
			case 'intro.start': return 'Empecemos';
			case 'intro.skip': return 'Saltar';
			case 'intro.next': return 'Siguiente';
			case 'intro.select_your_currency': return 'Selecciona tu divisa';
			case 'intro.welcome_subtitle': return 'Tu gestor de finanzas personales';
			case 'intro.welcome_subtitle2': return '100% libre, 100% gratis';
			case 'intro.welcome_footer': return 'Al iniciar sesión aceptas la <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/PRIVACY_POLICY.md\'>Política de Privacidad</a> y los <a href=\'https://github.com/enrique-lozano/Parsa/blob/main/docs/TERMS_OF_USE.md\'>Términos de uso</a> de la aplicación';
			case 'intro.offline_descr_title': return 'CUENTA SIN CONEXIÓN:';
			case 'intro.offline_descr': return 'Tus datos serán guardados unicamente en tu dispositivo, y estarán seguros mientras no desinstales la app o cambies de telefono. Para prevenir la perdida de datos se recomienda realizar una copia de seguridad regularmente desde los ajustes de la app.';
			case 'intro.offline_start': return 'Iniciar sesión offline';
			case 'intro.sl1_title': return 'Selecciona tu divisa';
			case 'intro.sl1_descr': return 'Para empezar, selecciona tu moneda. Podrás cambiar de divisa y de idioma mas adelante en todo momento en los ajustes de la aplicación';
			case 'intro.sl2_title': return 'Seguro, privado y confiable';
			case 'intro.sl2_descr': return 'Tus datos son solo tuyos. Almacenamos la información directamente en tu dispositivo, sin pasar por servidores externos. Esto hace que puedas usar la aplicación incluso sin Internet';
			case 'intro.sl2_descr2': return 'Además, el código fuente de la aplicación es público, cualquiera puede colaborar en el y ver como funciona';
			case 'intro.last_slide_title': return 'Todo listo!';
			case 'intro.last_slide_descr': return 'Con Parsa, podrás al fin lograr la independencia financiaria que tanto deseas. Podrás ver gráficas, presupuestos, consejos, estadisticas y mucho más sobre tu dinero.';
			case 'intro.last_slide_descr2': return 'Esperemos que disfrutes de tu experiencia! No dudes en contactar con nosotros en caso de dudas, sugerencias...';
			case 'home.title': return 'Dashboard';
			case 'home.filter_transactions': return 'Filtrar transacciones';
			case 'home.hello_day': return 'Buenos días,';
			case 'home.hello_night': return 'Buenas noches,';
			case 'home.total_balance': return 'Saldo total';
			case 'home.my_accounts': return 'Mis cuentas';
			case 'home.active_accounts': return 'Cuentas activas';
			case 'home.no_accounts': return 'Aun no hay cuentas creadas';
			case 'home.no_accounts_descr': return 'Empieza a usar toda la magia de Parsa. Crea al menos una cuenta para empezar a añadir tranacciones';
			case 'home.last_transactions': return 'Últimas transacciones';
			case 'home.should_create_account_header': return 'Ops!';
			case 'home.should_create_account_message': return 'Debes tener al menos una cuenta no archivada que no sea de ahorros antes de empezar a crear transacciones';
			case 'financial_health.display': return 'Salud financiera';
			case 'financial_health.review.very_good': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Excelente!';
					case GenderContext.female:
						return 'Excelente!';
				}
			};
			case 'financial_health.review.good': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Bueno';
					case GenderContext.female:
						return 'Buena';
				}
			};
			case 'financial_health.review.normal': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'En la media';
					case GenderContext.female:
						return 'En la media';
				}
			};
			case 'financial_health.review.bad': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Regular';
					case GenderContext.female:
						return 'Regular';
				}
			};
			case 'financial_health.review.very_bad': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Muy malo';
					case GenderContext.female:
						return 'Muy mala';
				}
			};
			case 'financial_health.review.insufficient_data': return ({required GenderContext context}) {
				switch (context) {
					case GenderContext.male:
						return 'Datos insuficientes';
					case GenderContext.female:
						return 'Datos insuficientes';
				}
			};
			case 'financial_health.review.descr.insufficient_data': return 'Parece que no tenemos gastos suficientes para calcular tu salud financiera. Añade unos pocos gastos e ingresos para que podamos ayudarte mas!';
			case 'financial_health.review.descr.very_good': return 'Enhorabuena! Tu salud financiera es formidable. Esperamos que sigas con tu buena racha y que continues aprendiendo con Parsa';
			case 'financial_health.review.descr.good': return 'Genial! Tu salud financiera es buena. Visita la pestaña de análisis para ver como ahorrar aun mas!';
			case 'financial_health.review.descr.normal': return 'Tu salud financiera se encuentra mas o menos en la media del resto de la población para este periodo';
			case 'financial_health.review.descr.bad': return 'Parece que tu situación financiera no es la mejor aun. Explora el resto de pestañas de análisis para conocer mas sobre tus finanzas';
			case 'financial_health.review.descr.very_bad': return 'Mmm, tu salud financera esta muy por debajo de lo que debería. Trata de ver donde esta el problema gracias a los distintos gráficos y estadisticas que te proporcionamos';
			case 'financial_health.months_without_income.title': return 'Ratio de supervivencia';
			case 'financial_health.months_without_income.subtitle': return 'Dado tu saldo, cantidad de tiempo que podrías pasar sin ingresos';
			case 'financial_health.months_without_income.text_zero': return '¡No podrías sobrevivir un mes sin ingresos con este ritmo de gastos!';
			case 'financial_health.months_without_income.text_one': return '¡Apenas podrías sobrevivir aproximadamente un mes sin ingresos con este ritmo de gastos!';
			case 'financial_health.months_without_income.text_other': return ({required Object n}) => 'Podrías sobrevivir aproximadamente <b>${n} meses</b> sin ingresos a este ritmo de gasto.';
			case 'financial_health.months_without_income.text_infinite': return 'Podrías sobrevivir aproximadamente <b>casi toda tu vida</b> sin ingresos a este ritmo de gasto.';
			case 'financial_health.months_without_income.suggestion': return 'Recuerda que es recomendable mantener este ratio siempre por encima de 5 meses como mínimo. Si ves que no tienes un colchon de ahorro suficiente, reduce los gastos no necesarios.';
			case 'financial_health.months_without_income.insufficient_data': return 'Parece que no tenemos gastos suficientes para calcular cuantos meses podrías sobrevivir sin ingresos. Introduce unas pocas transacciones y regresa aquí para consultar tu salud financiera';
			case 'financial_health.savings_percentage.title': return 'Porcentaje de ahorro';
			case 'financial_health.savings_percentage.subtitle': return 'Que parte de tus ingresos no son gastados en este periodo';
			case 'financial_health.savings_percentage.text.good': return ({required Object value}) => 'Enhorabuena! Has conseguido ahorrar un <b>${value}%</b> de tus ingresos durante este periodo. Parece que ya eres todo un expert@, sigue asi!';
			case 'financial_health.savings_percentage.text.normal': return ({required Object value}) => 'Enhorabuena, has conseguido ahorrar un <b>${value}%</b> de tus ingresos durante este periodo.';
			case 'financial_health.savings_percentage.text.bad': return ({required Object value}) => 'Has conseguido ahorrar un <b>${value}%</b> de tus ingresos durante este periodo. Sin embargo, creemos que aun puedes hacer mucho mas!';
			case 'financial_health.savings_percentage.text.very_bad': return 'Vaya, no has conseguido ahorrar nada durante este periodo.';
			case 'financial_health.savings_percentage.suggestion': return 'Recuerda que es recomendable ahorrar al menos un 15-20% de lo que ingresas.';
			case 'stats.title': return 'Estadísticas';
			case 'stats.balance': return 'Saldo';
			case 'stats.final_balance': return 'Saldo final';
			case 'stats.balance_by_account': return 'Saldo por cuentas';
			case 'stats.balance_by_currency': return 'Saldo por divisas';
			case 'stats.balance_evolution': return 'Tendencia de saldo';
			case 'stats.compared_to_previous_period': return 'Frente al periodo anterior';
			case 'stats.cash_flow': return 'Flujo de caja';
			case 'stats.by_periods': return 'Por periodos';
			case 'stats.by_categories': return 'Por categorías';
			case 'stats.by_tags': return 'Por etiquetas';
			case 'stats.distribution': return 'Distribución';
			case 'stats.finance_health_resume': return 'Resumen';
			case 'stats.finance_health_breakdown': return 'Desglose';
			case 'icon_selector.name': return 'Nombre:';
			case 'icon_selector.icon': return 'Icono';
			case 'icon_selector.color': return 'Color';
			case 'icon_selector.select_icon': return 'Selecciona un icono';
			case 'icon_selector.select_color': return 'Selecciona un color';
			case 'icon_selector.select_account_icon': return 'Identifica tu cuenta';
			case 'icon_selector.select_category_icon': return 'Identifica tu categoría';
			case 'icon_selector.scopes.transport': return 'Transporte';
			case 'icon_selector.scopes.money': return 'Dinero';
			case 'icon_selector.scopes.food': return 'Comida';
			case 'icon_selector.scopes.medical': return 'Salud';
			case 'icon_selector.scopes.entertainment': return 'Entretenimiento';
			case 'icon_selector.scopes.technology': return 'Technología';
			case 'icon_selector.scopes.other': return 'Otros';
			case 'icon_selector.scopes.logos_financial_institutions': return 'Financial institutions';
			case 'transaction.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Transacción',
				other: 'Transacciones',
			);
			case 'transaction.create': return 'Nueva transacción';
			case 'transaction.new_income': return 'Nuevo ingreso';
			case 'transaction.new_expense': return 'Nuevo gasto';
			case 'transaction.new_success': return 'Transacción creada correctamente';
			case 'transaction.edit': return 'Editar transacción';
			case 'transaction.edit_success': return 'Transacción editada correctamente';
			case 'transaction.edit_multiple': return 'Editar transacciones';
			case 'transaction.edit_multiple_success': return ({required Object x}) => '${x} transacciones editadas correctamente';
			case 'transaction.duplicate': return 'Clonar transacción';
			case 'transaction.duplicate_short': return 'Clonar';
			case 'transaction.duplicate_warning_message': return 'Se creará una transacción identica a esta con su misma fecha, ¿deseas continuar?';
			case 'transaction.duplicate_success': return 'Transacción clonada con exito';
			case 'transaction.delete': return 'Eliminar transacción';
			case 'transaction.delete_warning_message': return 'Esta acción es irreversible. El balance actual de tus cuentas y todas tus estadisticas serán recalculadas';
			case 'transaction.delete_success': return 'Transacción eliminada correctamente';
			case 'transaction.delete_multiple': return 'Eliminar transacciones';
			case 'transaction.delete_multiple_warning_message': return ({required Object x}) => 'Esta acción es irreversible y borrará definitivamente ${x} transacciones. El balance actual de tus cuentas y todas tus estadisticas serán recalculadas';
			case 'transaction.delete_multiple_success': return ({required Object x}) => '${x} transacciones eliminadas correctamente';
			case 'transaction.details': return 'Detalles del movimiento';
			case 'transaction.next_payments.skip': return 'Saltar';
			case 'transaction.next_payments.skip_success': return 'Transacción saltada con exito';
			case 'transaction.next_payments.skip_dialog_title': return 'Saltar transacción';
			case 'transaction.next_payments.skip_dialog_msg': return ({required Object date}) => 'Esta acción es irreversible. Desplazaremos la fecha del proximo movimiento al día ${date}';
			case 'transaction.next_payments.accept': return 'Aceptar';
			case 'transaction.next_payments.accept_today': return 'Aceptar hoy';
			case 'transaction.next_payments.accept_in_required_date': return ({required Object date}) => 'Aceptar en la fecha requerida (${date})';
			case 'transaction.next_payments.accept_dialog_title': return 'Aceptar transacción';
			case 'transaction.next_payments.accept_dialog_msg_single': return 'El estado de la transacción pasará a ser nulo. Puedes volver a editar el estado de esta transacción cuando lo desees';
			case 'transaction.next_payments.accept_dialog_msg': return ({required Object date}) => 'Esta acción creará una transacción nueva con fecha ${date}. Podrás consultar los detalles de esta transacción en la página de transacciones';
			case 'transaction.next_payments.recurrent_rule_finished': return 'La regla recurrente se ha completado, ya no hay mas pagos a realizar!';
			case 'transaction.list.empty': return 'No se han encontrado transacciones que mostrar aquí. Añade una transacción pulsando el botón \'+\' de la parte inferior';
			case 'transaction.list.searcher_placeholder': return 'Busca por categoría, descripción...';
			case 'transaction.list.searcher_no_results': return 'No se han encontrado transacciones que coincidan con los criterios de busqueda';
			case 'transaction.list.loading': return 'Cargando más transacciones...';
			case 'transaction.list.selected_short': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: '${n} seleccionada',
				other: '${n} seleccionadas',
			);
			case 'transaction.list.selected_long': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: '${n} transacción seleccionada',
				other: '${n} transacciones seleccionadas',
			);
			case 'transaction.list.bulk_edit.dates': return 'Editar fechas';
			case 'transaction.list.bulk_edit.categories': return 'Editar categorías';
			case 'transaction.list.bulk_edit.status': return 'Editar estados';
			case 'transaction.filters.from_value': return 'Desde monto';
			case 'transaction.filters.to_value': return 'Hasta monto';
			case 'transaction.filters.from_value_def': return ({required Object x}) => 'Desde ${x}';
			case 'transaction.filters.to_value_def': return ({required Object x}) => 'Hasta ${x}';
			case 'transaction.filters.from_date_def': return ({required Object date}) => 'Desde el ${date}';
			case 'transaction.filters.to_date_def': return ({required Object date}) => 'Hasta el ${date}';
			case 'transaction.form.validators.zero': return 'El valor de una transacción no puede ser igual a cero';
			case 'transaction.form.validators.date_max': return 'La fecha seleccionada es posterior a la actual. Se añadirá la transacción como pendiente';
			case 'transaction.form.validators.date_after_account_creation': return 'No puedes crear una transacción cuya fecha es anterior a la fecha de creación de la cuenta a la que pertenece';
			case 'transaction.form.validators.negative_transfer': return 'El valor monetario de una transferencia no puede ser negativo';
			case 'transaction.form.validators.transfer_between_same_accounts': return 'Las cuentas de origen y destino no pueden coincidir';
			case 'transaction.form.title': return 'Título de la transacción';
			case 'transaction.form.title_short': return 'Título';
			case 'transaction.form.no_tags': return '-- Sin etiquetas --';
			case 'transaction.form.value': return 'Valor de la transacción';
			case 'transaction.form.tap_to_see_more': return 'Toca para ver más detalles';
			case 'transaction.form.description': return 'Descripción';
			case 'transaction.form.description_info': return 'Toca aquí para escribir una descripción mas detallada sobre esta transacción';
			case 'transaction.form.exchange_to_preferred_title': return ({required Object currency}) => 'Cambio a ${currency}';
			case 'transaction.form.exchange_to_preferred_in_date': return 'El día de la transacción';
			case 'transaction.reversed.title': return 'Transacción invertida';
			case 'transaction.reversed.title_short': return 'Tr. invertida';
			case 'transaction.reversed.description_for_expenses': return 'A pesar de ser una transacción de tipo gasto, esta transacción tiene un monto positivo. Este tipo de transacciones pueden usarse para representar la devolución de un gasto previamente registrado, como un reembolso o que te realicen el pago de una deuda.';
			case 'transaction.reversed.description_for_incomes': return 'A pesar de ser una transacción de tipo ingreso, esta transacción tiene un monto negativo. Este tipo de transacciones pueden usarse para anular o corregir un ingreso que fue registrado incorrectamente, para reflejar una devolución o reembolso de dinero o para registrar el pago de deudas.';
			case 'transaction.status.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Estado',
				other: 'Estados',
			);
			case 'transaction.status.display_long': return 'Estado de la transacción';
			case 'transaction.status.tr_status': return ({required Object status}) => 'Transacción ${status}';
			case 'transaction.status.none': return 'Sin estado';
			case 'transaction.status.none_descr': return 'Transacción sin un estado concreto';
			case 'transaction.status.reconciled': return 'Reconciliada';
			case 'transaction.status.reconciled_descr': return 'Esta transacción ha sido validada ya y se corresponde con una transacción real de su banco';
			case 'transaction.status.unreconciled': return 'No reconciliada';
			case 'transaction.status.unreconciled_descr': return 'Esta transacción aun no ha sido validada y por tanto aun no figura en sus cuentas bancarias reales. Sin embargo, es tenida en cuenta para el calculo de balances y estadisticas en Parsa';
			case 'transaction.status.pending': return 'Pendiente';
			case 'transaction.status.pending_descr': return 'Esta transacción esta pendiente y por tanto no será tenida en cuenta a la hora de calcular balances y estadísticas';
			case 'transaction.status.voided': return 'Nula';
			case 'transaction.status.voided_descr': return 'Transacción nula/cancelada debido a un error en el pago o cualquier otro motivo. No será tenida en cuenta a la hora de calcular balances y estadísticas';
			case 'transaction.types.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Tipo de transacción',
				other: 'Tipos de transacción',
			);
			case 'transaction.types.income': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Ingreso',
				other: 'Ingresos',
			);
			case 'transaction.types.expense': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Gasto',
				other: 'Gastos',
			);
			case 'transaction.types.transfer': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Transferencia',
				other: 'Transferencias',
			);
			case 'transfer.display': return 'Transferencia';
			case 'transfer.transfers': return 'Transferencias';
			case 'transfer.transfer_to': return ({required Object account}) => 'Transferencia hacia ${account}';
			case 'transfer.create': return 'Nueva transferencia';
			case 'transfer.need_two_accounts_warning_header': return 'Ops!';
			case 'transfer.need_two_accounts_warning_message': return 'Se necesitan al menos dos cuentas para realizar esta acción. Si lo que necesitas es ajustar o editar el balance actual de esta cuenta pulsa el botón de editar';
			case 'transfer.form.from': return 'Cuenta origen';
			case 'transfer.form.to': return 'Cuenta destino';
			case 'transfer.form.value_in_destiny.title': return 'Cantidad transferida en destino';
			case 'transfer.form.value_in_destiny.amount_short': return ({required Object amount}) => '${amount} a cuenta de destino';
			case 'recurrent_transactions.title': return 'Movimientos recurrentes';
			case 'recurrent_transactions.title_short': return 'Mov. recurrentes';
			case 'recurrent_transactions.empty': return 'Parece que no posees ninguna transacción recurrente. Crea una transacción que se repita mensual, anual o semanalmente y aparecerá aquí';
			case 'recurrent_transactions.total_expense_title': return 'Gasto total por periodo';
			case 'recurrent_transactions.total_expense_descr': return '* Sin considerar la fecha de inicio y fin de cada recurrencia';
			case 'recurrent_transactions.details.title': return 'Transaccion recurrente';
			case 'recurrent_transactions.details.descr': return 'A continuación se muestran próximos movimientos de esta transacción. Podrás aceptar el primero de ellos o saltar este movimiento';
			case 'recurrent_transactions.details.last_payment_info': return 'Este movimiento es el último de la regla recurrente, por lo que se eliminará esta regla de forma automática al confirmar esta acción';
			case 'recurrent_transactions.details.delete_header': return 'Eliminar transacción recurrente';
			case 'recurrent_transactions.details.delete_message': return 'Esta acción es irreversible y no afectará a transacciones que ya hayas confirmado/pagado';
			case 'account.details': return 'Detalles de la cuenta';
			case 'account.date': return 'Fecha de apertura';
			case 'account.close_date': return 'Fecha de cierre';
			case 'account.reopen_short': return 'Reabrir';
			case 'account.reopen': return 'Reabrir cuenta';
			case 'account.reopen_descr': return '¿Seguro que quieres volver a abrir esta cuenta?';
			case 'account.balance': return 'Saldo de la cuenta';
			case 'account.n_transactions': return 'Número de transacciones';
			case 'account.add_money': return 'Añadir dinero';
			case 'account.withdraw_money': return 'Retirar dinero';
			case 'account.no_accounts': return 'No se han encontrado cuentas que mostrar aquí. Añade una transacción pulsando el botón \'+\' de la parte inferior';
			case 'account.types.title': return 'Tipo de cuenta';
			case 'account.types.warning': return 'Una vez elegido el tipo de cuenta este no podrá cambiarse en un futuro';
			case 'account.types.normal': return 'Cuenta corriente';
			case 'account.types.normal_descr': return 'Útil para registrar tus finanzas del día a día. Es la cuenta mas común, permite añadir gastos, ingresos...';
			case 'account.types.saving': return 'Cuenta de ahorros';
			case 'account.types.saving_descr': return 'Solo podrás añadir y retirar dinero de ella desde otras cuentas. Perfecta para empezar a ahorrar';
			case 'account.form.name': return 'Nombre de la cuenta';
			case 'account.form.name_placeholder': return 'Ej: Cuenta de ahorros';
			case 'account.form.notes': return 'Notas';
			case 'account.form.notes_placeholder': return 'Escribe algunas notas/descripciones sobre esta cuenta';
			case 'account.form.initial_balance': return 'Balance inicial';
			case 'account.form.current_balance': return 'Balance actual';
			case 'account.form.create': return 'Crear cuenta';
			case 'account.form.edit': return 'Editar cuenta';
			case 'account.form.tr_before_opening_date': return 'Existen transacciones en esta cuenta con fecha anterior a la fecha de apertura';
			case 'account.form.currency_not_found_warn': return 'No posees información sobre tipos de cambio para esta divisa. Se usará 1.0 como tipo de cambio por defecto. Puedes modificar esto en los ajustes';
			case 'account.form.already_exists': return 'Ya existe otra cuenta con el mismo nombre. Por favor, escriba otro';
			case 'account.form.iban': return 'IBAN';
			case 'account.form.swift': return 'SWIFT';
			case 'account.delete.warning_header': return '¿Eliminar cuenta?';
			case 'account.delete.warning_text': return 'Esta acción borrara esta cuenta y todas sus transacciones. No podrás volver a recuperar esta información tras el borrado.';
			case 'account.delete.success': return 'Cuenta eliminada correctamente';
			case 'account.close.title': return 'Cerrar cuenta';
			case 'account.close.title_short': return 'Cerrar';
			case 'account.close.warn': return 'Esta cuenta ya no aparecerá en ciertos listados y no podrá crear transacciones en ella con fecha posterior a la especificada debajo. Esta acción no afecta a ninguna transacción ni balance, y además, podrás volver a abrir esta cuenta cuando quieras';
			case 'account.close.should_have_zero_balance': return 'Debes tener un saldo actual en la cuenta de 0 para poder cerrarla. Edita esta cuenta antes de continuar';
			case 'account.close.should_have_no_transactions': return 'Esta cuenta posee transacciones posteriores a la fecha de cierre especificada. Borralas o edita la fecha de cierre de la cuenta antes de continuar';
			case 'account.close.success': return 'Cuenta cerrada exitosamente';
			case 'account.close.unarchive_succes': return 'Cuenta re-abierta exitosamente';
			case 'account.select.one': return 'Selecciona una cuenta';
			case 'account.select.multiple': return 'Selecciona cuentas';
			case 'account.select.all': return 'Todas las cuentas';
			case 'currencies.currency_converter': return 'Conversor de divisas';
			case 'currencies.currency_manager': return 'Administrador de divisas';
			case 'currencies.currency_manager_descr': return 'Configura tu divisa y sus tipos de cambio con otras';
			case 'currencies.currency': return 'Divisa';
			case 'currencies.preferred_currency': return 'Divisa predeterminada/base';
			case 'currencies.change_preferred_currency_title': return 'Cambiar divisa predeterminada';
			case 'currencies.change_preferred_currency_msg': return 'Todas las estadisticas y presupuestos serán mostradas en esta divisa a partir de ahora. Las cuentas y transacciones mantendrán la divisa que tenían. Todos los tipos de cambios guardados serán eliminados si ejecutas esta acción, ¿Desea continuar?';
			case 'currencies.form.equal_to_preferred_warn': return 'The currency can not be equal to the user currency';
			case 'currencies.form.specify_a_currency': return 'Por favor, especifica una divisa';
			case 'currencies.form.add': return 'Añadir tipo de cambio';
			case 'currencies.form.add_success': return 'Tipo de cambio añadido correctamente';
			case 'currencies.form.edit': return 'Editar tipo de cambio';
			case 'currencies.form.edit_success': return 'Tipo de cambio editado correctamente';
			case 'currencies.delete_all_success': return 'Tipos de cambio borrados con exito';
			case 'currencies.historical': return 'Histórico de tasas';
			case 'currencies.exchange_rate': return 'Tipo de cambio';
			case 'currencies.exchange_rates': return 'Tipos de cambio';
			case 'currencies.empty': return 'Añade tipos de cambio aqui para que en caso de tener cuentas en otras divisas distintas a tu divisa base nuestros gráficos sean mas exactos';
			case 'currencies.select_a_currency': return 'Selecciona una divisa';
			case 'currencies.search': return 'Busca por nombre o por código de la divisa';
			case 'tags.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
				one: 'Etiqueta',
				other: 'Etiquetas',
			);
			case 'tags.form.name': return 'Nombre de la etiqueta';
			case 'tags.form.description': return 'Descripción';
			case 'tags.empty_list': return 'No has creado ninguna etiqueta aun. Las etiquetas y las categorías son una gran forma de categorizar tus movimientos';
			case 'tags.without_tags': return 'Sin etiquetas';
			case 'tags.select': return 'Selecionar etiquetas';
			case 'tags.create': return 'Crear etiqueta';
			case 'tags.add': return 'Añadir etiqueta';
			case 'tags.create_success': return 'Etiqueta creada correctamente';
			case 'tags.already_exists': return 'El nombre de esta etiqueta ya existe. Puede que quieras editarla';
			case 'tags.edit': return 'Editar etiqueta';
			case 'tags.edit_success': return 'Etiqueta editada correctamente';
			case 'tags.delete_success': return 'Categoría eliminada correctamente';
			case 'tags.delete_warning_header': return '¿Eliminar etiqueta?';
			case 'tags.delete_warning_message': return 'Esta acción no borrará las transacciones que poseen esta etiqueta.';
			case 'categories.unknown': return 'Categoría desconocida';
			case 'categories.create': return 'Crear categoría';
			case 'categories.create_success': return 'Categoría creada correctamente';
			case 'categories.new_category': return 'Nueva categoría';
			case 'categories.already_exists': return 'El nombre de esta categoría ya existe. Puede que quieras editarla';
			case 'categories.edit': return 'Editar categoría';
			case 'categories.edit_success': return 'Categoría editada correctamente';
			case 'categories.name': return 'Nombre de la categoría';
			case 'categories.type': return 'Tipo de categoría';
			case 'categories.both_types': return 'Ambos tipos';
			case 'categories.subcategories': return 'Subcategorías';
			case 'categories.subcategories_add': return 'Añadir subcategoría';
			case 'categories.make_parent': return 'Convertir en categoría';
			case 'categories.make_child': return 'Convertir en subcategoría';
			case 'categories.make_child_warning1': return ({required Object destiny}) => 'Esta categoría y sus subcategorías pasarán a ser subcategorías de <b>${destiny}</b>.';
			case 'categories.make_child_warning2': return ({required Object x, required Object destiny}) => 'Sus transacciones <b>(${x})</b> pasarán a las nuevas subcategorías creadas dentro de la categoría <b>${destiny}</b>.';
			case 'categories.make_child_success': return 'Subcategorías creadas con exito';
			case 'categories.merge': return 'Fusionar con otra categoría';
			case 'categories.merge_warning1': return ({required Object x, required Object from, required Object destiny}) => 'Todas las transacciones (${x}) asocidadas con la categoría <b>${from}</b> serán movidas a la categoría <b>${destiny}</b>.';
			case 'categories.merge_warning2': return ({required Object from}) => 'La categoría <b>${from}</b> será eliminada de forma irreversible.';
			case 'categories.merge_success': return 'Categoría fusionada correctamente';
			case 'categories.delete_success': return 'Categoría eliminada correctamente';
			case 'categories.delete_warning_header': return '¿Eliminar categoría?';
			case 'categories.delete_warning_message': return ({required Object x}) => 'Esta acción borrará de forma irreversible todas las transacciones <b>(${x})</b> relativas a esta categoría.';
			case 'categories.select.title': return 'Selecciona categorías';
			case 'categories.select.select_one': return 'Selecciona una categoría';
			case 'categories.select.select_subcategory': return 'Elige una subcategoría';
			case 'categories.select.without_subcategory': return 'Sin subcategoría';
			case 'categories.select.all': return 'Todas las categorías';
			case 'categories.select.all_short': return 'Todas';
			case 'budgets.title': return 'Presupuestos';
			case 'budgets.repeated': return 'Periódicos';
			case 'budgets.one_time': return 'Una vez';
			case 'budgets.annual': return 'Anuales';
			case 'budgets.week': return 'Semanales';
			case 'budgets.month': return 'Mensuales';
			case 'budgets.actives': return 'Activos';
			case 'budgets.pending': return 'Pendientes de comenzar';
			case 'budgets.finish': return 'Finalizados';
			case 'budgets.from_budgeted': return 'De un total de ';
			case 'budgets.days_left': return 'días restantes';
			case 'budgets.days_to_start': return 'días para empezar';
			case 'budgets.since_expiration': return 'días desde su expiración';
			case 'budgets.no_budgets': return 'Parece que no hay presupuestos que mostrar en esta sección. Empieza creando un presupuesto pulsando el botón inferior';
			case 'budgets.delete': return 'Eliminar presupuesto';
			case 'budgets.delete_warning': return 'Esta acción es irreversible. Categorías y transacciones referentes a este presupuesto no serán eliminados';
			case 'budgets.form.title': return 'Añade un presupuesto';
			case 'budgets.form.name': return 'Nombre del presupuesto';
			case 'budgets.form.value': return 'Cantidad límite';
			case 'budgets.form.create': return 'Añade el presupuesto';
			case 'budgets.form.edit': return 'Editar presupuesto';
			case 'budgets.form.negative_warn': return 'Los presupuestos no pueden tener un valor límite negativo';
			case 'budgets.details.title': return 'Detalles del presupuesto';
			case 'budgets.details.budget_value': return 'Presupuestado';
			case 'budgets.details.statistics': return 'Estadísticas';
			case 'budgets.details.expend_diary_left': return ({required Object dailyAmount, required Object remainingDays}) => 'Puedes gastar ${dailyAmount}/día por los ${remainingDays} días restantes';
			case 'budgets.details.expend_evolution': return 'Evolución del gasto';
			case 'budgets.details.no_transactions': return 'Parece que no has realizado ningún gasto relativo a este presupuesto';
			case 'backup.export.title': return 'Exportar datos';
			case 'backup.export.title_short': return 'Exportar';
			case 'backup.export.all': return 'Respaldo total';
			case 'backup.export.all_descr': return 'Exporta todos tus datos (cuentas, transacciones, presupuestos, ajustes...). Importalos de nuevo en cualquier momento para no perder nada.';
			case 'backup.export.transactions': return 'Respaldo de transacciones';
			case 'backup.export.transactions_descr': return 'Exporta tus transacciones en CSV para que puedas analizarlas mas facilmente en otros programas o aplicaciones.';
			case 'backup.export.description': return 'Exporta tus datos en diferentes formatos';
			case 'backup.export.dialog_title': return 'Guardar/Enviar archivo';
			case 'backup.export.success': return ({required Object x}) => 'Archivo guardado/enviado correctamente en ${x}';
			case 'backup.export.error': return 'Error al descargar el archivo. Por favor contacte con el desarrollador via lozin.technologies@gmail.com';
			case 'backup.import.title': return 'Importar tus datos';
			case 'backup.import.title_short': return 'Importar';
			case 'backup.import.restore_backup': return 'Restaurar copia de seguridad';
			case 'backup.import.restore_backup_descr': return 'Importa una base de datos anteriormente guardada desde Parsa. Esta acción remplazará cualquier dato actual de la aplicación por los nuevos datos';
			case 'backup.import.restore_backup_warn_title': return 'Sobreescribir todos los datos';
			case 'backup.import.restore_backup_warn_description': return 'Al importar una nueva base de datos, perderas toda la información actualmente guardada en la app. Se recomienda hacer una copia de seguridad antes de continuar. No subas aquí ningún fichero cuyo origen no conozcas, sube solo ficheros que hayas descargado previamente desde Parsa';
			case 'backup.import.tap_to_select_file': return 'Pulsa para seleccionar un archivo';
			case 'backup.import.select_other_file': return 'Selecciona otro fichero';
			case 'backup.import.manual_import.title': return 'Importación manual';
			case 'backup.import.manual_import.descr': return 'Importa transacciones desde un fichero .csv de forma manual';
			case 'backup.import.manual_import.default_account': return 'Cuenta por defecto';
			case 'backup.import.manual_import.remove_default_account': return 'Eliminar cuenta por defecto';
			case 'backup.import.manual_import.default_category': return 'Categoría por defecto';
			case 'backup.import.manual_import.select_a_column': return 'Selecciona una columna del .csv';
			case 'backup.import.manual_import.success': return ({required Object x}) => 'Se han importado correctamente ${x} transacciones';
			case 'backup.import.manual_import.steps.0': return 'Selecciona tu fichero';
			case 'backup.import.manual_import.steps.1': return 'Columna para la cantidad';
			case 'backup.import.manual_import.steps.2': return 'Columna para la cuenta';
			case 'backup.import.manual_import.steps.3': return 'Columna para la categoría';
			case 'backup.import.manual_import.steps.4': return 'Columna para la fecha';
			case 'backup.import.manual_import.steps.5': return 'Otras columnas';
			case 'backup.import.manual_import.steps_descr.0': return 'Selecciona un fichero .csv de tu dispositivo. Asegurate de que este tenga una primera fila que describa el nombre de cada columna';
			case 'backup.import.manual_import.steps_descr.1': return 'Selecciona la columna donde se especifica el valor de cada transacción. Usa valores negativos para los gastos y positivos para los ingresos. Usa un punto como separador decimal';
			case 'backup.import.manual_import.steps_descr.2': return 'Selecciona la columna donde se especifica la cuenta a la que pertenece cada transacción. Podrás también seleccionar una cuenta por defecto en el caso de que no encontremos la cuenta que desea. Si no se especifica una cuenta por defecto, crearemos una con el mismo nombre';
			case 'backup.import.manual_import.steps_descr.3': return 'Especifica la columna donde se encuentra el nombre de la categoría de la transacción. Debes especificar una categoría por defecto para que asignemos esta categoría a las transacciones, en caso de que la categoría no se pueda encontrar';
			case 'backup.import.manual_import.steps_descr.4': return 'Selecciona la columna donde se especifica la fecha de cada transacción. En caso de no especificarse, se crearan transacciones con la fecha actual';
			case 'backup.import.manual_import.steps_descr.5': return 'Especifica las columnas para otros atributos optativos de las transacciones';
			case 'backup.import.success': return 'Importación realizada con exito';
			case 'backup.import.cancelled': return 'La importación fue cancelada por el usuario';
			case 'backup.import.error': return 'Error al importar el archivo. Por favor contacte con el desarrollador via lozin.technologies@gmail.com';
			case 'backup.about.title': return 'Información sobre tu base de datos';
			case 'backup.about.create_date': return 'Fecha de creación';
			case 'backup.about.modify_date': return 'Última modificación';
			case 'backup.about.last_backup': return 'Última copia de seguridad';
			case 'backup.about.size': return 'Tamaño';
			case 'settings.title_long': return 'Configuración y apariencia';
			case 'settings.title_short': return 'Configuración';
			case 'settings.description': return 'Tema de la aplicación, textos y otras configuraciones generales';
			case 'settings.edit_profile': return 'Editar perfil';
			case 'settings.lang_section': return 'Idioma y textos';
			case 'settings.lang_title': return 'Idioma de la aplicación';
			case 'settings.lang_descr': return 'Idioma en el que se mostrarán los textos en la aplicación';
			case 'settings.locale': return 'Región';
			case 'settings.locale_descr': return 'Establecer el formato a utilizar para fechas, números...';
			case 'settings.locale_warn': return 'Al cambiar la región, la aplicación se actualizará';
			case 'settings.first_day_of_week': return 'Primer día de la semana';
			case 'settings.theme_and_colors': return 'Tema y colores';
			case 'settings.theme': return 'Tema';
			case 'settings.theme_auto': return 'Definido por el sistema';
			case 'settings.theme_light': return 'Claro';
			case 'settings.theme_dark': return 'Oscuro';
			case 'settings.amoled_mode': return 'Modo AMOLED';
			case 'settings.amoled_mode_descr': return 'Usar un fondo negro puro cuando sea posible. Esto ayudará ligeramente a la batería de dispositivos con pantallas AMOLED';
			case 'settings.dynamic_colors': return 'Colores dinámicos';
			case 'settings.dynamic_colors_descr': return 'Usar el color de acento de su sistema siempre que sea posible';
			case 'settings.accent_color': return 'Color de acento';
			case 'settings.accent_color_descr': return 'Elegir el color que la aplicación usará para enfatizar ciertas partes de la interfaz';
			case 'settings.security.title': return 'Seguridad';
			case 'settings.security.private_mode_at_launch': return 'Modo privado al arrancar';
			case 'settings.security.private_mode_at_launch_descr': return 'Arranca la app en modo privado por defecto';
			case 'settings.security.private_mode': return 'Modo privado';
			case 'settings.security.private_mode_descr': return 'Oculta todos los valores monetarios';
			case 'settings.security.private_mode_activated': return 'Modo privado activado';
			case 'settings.security.private_mode_deactivated': return 'Modo privado desactivado';
			case 'more.title': return 'Más';
			case 'more.title_long': return 'Más acciones';
			case 'more.data.display': return 'Datos';
			case 'more.data.display_descr': return 'Exporta y importa tus datos para no perder nada';
			case 'more.data.delete_all': return 'Eliminar mis datos';
			case 'more.data.delete_all_header1': return 'Alto ahí padawan ⚠️⚠️';
			case 'more.data.delete_all_message1': return '¿Estas seguro de que quieres continuar? Todos tus datos serán borrados permanentemente y no podrán ser recuperados';
			case 'more.data.delete_all_header2': return 'Un último paso ⚠️⚠️';
			case 'more.data.delete_all_message2': return 'Al eliminar una cuenta eliminarás todos tus datos personales almacenados. Tus cuentas, transacciones, presupuestos y categorías serán borrados y no podrán ser recuperados. ¿Estas de acuerdo?';
			case 'more.about_us.display': return 'Información de la app';
			case 'more.about_us.description': return 'Consulta los terminos y otra información relevante sobre Parsa. Ponte en contacto con la comunidad reportando errores, dejando sugerencias...';
			case 'more.about_us.legal.display': return 'Información legal';
			case 'more.about_us.legal.privacy': return 'Política de privacidad';
			case 'more.about_us.legal.terms': return 'Términos de uso';
			case 'more.about_us.legal.licenses': return 'Licencias';
			case 'more.about_us.project.display': return 'Proyecto';
			case 'more.about_us.project.contributors': return 'Colaboradores';
			case 'more.about_us.project.contributors_descr': return 'Todos los desarrolladores que han hecho que Parsa crezca';
			case 'more.about_us.project.contact': return 'Contacta con nosotros';
			case 'more.help_us.display': return 'Ayúdanos';
			case 'more.help_us.description': return 'Descubre de que formas puedes ayudar a que Parsa sea cada vez mejor';
			case 'more.help_us.rate_us': return 'Califícanos';
			case 'more.help_us.rate_us_descr': return '¡Cualquier valoración es bienvenida!';
			case 'more.help_us.share': return 'Comparte Parsa';
			case 'more.help_us.share_descr': return 'Comparte nuestra app a amigos y familiares';
			case 'more.help_us.share_text': return 'Parsa! La mejor app de finanzas personales. Descargala aquí';
			case 'more.help_us.thanks': return '¡Gracias!';
			case 'more.help_us.thanks_long': return 'Tus contribuciones a Parsa y otros proyectos de código abierto, grandes o pequeños, hacen posibles grandes proyectos como este. Gracias por tomarse el tiempo para contribuir.';
			case 'more.help_us.donate': return 'Haz una donación';
			case 'more.help_us.donate_descr': return 'Con tu donación ayudaras a que la app siga recibiendo mejoras. ¿Que mejor forma que agradecer el trabajo realizado invitandome a un cafe?';
			case 'more.help_us.donate_success': return 'Donación realizada. Muchas gracias por tu contribución! ❤️';
			case 'more.help_us.donate_err': return 'Ups! Parece que ha habido un error a la hora de recibir tu pago';
			case 'more.help_us.report': return 'Reporta errores, deja sugerencias...';
			default: return null;
		}
	}
}

extension on _TranslationsPt {
	dynamic _flatMapFunction(String path) {
		switch (path) {
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
			case 'general.time.periodicity.no_repeat': return 'Sem repetição';
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
			case 'general.time.all.diary': return 'Todos os dias';
			case 'general.time.all.monthly': return 'Todos os meses';
			case 'general.time.all.annually': return 'Todos os anos';
			case 'general.time.all.quaterly': return 'Todos os trimestres';
			case 'general.time.all.weekly': return 'Todas as semanas';
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
			case 'intro.welcome_subtitle2': return '100% aberto, 100% grátis';
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
			case 'home.total_balance': return 'Saldo total';
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
			case 'financial_health.review.descr.insufficient_data': return 'Parece que não temos despesas suficientes para calcular sua saúde financeira. Adicione algumas despesas/receitas neste período para que possamos ajudá-lo!';
			case 'financial_health.review.descr.very_good': return 'Parabéns! Sua saúde financeira está excelente. Esperamos que continue em sua boa fase e continue aprendendo com o Parsa';
			case 'financial_health.review.descr.good': return 'Ótimo! Sua saúde financeira está boa. Visite a aba de análise para ver como economizar ainda mais!';
			case 'financial_health.review.descr.normal': return 'Sua saúde financeira está mais ou menos na média do restante da população para este período';
			case 'financial_health.review.descr.bad': return 'Parece que sua situação financeira ainda não é das melhores. Explore o restante dos gráficos para aprender mais sobre suas finanças';
			case 'financial_health.review.descr.very_bad': return 'Hmm, sua saúde financeira está muito abaixo do esperado. Explore o restante dos gráficos para aprender mais sobre suas finanças';
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
			case 'financial_health.savings_percentage.text.very_bad': return 'Uau, você não conseguiu economizar nada durante este período.';
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
			case 'stats.distribution': return 'Distribuição';
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
			case 'transaction.delete_warning_message': return 'Essa ação é irreversível. O saldo atual de suas contas e todas as suas Parsaísticas serão recalculados';
			case 'transaction.delete_success': return 'Transação excluída corretamente';
			case 'transaction.delete_multiple': return 'Excluir transações';
			case 'transaction.delete_multiple_warning_message': return ({required Object x}) => 'Essa ação é irreversível e removerá ${x} transações. O saldo atual de suas contas e todas as suas Parsaísticas serão recalculados';
			case 'transaction.delete_multiple_success': return ({required Object x}) => '${x} transações excluídas corretamente';
			case 'transaction.details': return 'Detalhes do movimento';
			case 'transaction.next_payments.accept': return 'Aceitar';
			case 'transaction.next_payments.skip': return 'Pular';
			case 'transaction.next_payments.skip_success': return 'Transação pulada com sucesso';
			case 'transaction.next_payments.skip_dialog_title': return 'Pular transação';
			case 'transaction.next_payments.skip_dialog_msg': return ({required Object date}) => 'Essa ação é irreversível. Vamos mover a data do próximo movimento para ${date}';
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
			case 'transaction.filters.from_value_def': return ({required Object x}) => 'A partir de ${x}';
			case 'transaction.filters.to_value_def': return ({required Object x}) => 'Até ${x}';
			case 'transaction.filters.from_date_def': return ({required Object date}) => 'A partir de ${date}';
			case 'transaction.filters.to_date_def': return ({required Object date}) => 'Até ${date}';
			case 'transaction.form.validators.zero': return 'O valor de uma transação não pode ser igual a zero';
			case 'transaction.form.validators.date_max': return 'A data selecionada é posterior à atual. A transação será adicionada como pendente';
			case 'transaction.form.validators.date_after_account_creation': return 'Você não pode criar uma transação cuja data seja anterior à data de criação da conta a que pertence';
			case 'transaction.form.validators.negative_transfer': return 'O valor monetário de uma transferência não pode ser negativo';
			case 'transaction.form.validators.transfer_between_same_accounts': return 'A conta de origem e a conta de destino não podem ser a mesma';
			case 'transaction.form.title': return 'Título da transação';
			case 'transaction.form.title_short': return 'Título';
			case 'transaction.form.value': return 'Valor da transação';
			case 'transaction.form.tap_to_see_more': return 'Toque para ver mais detalhes';
			case 'transaction.form.no_tags': return '-- Sem tags --';
			case 'transaction.form.description': return 'Descrição';
			case 'transaction.form.description_info': return 'Toque aqui para inserir uma descrição mais detalhada sobre esta transação';
			case 'transaction.form.exchange_to_preferred_title': return ({required Object currency}) => 'Taxa de câmbio para ${currency}';
			case 'transaction.form.exchange_to_preferred_in_date': return 'Na data da transação';
			case 'transaction.reversed.title': return 'Transação inversa';
			case 'transaction.reversed.title_short': return 'Trans. inversa';
			case 'transaction.reversed.description_for_expenses': return 'Apesar de ser uma transação de despesa, ela tem um valor positivo. Esses tipos de transações podem ser usados para representar o retorno de uma despesa previamente registrada, como um reembolso ou o pagamento de uma dívida.';
			case 'transaction.reversed.description_for_incomes': return 'Apesar de ser uma transação de receita, ela tem um valor negativo. Esses tipos de transações podem ser usados para anular ou corrigir uma receita que foi registrada incorretamente, para refletir um retorno ou reembolso de dinheiro ou para registrar o pagamento de dívidas.';
			case 'transaction.status.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Status',
				other: 'Status',
			);
			case 'transaction.status.display_long': return 'Status da transação';
			case 'transaction.status.tr_status': return ({required Object status}) => 'Transação ${status}';
			case 'transaction.status.none': return 'Sem status';
			case 'transaction.status.none_descr': return 'Transação sem status específico';
			case 'transaction.status.reconciled': return 'Conciliada';
			case 'transaction.status.reconciled_descr': return 'Esta transação já foi validada e corresponde a uma transação real do seu banco';
			case 'transaction.status.unreconciled': return 'Não conciliada';
			case 'transaction.status.unreconciled_descr': return 'Esta transação ainda não foi validada e, portanto, ainda não aparece em suas contas bancárias reais. No entanto, ela conta para o cálculo de saldos e insights no Parsa';
			case 'transaction.status.pending': return 'Pendente';
			case 'transaction.status.pending_descr': return 'Esta transação está pendente e, portanto, não será considerada no cálculo de saldos e insights';
			case 'transaction.status.voided': return 'Anulada';
			case 'transaction.status.voided_descr': return 'Transação anulada/cancelada devido a erro de pagamento ou qualquer outro motivo. Ela não será considerada no cálculo de saldos e insights';
			case 'transaction.types.display': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Tipo de transação',
				other: 'Tipos de transações',
			);
			case 'transaction.types.income': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Receitas',
				other: 'Receitas',
			);
			case 'transaction.types.expense': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Despesas',
				other: 'Despesas',
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
			case 'recurrent_transactions.details.descr': return 'Os próximos movimentos para esta transação estão listados abaixo. Você pode aceitar o primeiro movimento ou pular este movimento';
			case 'recurrent_transactions.details.last_payment_info': return 'Este movimento é o último da regra recorrente, então essa regra será automaticamente excluída ao confirmar esta ação';
			case 'recurrent_transactions.details.delete_header': return 'Excluir transação recorrente';
			case 'recurrent_transactions.details.delete_message': return 'Esta ação é irreversível e não afetará as transações que você já confirmou/pagou';
			case 'account.details': return 'Detalhes da conta';
			case 'account.date': return 'Data de abertura';
			case 'account.close_date': return 'Data de fechamento';
			case 'account.reopen': return 'Reabrir conta';
			case 'account.reopen_short': return 'Reabrir';
			case 'account.reopen_descr': return 'Tem certeza de que deseja reabrir esta conta?';
			case 'account.balance': return 'Saldo da conta';
			case 'account.n_transactions': return 'Número de transações';
			case 'account.add_money': return 'Adicionar dinheiro';
			case 'account.withdraw_money': return 'Retirar dinheiro';
			case 'account.no_accounts': return 'Nenhuma transação encontrada para exibir aqui. Adicione uma transação clicando no botão \'+\' na parte inferior';
			case 'account.types.title': return 'Tipo de conta';
			case 'account.types.warning': return 'Uma vez escolhido o tipo de conta, ele não poderá ser alterado no futuro';
			case 'account.types.normal': return 'Conta corrente';
			case 'account.types.normal_descr': return 'Útil para registrar suas finanças do dia a dia. É a conta mais comum, permite adicionar despesas, receitas...';
			case 'account.types.saving': return 'Conta poupança';
			case 'account.types.saving_descr': return 'Você só poderá adicionar e retirar dinheiro dela a partir de outras contas. Perfeito para começar a economizar';
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
				one: 'Etiqueta',
				other: 'Etiquetas',
			);
			case 'tags.form.name': return 'Nome da etiqueta';
			case 'tags.form.description': return 'Descrição';
			case 'tags.empty_list': return 'Você ainda não criou nenhuma etiqueta. Etiquetas e categorias são uma ótima maneira de categorizar seus movimentos';
			case 'tags.without_tags': return 'Sem etiquetas';
			case 'tags.select': return 'Selecionar etiquetas';
			case 'tags.add': return 'Adicionar etiqueta';
			case 'tags.create': return 'Criar etiqueta';
			case 'tags.create_success': return 'Etiqueta criada com sucesso';
			case 'tags.already_exists': return 'Este nome de etiqueta já existe. Talvez você queira editá-lo';
			case 'tags.edit': return 'Editar etiqueta';
			case 'tags.edit_success': return 'Etiqueta editada com sucesso';
			case 'tags.delete_success': return 'Etiqueta excluída com sucesso';
			case 'tags.delete_warning_header': return 'Excluir etiqueta?';
			case 'tags.delete_warning_message': return 'Essa ação não excluirá as transações que possuem essa etiqueta.';
			case 'categories.unknown': return 'Categoria desconhecida';
			case 'categories.create': return 'Criar categoria';
			case 'categories.create_success': return 'Categoria criada corretamente';
			case 'categories.new_category': return 'Nova categoria';
			case 'categories.already_exists': return 'O nome desta categoria já existe. Talvez você queira editá-la';
			case 'categories.edit': return 'Editar categoria';
			case 'categories.edit_success': return 'Categoria editada corretamente';
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
			case 'categories.delete_success': return 'Categoria excluída corretamente';
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
			case 'budgets.no_budgets': return 'Parece não haver orçamentos para exibir nesta seção. Comece criando um orçamento clicando no botão abaixo';
			case 'budgets.delete': return 'Excluir orçamento';
			case 'budgets.delete_warning': return 'Essa ação é irreversível. Categorias e transações referentes a esta cota não serão excluídas';
			case 'budgets.form.title': return 'Adicionar um orçamento';
			case 'budgets.form.name': return 'Nome do orçamento';
			case 'budgets.form.value': return 'Quantidade limite';
			case 'budgets.form.create': return 'Adicionar orçamento';
			case 'budgets.form.edit': return 'Editar orçamento';
			case 'budgets.form.negative_warn': return 'Os orçamentos não podem ter um valor negativo';
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
			case 'backup.export.description': return 'Baixe seus dados em diferentes formatos';
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
			case 'backup.import.manual_import.title': return 'Importação manual';
			case 'backup.import.manual_import.descr': return 'Importe transações de um arquivo .csv manualmente';
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
			case 'settings.title_long': return 'Configurações e aparência';
			case 'settings.title_short': return 'Configurações';
			case 'settings.description': return 'Tema do aplicativo, textos e outras configurações gerais';
			case 'settings.edit_profile': return 'Editar perfil';
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
			case 'settings.security.title': return 'Segurança';
			case 'settings.security.private_mode_at_launch': return 'Modo privado ao iniciar';
			case 'settings.security.private_mode_at_launch_descr': return 'Inicie o aplicativo no modo privado por padrão';
			case 'settings.security.private_mode': return 'Modo privado';
			case 'settings.security.private_mode_descr': return 'Oculte todos os valores monetários';
			case 'settings.security.private_mode_activated': return 'Modo privado ativado';
			case 'settings.security.private_mode_deactivated': return 'Modo privado desativado';
			case 'more.title': return 'Mais';
			case 'more.title_long': return 'Mais ações';
			case 'more.data.display': return 'Dados';
			case 'more.data.display_descr': return 'Exporte e importe seus dados para não perder nada';
			case 'more.data.delete_all': return 'Excluir meus dados';
			case 'more.data.delete_all_header1': return 'Pare aí, padawan ⚠️⚠️';
			case 'more.data.delete_all_message1': return 'Tem certeza de que deseja continuar? Todos os seus dados serão excluídos permanentemente e não poderão ser recuperados';
			case 'more.data.delete_all_header2': return 'Último passo ⚠️⚠️';
			case 'more.data.delete_all_message2': return 'Ao excluir uma conta, você excluirá todos os seus dados pessoais armazenados. Suas contas, transações, orçamentos e categorias serão excluídos e não poderão ser recuperados. Você concorda?';
			case 'more.about_us.display': return 'Informações do aplicativo';
			case 'more.about_us.description': return 'Confira os termos e outras informações relevantes sobre o Parsa. Entre em contato com a comunidade relatando bugs, deixando sugestões...';
			case 'more.about_us.legal.display': return 'Informações legais';
			case 'more.about_us.legal.privacy': return 'Política de privacidade';
			case 'more.about_us.legal.terms': return 'Termos de uso';
			case 'more.about_us.legal.licenses': return 'Licenças';
			case 'more.about_us.project.display': return 'Projeto';
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
			case 'more.help_us.report': return 'Relatar bugs, deixar sugestões...';
			default: return null;
		}
	}
}
