import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final String selectedStatusFilter;
  final String selectedSortBy;
  final bool isSortAscending;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;
  final ValueChanged<String> onSortByChanged;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedStatusFilter,
    required this.selectedSortBy,
    required this.isSortAscending,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onSortByChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input + Sort Dropdown Row
        Row(
          children: [
            // Search Input Field
            Expanded(
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryDarkGreen),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => onSearchChanged(''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Sort Menu Popup
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: PopupMenuButton<String>(
                icon: Row(
                  children: [
                    const Icon(Icons.sort, color: AppColors.primaryDarkGreen, size: 20),
                    Icon(
                      isSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: AppColors.primaryGold,
                    ),
                  ],
                ),
                tooltip: 'Sort Options',
                onSelected: onSortByChanged,
                itemBuilder: (context) => [
                  _sortItem('name', 'Sort by Name'),
                  _sortItem('amountDue', 'Sort by Amount Due'),
                  _sortItem('amountPaid', 'Sort by Amount Paid'),
                  _sortItem('status', 'Sort by Payment Status'),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Filter Choice Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text(
                'Filter: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              _filterChip('All', 'All Members'),
              const SizedBox(width: 6),
              _filterChip('Paid', 'Paid', dotColor: AppColors.statusPaidDot),
              const SizedBox(width: 6),
              _filterChip('Partial', 'Partial Payment', dotColor: AppColors.statusPartialDot),
              const SizedBox(width: 6),
              _filterChip('Unpaid', 'Unpaid', dotColor: AppColors.statusUnpaidDot),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _sortItem(String value, String label) {
    final isSelected = selectedSortBy == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
            ),
          ),
          if (isSelected)
            Icon(
              isSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: AppColors.primaryGold,
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label, {Color? dotColor}) {
    final isSelected = selectedStatusFilter == filterKey;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selectedColor: AppColors.primaryDarkGreen,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primaryDarkGreen : AppColors.cardBorder,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => onStatusFilterChanged(filterKey),
    );
  }
}
