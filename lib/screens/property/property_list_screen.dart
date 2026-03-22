import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet(BuildContext context) {
    final propertyProvider = context.read<PropertyProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...SortOption.values.map((option) {
                return ListTile(
                  leading: Radio<SortOption>(
                    value: option,
                    groupValue: propertyProvider.sortOption,
                    onChanged: (value) {
                      if (value != null) {
                        propertyProvider.setSortOption(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text(option.displayName),
                  onTap: () {
                    propertyProvider.setSortOption(option);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final propertyProvider = context.read<PropertyProvider>();
    PropertyFilter tempFilter = propertyProvider.filter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Properties',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() =>
                                  tempFilter = const PropertyFilter());
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // Property Type
                            const Text(
                              'Property Type',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: PropertyType.values.map((type) {
                                final isSelected = tempFilter.type == type;
                                return FilterChip(
                                  label: Text(type.displayName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempFilter = PropertyFilter(
                                        type: selected ? type : null,
                                        status: tempFilter.status,
                                        minPrice: tempFilter.minPrice,
                                        maxPrice: tempFilter.maxPrice,
                                        minArea: tempFilter.minArea,
                                        maxArea: tempFilter.maxArea,
                                        minBedrooms: tempFilter.minBedrooms,
                                        city: tempFilter.city,
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // Status
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: PropertyStatus.values.map((status) {
                                final isSelected = tempFilter.status == status;
                                return FilterChip(
                                  label: Text(status.displayName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempFilter = PropertyFilter(
                                        type: tempFilter.type,
                                        status: selected ? status : null,
                                        minPrice: tempFilter.minPrice,
                                        maxPrice: tempFilter.maxPrice,
                                        minArea: tempFilter.minArea,
                                        maxArea: tempFilter.maxArea,
                                        minBedrooms: tempFilter.minBedrooms,
                                        city: tempFilter.city,
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // Bedrooms
                            const Text(
                              'Minimum Bedrooms',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [1, 2, 3, 4, 5].map((beds) {
                                final isSelected =
                                    tempFilter.minBedrooms == beds;
                                return FilterChip(
                                  label: Text('$beds+ BHK'),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempFilter = PropertyFilter(
                                        type: tempFilter.type,
                                        status: tempFilter.status,
                                        minPrice: tempFilter.minPrice,
                                        maxPrice: tempFilter.maxPrice,
                                        minArea: tempFilter.minArea,
                                        maxArea: tempFilter.maxArea,
                                        minBedrooms: selected ? beds : null,
                                        city: tempFilter.city,
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            propertyProvider.setFilter(tempFilter);
                            Navigator.pop(context);
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, _) {
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 180,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                final name =
                                    authProvider.currentUser?.name ?? 'Guest';
                                return Text(
                                  'Hello, ${name.split(' ').first}! 👋',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                            const Text(
                              'Find Your Dream Home',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Search Bar
                            TextField(
                              controller: _searchController,
                              onChanged: propertyProvider.setSearchQuery,
                              decoration: InputDecoration(
                                hintText: 'Search city, location or property...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.grey),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            color: Colors.grey),
                                        onPressed: () {
                                          _searchController.clear();
                                          propertyProvider.setSearchQuery('');
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                title: const Text('Bharosa Real Estate'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => _showFilterBottomSheet(context),
                    tooltip: 'Filter',
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort_rounded),
                    onPressed: () => _showSortBottomSheet(context),
                    tooltip: 'Sort',
                  ),
                ],
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: _buildFilterChips(propertyProvider),
              ),

              // Property Count & Sort Info
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${propertyProvider.filteredProperties.length} Properties',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        propertyProvider.sortOption.displayName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Featured Properties
              if (propertyProvider.featuredProperties.isNotEmpty &&
                  propertyProvider.searchQuery.isEmpty &&
                  !propertyProvider.filter.hasActiveFilters)
                ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Featured Properties',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildFeaturedProperties(
                        propertyProvider.featuredProperties),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        'All Properties',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

              // Property List
              if (propertyProvider.isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPropertyCardSkeleton(),
                    childCount: 5,
                  ),
                )
              else if (propertyProvider.filteredProperties.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(propertyProvider),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final property =
                            propertyProvider.filteredProperties[index];
                        return _buildPropertyCard(context, property);
                      },
                      childCount: propertyProvider.filteredProperties.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(PropertyProvider propertyProvider) {
    if (!propertyProvider.filter.hasActiveFilters) return const SizedBox();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (propertyProvider.filter.type != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(propertyProvider.filter.type!.displayName),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  propertyProvider.setFilter(PropertyFilter(
                    status: propertyProvider.filter.status,
                    minPrice: propertyProvider.filter.minPrice,
                    maxPrice: propertyProvider.filter.maxPrice,
                    minArea: propertyProvider.filter.minArea,
                    maxArea: propertyProvider.filter.maxArea,
                    minBedrooms: propertyProvider.filter.minBedrooms,
                    city: propertyProvider.filter.city,
                  ));
                },
              ),
            ),
          if (propertyProvider.filter.status != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(propertyProvider.filter.status!.displayName),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  propertyProvider.setFilter(PropertyFilter(
                    type: propertyProvider.filter.type,
                    minPrice: propertyProvider.filter.minPrice,
                    maxPrice: propertyProvider.filter.maxPrice,
                    minArea: propertyProvider.filter.minArea,
                    maxArea: propertyProvider.filter.maxArea,
                    minBedrooms: propertyProvider.filter.minBedrooms,
                    city: propertyProvider.filter.city,
                  ));
                },
              ),
            ),
          if (propertyProvider.filter.minBedrooms != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${propertyProvider.filter.minBedrooms}+ BHK'),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  propertyProvider.setFilter(PropertyFilter(
                    type: propertyProvider.filter.type,
                    status: propertyProvider.filter.status,
                    minPrice: propertyProvider.filter.minPrice,
                    maxPrice: propertyProvider.filter.maxPrice,
                    minArea: propertyProvider.filter.minArea,
                    maxArea: propertyProvider.filter.maxArea,
                    city: propertyProvider.filter.city,
                  ));
                },
              ),
            ),
          TextButton.icon(
            onPressed: propertyProvider.clearFilter,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProperties(List<PropertyModel> featured) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final property = featured[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PropertyDetailScreen(property: property),
                ),
              );
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(31),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    property.imageUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: property.imageUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey.shade300,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.home, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.home,
                                color: Colors.grey, size: 48),
                          ),
                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(179),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            property.formattedPrice,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Featured badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyModel property) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isFav = authProvider.isFavorite(property.id);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PropertyDetailScreen(property: property),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: property.imageUrls.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: property.imageUrls.first,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.home_rounded,
                                  color: Colors.grey,
                                  size: 64,
                                ),
                              ),
                      ),
                    ),
                    // Status badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: property.status == PropertyStatus.forSale
                              ? Colors.green
                              : property.status == PropertyStatus.forRent
                                  ? Colors.blue
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          property.status.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Favorite Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => authProvider.toggleFavorite(property.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(31),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFav ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    // Image count
                    if (property.imageUrls.length > 1)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_library_outlined,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '${property.imageUrls.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withAlpha(26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          property.type.displayName,
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${property.location}, ${property.city}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Features Row
                      Row(
                        children: [
                          if (property.bedrooms != null) ...[
                            _buildFeatureItem(
                              Icons.bed_outlined,
                              '${property.bedrooms} Beds',
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (property.bathrooms != null) ...[
                            _buildFeatureItem(
                              Icons.bathtub_outlined,
                              '${property.bathrooms} Baths',
                            ),
                            const SizedBox(width: 12),
                          ],
                          _buildFeatureItem(
                            Icons.square_foot_rounded,
                            '${property.area.toInt()} sq ft',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            property.formattedPrice,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          if (property.reviewCount > 0)
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 2),
                                Text(
                                  property.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  ' (${property.reviewCount})',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildEmptyState(PropertyProvider propertyProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Properties Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            propertyProvider.filter.hasActiveFilters
                ? 'Try adjusting your filters'
                : 'No properties available at the moment',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          if (propertyProvider.filter.hasActiveFilters)
            OutlinedButton.icon(
              onPressed: propertyProvider.clearFilter,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          TextButton.icon(
            onPressed: propertyProvider.fetchProperties,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
