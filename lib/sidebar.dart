import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Responsive sidebar layout.
///
/// - Narrow screens (< 600dp): `Scaffold` with hamburger menu opening a `Drawer`
/// - Wide screens (>= 600dp): persistent `NavigationRail` on the left
class SidebarLayout extends StatelessWidget {
  const SidebarLayout({super.key, required this.child});

  final Widget child;

  static const _destinations = <_NavDestination>[
    _NavDestination('Dashboard', Icons.dashboard_outlined, Icons.dashboard, '/'),
    _NavDestination('Shopping', Icons.shopping_cart_outlined, Icons.shopping_cart, '/shopping'),
    _NavDestination('Recipes', Icons.restaurant_menu_outlined, Icons.restaurant_menu, '/recipes'),
    _NavDestination('Meal Plan', Icons.calendar_month_outlined, Icons.calendar_month, '/meal-plan'),
    _NavDestination('AI Recipe', Icons.auto_awesome_outlined, Icons.auto_awesome, '/ai-recipe'),
  ];

  int _selectedIndex(String location) {
    // Match the most specific path first.
    for (var i = _destinations.length - 1; i >= 0; i--) {
      final path = _destinations[i].path;
      if (path == '/') {
        if (location == '/') return i;
      } else if (location.startsWith(path)) {
        return i;
      }
    }
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    context.go(_destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final location =
        GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedIndex(location);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) =>
                  _onDestinationSelected(context, i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'GenieHub',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              destinations: _destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Narrow layout with drawer.
    return Scaffold(
      appBar: AppBar(
        title: const Text('GenieHub'),
        centerTitle: true,
      ),
      drawer: NavigationDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) {
          Navigator.of(context).pop(); // close drawer
          _onDestinationSelected(context, i);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
            child: Text(
              'GenieHub',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const Divider(indent: 28, endIndent: 28),
          ..._destinations.map(
            (d) => NavigationDrawerDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: Text(d.label),
            ),
          ),
        ],
      ),
      body: child,
    );
  }
}

class _NavDestination {
  const _NavDestination(this.label, this.icon, this.selectedIcon, this.path);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}
