import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.airport_shuttle),
          activeIcon: Icon(Icons.airport_shuttle),
          label: 'Vans',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_gas_station_outlined),
          activeIcon: Icon(Icons.local_gas_station),
          label: 'Fuel',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_2_outlined),
          activeIcon: Icon(Icons.qr_code_2),
          label: 'Fuel Pass',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
