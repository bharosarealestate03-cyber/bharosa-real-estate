import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';

enum SortOption {
  priceAsc,
  priceDesc,
  newest,
  oldest,
  areaAsc,
  areaDesc,
  rating,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.priceAsc:
        return 'Price: Low to High';
      case SortOption.priceDesc:
        return 'Price: High to Low';
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.areaAsc:
        return 'Area: Small to Large';
      case SortOption.areaDesc:
        return 'Area: Large to Small';
      case SortOption.rating:
        return 'Best Rated';
    }
  }
}

class PropertyFilter {
  final PropertyType? type;
  final PropertyStatus? status;
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final int? minBedrooms;
  final String? city;

  const PropertyFilter({
    this.type,
    this.status,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.minBedrooms,
    this.city,
  });

  bool get hasActiveFilters =>
      type != null ||
      status != null ||
      minPrice != null ||
      maxPrice != null ||
      minArea != null ||
      maxArea != null ||
      minBedrooms != null ||
      city != null;

  PropertyFilter copyWith({
    PropertyType? type,
    PropertyStatus? status,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? minBedrooms,
    String? city,
  }) {
    return PropertyFilter(
      type: type ?? this.type,
      status: status ?? this.status,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      city: city ?? this.city,
    );
  }
}

class PropertyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<PropertyModel> _allProperties = [];
  List<PropertyModel> _filteredProperties = [];
  List<PropertyModel> _featuredProperties = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;
  PropertyFilter _filter = const PropertyFilter();

  List<PropertyModel> get allProperties => _allProperties;
  List<PropertyModel> get filteredProperties => _filteredProperties;
  List<PropertyModel> get featuredProperties => _featuredProperties;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  PropertyFilter get filter => _filter;

  PropertyProvider() {
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('properties')
          .orderBy('createdAt', descending: true)
          .get();

      _allProperties =
          snapshot.docs.map((doc) => PropertyModel.fromFirestore(doc)).toList();

      _featuredProperties =
          _allProperties.where((p) => p.isFeatured).toList();

      _applyFiltersAndSort();
    } catch (e) {
      _errorMessage = 'Failed to load properties. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PropertyModel?> getPropertyById(String id) async {
    // Check in-memory first
    final cached = _allProperties.where((p) => p.id == id).firstOrNull;
    if (cached != null) return cached;

    try {
      final doc = await _firestore.collection('properties').doc(id).get();
      if (doc.exists) {
        return PropertyModel.fromFirestore(doc);
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return null;
  }

  Future<List<PropertyModel>> getFavoriteProperties(
      List<String> propertyIds) async {
    if (propertyIds.isEmpty) return [];

    try {
      final favorites = _allProperties
          .where((p) => propertyIds.contains(p.id))
          .toList();

      if (favorites.length == propertyIds.length) return favorites;

      // Fetch from Firestore if not all in cache
      final docs = await Future.wait(
        propertyIds.map((id) => _firestore.collection('properties').doc(id).get()),
      );

      return docs
          .where((doc) => doc.exists)
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFiltersAndSort();
  }

  void setFilter(PropertyFilter filter) {
    _filter = filter;
    _applyFiltersAndSort();
  }

  void clearFilter() {
    _filter = const PropertyFilter();
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    var results = List<PropertyModel>.from(_allProperties);

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.location.toLowerCase().contains(query) ||
            p.city.toLowerCase().contains(query) ||
            p.state.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply filters
    if (_filter.type != null) {
      results = results.where((p) => p.type == _filter.type).toList();
    }
    if (_filter.status != null) {
      results = results.where((p) => p.status == _filter.status).toList();
    }
    if (_filter.minPrice != null) {
      results = results.where((p) => p.price >= _filter.minPrice!).toList();
    }
    if (_filter.maxPrice != null) {
      results = results.where((p) => p.price <= _filter.maxPrice!).toList();
    }
    if (_filter.minArea != null) {
      results = results.where((p) => p.area >= _filter.minArea!).toList();
    }
    if (_filter.maxArea != null) {
      results = results.where((p) => p.area <= _filter.maxArea!).toList();
    }
    if (_filter.minBedrooms != null) {
      results = results
          .where((p) => (p.bedrooms ?? 0) >= _filter.minBedrooms!)
          .toList();
    }
    if (_filter.city != null && _filter.city!.isNotEmpty) {
      results = results
          .where((p) =>
              p.city.toLowerCase() == _filter.city!.toLowerCase())
          .toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.priceAsc:
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.newest:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.areaAsc:
        results.sort((a, b) => a.area.compareTo(b.area));
        break;
      case SortOption.areaDesc:
        results.sort((a, b) => b.area.compareTo(a.area));
        break;
      case SortOption.rating:
        results.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
    }

    _filteredProperties = results;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReview({
    required String propertyId,
    required String userId,
    required String userName,
    String? userImageUrl,
    required double rating,
    required String comment,
  }) async {
    try {
      final review = Review(
        userId: userId,
        userName: userName,
        userImageUrl: userImageUrl,
        rating: rating,
        comment: comment,
      );

      final propertyRef = _firestore.collection('properties').doc(propertyId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(propertyRef);
        if (!snapshot.exists) return;

        final property = PropertyModel.fromFirestore(snapshot);
        final reviews = List<Review>.from(property.reviews)..add(review);
        final newCount = reviews.length;
        final newAverage =
            reviews.fold(0.0, (acc, r) => acc + r.rating) / newCount;

        transaction.update(propertyRef, {
          'reviews': reviews.map((r) => r.toMap()).toList(),
          'reviewCount': newCount,
          'averageRating': newAverage,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      // Refresh local data
      await fetchProperties();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
