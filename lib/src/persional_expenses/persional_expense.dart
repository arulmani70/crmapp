import 'package:crmapp/src/persional_expenses/view/desktop/persional_expenses_desktop.dart';
import 'package:crmapp/src/persional_expenses/view/mobile/persional_expenses_mobile.dart';
import 'package:crmapp/src/persional_expenses/view/tablet/persional_expenses_tablet.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PersionalExpenses extends StatelessWidget {
  const PersionalExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveValue<Widget>(
      context,
      defaultValue: PersionalExpensesDesktop(),
      conditionalValues: [
        const Condition.equals(name: TABLET, value: PersionalExpensesTablet()),
        const Condition.smallerThan(
          name: MOBILE,
          value: PersionalExpensesMobile(),
        ),
      ],
    ).value;
  }
}
