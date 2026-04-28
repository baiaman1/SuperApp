import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:superapp_mobile/core/models/app_models.dart';
import 'package:superapp_mobile/core/network/api_exception.dart';
import 'package:superapp_mobile/core/utils/formatters.dart';
import 'package:superapp_mobile/features/home/app_controller.dart';

part 'home_page_parts/home_sections.dart';
part 'home_page_parts/home_overview.dart';
part 'home_page_parts/home_composer.dart';
part 'home_page_parts/home_management.dart';
part 'home_page_parts/home_accounts.dart';
part 'home_page_parts/home_analytics.dart';
part 'home_page_parts/home_transaction_sheet.dart';
part 'home_page_parts/home_support.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.controller.homeData;
    final pages = [
      _HomeSection(
        controller: widget.controller,
        child: _AddFlowTab(controller: widget.controller),
      ),
      _HomeSection(
        controller: widget.controller,
        child: _AccountsManagerTab(controller: widget.controller),
      ),
      _HomeSection(
        controller: widget.controller,
        child: _ReportsTab(controller: widget.controller),
      ),
      _HomeSection(
        controller: widget.controller,
        child: _HistoryTab(controller: widget.controller),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: data == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(controller: widget.controller),
                        const SizedBox(height: 16),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: widget.controller.refreshHome,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 120),
                              children: [
                                if (widget.controller.homeError != null) ...[
                                  _InfoBanner(
                                    message: widget.controller.homeError!,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                _EmptyState(controller: widget.controller),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : IndexedStack(index: _pageIndex, children: pages),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        onDestinationSelected: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Счета',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats_rounded),
            label: 'Аналитика',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'История',
          ),
        ],
      ),
    );
  }
}

enum _FilterPeriod { day, month, year, custom }

enum _HistoryEntryFilter { all, income, expense }

class _HomeSection extends StatelessWidget {
  const _HomeSection({required this.controller, required this.child});

  final AppController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(controller: controller),
        const SizedBox(height: 16),
        if (controller.homeError != null) ...[
          _InfoBanner(message: controller.homeError!),
          const SizedBox(height: 16),
        ],
        Expanded(child: child),
      ],
    );
  }
}
