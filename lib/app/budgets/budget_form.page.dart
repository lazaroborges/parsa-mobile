import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parsa/app/accounts/account_selector.dart';
import 'package:parsa/app/categories/selectors/category_multi_selector.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/database/services/currency/currency_service.dart';
import 'package:parsa/core/extensions/lists.extensions.dart';
import 'package:parsa/core/models/budget/budget.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/models/date-utils/periodicity.dart';
import 'package:parsa/core/presentation/widgets/form_fields/date_field.dart';
import 'package:parsa/core/presentation/widgets/form_fields/date_form_field.dart';
import 'package:parsa/core/utils/text_field_utils.dart';
import 'package:parsa/core/utils/uuid.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:parsa/main.dart' show firebaseAnalytics;

import '../../core/models/account/account.dart';
import '../../core/presentation/widgets/count_indicator.dart';
import '../../core/presentation/widgets/form_fields/list_tile_field.dart';
import '../../core/presentation/widgets/persistent_footer_button.dart';
import '../tags/tags_selector.modal.dart';
import '../../core/database/services/tags/tags_service.dart';
import '../../core/models/tags/tag.dart';

class BudgetFormPage extends StatefulWidget {
  const BudgetFormPage({super.key, this.budgetToEdit, required this.prevPage});

  final Budget? budgetToEdit;

  final Widget prevPage;

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();

  bool get isEditMode => widget.budgetToEdit != null;

  TextEditingController valueController = TextEditingController();
  double? get valueToNumber => double.tryParse(valueController.text);

  TextEditingController nameController = TextEditingController();

  List<Category>? categories;
  List<Account>? accounts;

  // Budget type: 'one-time' or 'repeated'
  String budgetType = 'repeated';

  Periodicity? intervalPeriod = Periodicity.month;

  DateTime startDate = DateTime.now();
  DateTime? endDate;

  List<Tag>? tags;

