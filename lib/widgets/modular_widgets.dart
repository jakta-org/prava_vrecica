import 'package:flutter/material.dart';
import 'package:prava_vrecica/fun/fun_widgets.dart';
import '../documents/document_widgets.dart';
import '../statistics/stats_widgets.dart';
import 'info_widgets.dart';
import 'misc_widgets.dart';

abstract class ModularWidgets {
  static Map<String, Function> interactiveWidgets = {
    "statistics_chart": barChart,
    "manual_add_statistics": (state) => (ObjectEntryWidget(state: state)),
    "fun_facts": (state) => const FunFactsWidget(),
    "generate_order": (state) => const GenerateOrderWidget(),
  };

  static Map<String, Function> infoWidgets = {
    "author_info": authorInfoOverview,
    "objects_overview": objectsOverview,
  };

  static Map<String, Function> miscWidgets = {
    "generate_ticket": (state) => createTicketButton(state),
  };

  static List<Widget> getWidgetList(WidgetType type, State state, List<String> accepted) {
    List<Widget> rList = [];
    if (type == WidgetType.interactive) {
      for (String widgetKey in interactiveWidgets.keys) {
        if (accepted.contains(widgetKey)) {
          rList.add(interactiveWidgets[widgetKey]!(state));
        }
      }
    } else if (type == WidgetType.info) {
      for (String widgetKey in infoWidgets.keys) {
        if (accepted.contains(widgetKey)) {
          rList.add(infoWidgets[widgetKey]!(state));
        }
      }
    }

    return rList;
  }
}

enum WidgetType {
  interactive,
  info,
  misc
}