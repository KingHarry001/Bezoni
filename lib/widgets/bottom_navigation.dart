import 'package:flutter/material.dart';
import 'package:bezoni/core/navigation_service.dart';
import 'package:bezoni/components/cart_notifier.dart';
import 'package:bezoni/themes/theme_extensions.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartNotifier(),
      builder: (context, _) {
        final cartNotifier = CartNotifier();

        return Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            border: Border(
              top: BorderSide(
                color: context.dividerColor.withOpacity(0.5),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: context.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    Icons.home_outlined,
                    Icons.home,
                    'Home',
                    NavigationService.HOME_INDEX,
                  ),
                  _buildNavItem(
                    context,
                    Icons.search,
                    Icons.search,
                    'Search',
                    NavigationService.SEARCH_INDEX,
                  ),
                  _buildNavItem(
                    context,
                    Icons.shopping_cart_outlined,
                    Icons.shopping_cart,
                    'Cart',
                    NavigationService.CART_INDEX,
                    badge: cartNotifier.itemCount > 0
                        ? cartNotifier.itemCount.toString()
                        : null,
                  ),
                  _buildNavItem(
                    context,
                    Icons.chat_bubble_outline,
                    Icons.chat_bubble,
                    'Messages',
                    NavigationService.MESSAGES_INDEX,
                  ),
                  _buildNavItem(
                    context,
                    Icons.person_outline,
                    Icons.person,
                    'Profile',
                    NavigationService.PROFILE_INDEX,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    IconData selectedIcon,
    String label,
    int index, {
    String? badge,
  }) {
    final bool isSelected = index == currentIndex;
    final navigationService = NavigationService();

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            navigationService.navigateToTab(context, index);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      size: 24,
                      color: isSelected
                          ? context.primaryColor
                          : context.subtitleColor,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: BoxDecoration(
                          color: context.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? context.primaryColor
                      : context.subtitleColor,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}