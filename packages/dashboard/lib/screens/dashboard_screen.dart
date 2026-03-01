import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

/// The home screen that aggregates widgets from all feature modules.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    this.onNavigateToShopping,
    this.onNavigateToShoppingList,
    this.onNavigateToShoppingMode,
    this.onNavigateToMealPlan,
    this.onNavigateToAddRecipe,
    this.onNavigateToRecipes,
    this.onNavigateToAiRecipe,
  });

  final VoidCallback? onNavigateToShopping;
  final ValueChanged<String>? onNavigateToShoppingList;
  final ValueChanged<String>? onNavigateToShoppingMode;
  final VoidCallback? onNavigateToMealPlan;
  final VoidCallback? onNavigateToAddRecipe;
  final VoidCallback? onNavigateToRecipes;
  final VoidCallback? onNavigateToAiRecipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isFree = user.tier == UserTier.free;

    return Scaffold(
      backgroundColor: Colors.transparent, // Shell sets the background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _DashboardHeader(user: user, isFree: isFree),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Banner
                    const _AdBanner(),
                    const SizedBox(height: 24),

                    // Meal Plan section
                    _DashboardMealPlan(onTap: onNavigateToMealPlan),
                    const SizedBox(height: 24),

                    // Shared List section
                    _DashboardSharedList(onTap: onNavigateToShopping),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header matching the HTML design.
///
/// Subscribed users see their profile avatar + name.
/// Free users see a hamburger button that opens the shell's drawer.
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.user, required this.isFree});

  final AppUser user;
  final bool isFree;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          if (isFree)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menu',
            )
          else ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
                image: DecorationImage(
                  image: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : const NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDRgzGsuefOUERK2U6-Sahns0RuKNXmzuJl0VXrHlIaF4CAF8x5_iwYgwiFLkpaLI9r8XS6zp8oq_HYcCrLowEy88k7ZgsDDxcMEg5c3pKSsrUaTeH_OlK1FELgBD32v7bFhvsd392gp1GlPDu4fI6Rrs_KqG1yF_7rcNBOdk7MRAbVtLJanWa4ZdL0vXoro4OG2XMjFLUtSygKmb4HIQxfc4Xgzq8874HzluKApoLyhvNtZ9uj26b88MOo_YuI7g10BqiwlwPeX4w',
                        ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFree)
                  Text(
                    user.displayName.isEmpty ? 'The Smiths' : user.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                Text(
                  'Family Hub',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(icon: Icons.chat_bubble_outline, onPressed: () {}),
          const SizedBox(width: 8),
          _HeaderIconButton(
            icon: Icons.notifications_none,
            onPressed: () {},
            showBadge: true,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, size: 24),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        if (showBadge)
          Positioned(
            top: 8,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red.shade500,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AdBanner extends StatelessWidget {
  const _AdBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 88,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF1F5F9), // slate-800 / slate-100
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF475569)
              : const Color(0xFFCBD5E1), // slate-600 / slate-300
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.ads_click,
            size: 48,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          Text(
            'ADVERTISEMENT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: isDark
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8), // slate-500 / slate-400
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMealPlan extends StatelessWidget {
  const _DashboardMealPlan({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Family Meal Plan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Edit Plan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Days Row
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = index == 0;
              final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
              final dates = ['24', '25', '26', '27', '28', '29', '30'];

              return Container(
                width: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                      ),
                    ),
                    Text(
                      dates[index],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Main Card
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image part
              SizedBox(
                height: 128,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAE-ksEzq0s-UKvMWPfnZlFw1CkXFaBlH4QaD6fKMCDe6c4hZRwTASwhm_aVN3dykpjVLZ3ahY4uqcqObiex0Z6nYT5FW1kFQuK6qvukwc0thEzOvWVrWCXLSOw0WZWMaLvB6bVhMd88i8i45A52bqteZReguZeA0TZEfwY8_0Awzc2qgMX6jko6KpJPJCyoqu9w_gjD_BcSPlS6TKWc5xHJLnnRTHccZE-jGyX7Cl-pCB3sVgtXKdMWY93C_EGu2Ik8ZCeIXa6_IA',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.fastfood, color: Colors.white),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          'Dinner • 7:00 PM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 16,
                      left: 16,
                      child: Text(
                        'Fried Chicken & Slaw',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Details part
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.pink.shade100,
                          child: Text(
                            'L',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Requested by '),
                              TextSpan(
                                text: 'Lily (Daughter)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155).withValues(alpha: 0.5)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tomorrow\'s Request',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFE2E8F0)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Grilled Fish & Chips',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Requested by Noah (Son)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardSharedList extends StatelessWidget {
  const _DashboardSharedList({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_cart,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Shared List',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 56, // For overlapping avatars
                  height: 24,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: _Avatar(color: Colors.purple, initial: 'M'),
                      ),
                      Positioned(
                        left: 16,
                        child: _Avatar(color: Colors.blue, initial: 'D'),
                      ),
                      Positioned(
                        left: 32,
                        child: _Avatar(color: Colors.pink, initial: 'L'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              _SharedListItem(
                title: 'Watermelon',
                isDone: true,
                avatar: _Avatar(color: Colors.pink, initial: 'L', size: 16),
                addedBy: 'Added by Lily',
              ),
              const Divider(height: 24),
              _SharedListItem(
                title: 'Cooking Oil',
                isDone: false,
                avatar: const Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: Colors.orange,
                ),
                addedBy: 'Added by AI from Meal Plan',
              ),
              const Divider(height: 24),
              _SharedListItem(
                title: 'Milk',
                isDone: false,
                avatar: _Avatar(color: Colors.blue, initial: 'D', size: 16),
                addedBy: 'Added by Dad',
              ),
              const Divider(height: 24),
              Opacity(
                opacity: 0.5,
                child: _SharedListItem(
                  title: 'Bread',
                  isDone: true,
                  avatar: _Avatar(color: Colors.purple, initial: 'M', size: 16),
                  addedBy: 'Added by Mom',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SharedListItem extends StatelessWidget {
  const _SharedListItem({
    required this.title,
    required this.isDone,
    required this.avatar,
    required this.addedBy,
  });

  final String title;
  final bool isDone;
  final Widget avatar;
  final String addedBy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: isDone,
            onChanged: (_) {},
            activeColor: AppColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDone
                      ? const Color(0xFF94A3B8)
                      : (isDark
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFF334155)),
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  avatar,
                  const SizedBox(width: 6),
                  Text(
                    addedBy,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.color, required this.initial, this.size = 24});
  final MaterialColor color;
  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.shade100,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: color.shade600,
        ),
      ),
    );
  }
}