  submitForm() {
    final t = Translations.of(context);

    if (valueToNumber! < 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.budgets.form.negative_warn)));

      return;
    }

    onSuccess() {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEditMode
              ? t.transaction.edit_success
              : t.transaction.new_success)));
    }

    final Budget toPush;

    // Set intervalPeriod to null for one-time budgets
    final Periodicity? finalIntervalPeriod =
        budgetType == 'one-time' ? null : intervalPeriod;

    toPush = Budget(
      id: isEditMode ? widget.budgetToEdit!.id : generateUUID(),
      name: nameController.text,
      limitAmount: valueToNumber!,
      intervalPeriod: finalIntervalPeriod,
      startDate: finalIntervalPeriod == null ? startDate : null,
      endDate: finalIntervalPeriod == null ? endDate : null,
      categories: categories?.map((e) => e.id).toList(),
      accounts: accounts?.map((e) => e.id).toList(),
      tags: tags?.map((e) => e.id).toList(),
    );

    if (isEditMode) {
      BudgetService.instance.updateBudget(toPush).then((value) {
        onSuccess();
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      });
    } else {
      BudgetService.instance.insertBudget(toPush).then((value) {
        // Track budget creation
        firebaseAnalytics?.logEvent(
          name: 'budget_created',
          parameters: {
            'budget_type': budgetType,
            'creation_source': 'budget_form',
          },
        );

        onSuccess();
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      fillForm(widget.budgetToEdit!);
    }
  }

  // Helper method to determine budget type from a Budget object
  String getBudgetTypeFromBudget(Budget budget) {
    return budget.intervalPeriod == null ? 'one-time' : 'repeated';
  }

  fillForm(Budget budget) async {
    nameController.text = budget.name;
    valueController.text = budget.limitAmount.abs().toString();

    // Set budget type based on intervalPeriod
    budgetType = getBudgetTypeFromBudget(budget);

    if (budget.intervalPeriod == null) {
      startDate = budget.startDate!;
      endDate = budget.endDate;
    }

    categories = budget.categories == null
        ? null
        : await CategoryService.instance
            .getCategories(
              predicate: (p0, p1) => p0.id.isIn(budget.categories!),
            )
            .first;

    accounts = budget.accounts == null
        ? null
        : await AccountService.instance
            .getAccounts(
              predicate: (p0, p1) => p0.id.isIn(budget.accounts!),
            )
            .first;

    intervalPeriod = budget.intervalPeriod;

    // Direct database query to get the tags for this budget
    if (budget.id != null) {
      final tagIds = await (AppDB.instance.select(AppDB.instance.budgetTag)
            ..where((tbl) => tbl.budgetID.equals(budget.id)))
          .map((row) => row.tagID)
          .get();

      if (tagIds.isNotEmpty) {
        tags = await TagService.instance
            .getTags(filter: (tag) => tag.id.isIn(tagIds))
            .first;
      } else {
        tags = null;
      }
    } else {
      tags = null;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? t.budgets.form.edit : t.budgets.form.create),
      ),
      persistentFooterButtons: [
        PersistentFooterButton(
          child: FilledButton.icon(
            onPressed: categories != null && categories!.isEmpty ||
                    (budgetType == 'one-time' &&
                        (endDate == null || !endDate!.isAfter(startDate)))
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      submitForm();
                    }
                  },
            icon: const Icon(Icons.save),
            label:
                Text(isEditMode ? t.budgets.form.edit : t.budgets.form.create),
          ),
        )
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                maxLength: 15,
                validator: (value) => fieldValidator(value, isRequired: true),
                decoration: InputDecoration(
                  labelText: '${t.budgets.form.name} *',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: '${t.budgets.form.value} *',
                  hintText: 'Ex.: 200',
                  suffix: StreamBuilder(
                      stream:
                          CurrencyService.instance.getUserPreferredCurrency(),
                      builder: (context, snapshot) {
                        return Text(snapshot.data?.symbol ?? '');
                      }),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final defaultNumberValidatorResult = fieldValidator(value,
                      isRequired: true, validator: ValidatorType.double);

                  if (defaultNumberValidatorResult != null) {
                    return defaultNumberValidatorResult;
                  }

                  if (valueToNumber! == 0) {
                    return t.transaction.form.validators.zero;
                  }

                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              // Budget Type Dropdown
              DropdownButtonFormField<String>(
                value: budgetType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Orçamento *',
                  helperText: budgetType == 'one-time'
                      ? 'Orçamento com datas específicas de início e fim'
                      : 'Orçamento que se repete periodicamente',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'repeated',
                    child: Text('Recorrente'),
                  ),
                  DropdownMenuItem(
                    value: 'one-time',
                    child: Text('Único'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    budgetType = value!;
                    // If changing to one-time, set intervalPeriod to null
                    if (budgetType == 'one-time') {
                      intervalPeriod = null;
                    } else {
                      // If changing to repeated, set a default intervalPeriod
                      intervalPeriod = Periodicity.month;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              // Show periodicity dropdown only for repeated budgets
              if (budgetType == 'repeated')
                DropdownButtonFormField(
                  value: intervalPeriod,
                  decoration: InputDecoration(
                    labelText: '${t.general.time.periodicity.display} *',
                  ),
                  items: List.generate(
                      Periodicity.values.length,
                      (index) => DropdownMenuItem(
                          value: Periodicity.values[index],
                          child: Text(Periodicity.values[index]
                              .allThePeriodsText(context)))),
                  onChanged: (value) {
                    setState(() {
                      intervalPeriod = value;
                    });
                  },
                ),
              // Show date fields for one-time budgets
              if (budgetType == 'one-time') ...[
                Row(
                  children: [
                    Expanded(
                      child: DateTimeFormField(
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.event),
                          labelText: '${t.general.time.start_date} *',
                        ),
                        mode: DateTimeFieldPickerMode.date,
                        initialDate: startDate,
                        lastDate: endDate,
                        dateFormat: DateFormat.yMMMd(),
                        validator: (e) =>
                            e == null ? t.general.validations.required : null,
                        onDateSelected: (DateTime value) {
                          final adjustedValue = DateTime(
                              value.year, value.month, value.day, 0, 0, 0);
                          setState(() {
                            startDate = adjustedValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DateTimeFormField(
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.event),
                          labelText: '${t.general.time.end_date} *',
                        ),
                        mode: DateTimeFieldPickerMode.date,
                        initialDate: endDate,
                        firstDate: startDate,
                        dateFormat: DateFormat.yMMMd(),
                        validator: (e) =>
                            e == null ? t.general.validations.required : null,
                        onDateSelected: (DateTime value) {
                          final adjustedValue = DateTime(
                              value.year, value.month, value.day, 23, 59, 59);
                          setState(() {
                            endDate = adjustedValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              StreamBuilder(
                stream: AccountService.instance.getAccounts(),
                builder: (context, snapshot) {
                  List<Account>? selectedAccounts = accounts;
                  if (snapshot.hasData) {
                    selectedAccounts = accounts == null
                        ? null
                        : snapshot.data!
                            .where((element) =>
                                accounts!.map((e) => e.id).contains(element.id))
                            .toList();
                  }

                  return ListTileField(
                    title: t.general.accounts,
                    leading: const Icon(Icons.account_balance_rounded),
                    trailing: CountIndicatorWithExpandArrow(
                      countToDisplay: accounts?.length,
                    ),
                    subtitle: accounts != null
                        ? selectedAccounts!.map((e) => e.name).printFormatted()
                        : t.account.select.all,
                    onTap: () => showAccountSelectorBottomSheet(
                        context,
                        AccountSelectorModal(
                          allowMultiSelection: true,
                          filterSavingAccounts: false,
                          selectedAccounts: selectedAccounts ?? [],
                        )).then((selection) {
                      if (selection == null) return;

                      setState(() {
                        accounts = selection.length == snapshot.data!.length
                            ? null
                            : selection;
                      });
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                  stream: CategoryService.instance.getCategories(),
                  builder: (context, snapshot) {
                    List<Category>? selectedCategories = categories;
                    if (snapshot.hasData) {
                      selectedCategories = categories == null
                          ? null
                          : snapshot.data!
                              .where((element) => categories!
                                  .map((e) => e.id)
                                  .contains(element.id))
                              .toList();
                    }

                    return ListTileField(
                      title: t.general.categories,
                      leading: const Icon(Icons.category_rounded),
                      trailing: CountIndicatorWithExpandArrow(
                        countToDisplay: categories?.length,
                      ),
                      subtitle: categories != null
                          ? selectedCategories!
                              .map((e) => e.name)
                              .printFormatted()
                          : t.categories.select.all,
                      onTap: () {
                        showMultiCategoryListModal(
                          context,
                          CategoryMultiSelectorModal(
                            selectedCategories: selectedCategories ?? [],
                          ),
                        ).then((selection) {
                          if (selection == null) return;

                          categories = selection.length == snapshot.data!.length
                              ? null
                              : selection;

                          setState(() {});
                        });
                      },
                    );
                  }),
              const SizedBox(height: 16),
              StreamBuilder<List<Tag>>(
                stream: TagService.instance.getTags(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Get all available tags
                  final allTags = snapshot.data!;

                  // Create a list of currently selected tag IDs
                  final selectedTagIds = tags?.map((t) => t.id).toSet() ?? {};

                  return ListTileField(
                    title: t.tags.display(n: 2),
                    leading: Icon(Tag.icon),
                    trailing: CountIndicatorWithExpandArrow(
                      countToDisplay: tags?.length,
                    ),
                    subtitle: tags == null
                        ? t.account.select.all
                        : (tags!.isEmpty
                            ? t.tags.no_tags
                            : tags!.map((e) => e.name).printFormatted()),
                    onTap: () {
                      showTagListModal(
                        context,
                        modal: TagSelector(
                          selectedTags: tags ?? [],
                          allowEmptySubmit: true,
                          includeNullTag: false,
                        ),
                      ).then((selection) {
                        if (selection == null) return;

                        setState(() {
                          if (selection.isEmpty ||
                              selection.length == allTags.length) {
                            tags = null;
                          } else {
                            tags = selection.cast<Tag>();
                          }
                        });
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
