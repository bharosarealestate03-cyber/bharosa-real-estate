import 'package:cloud_firestore/cloud_firestore.dart';

enum PropertyType { apartment, house, commercial, land }

enum PropertyStatus { forSale, forRent, sold, rented }

extension PropertyTypeExtension on PropertyType {
  String get displayName {
    switch (this) {
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.house:
        return 'House';
      case PropertyType.commercial:
        return 'Commercial';
      case PropertyType.land:
        return 'Land';
    }
  }

  String get value {
    return name;
  }
}

extension PropertyStatusExtension on PropertyStatus {
  String get displayName {
    switch (this) {
      case PropertyStatus.forSale:
        return 'For Sale';
      case PropertyStatus.forRent:
        return 'For Rent';
      case PropertyStatus.sold:
        return 'Sold';
      case PropertyStatus.rented:
        return 'Rented';
    }
  }

  String get value {
    return name;
  }
}

class Review {
  final String userId;
  final String userName;
  final String? userImageUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Review.fromMap(Map<String, dynamic> data) {
    return Review(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userImageUrl: data['userImageUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class PropertyModel {
  final String id;
  final String title;
  final String description;
  final PropertyType type;
  final PropertyStatus status;
  final double price;
  final String location;
  final String city;
  final String state;
  final double? latitude;
  final double? longitude;
  final int? bedrooms;
  final int? bathrooms;
  final double area; // in sq ft
  final List<String> imageUrls;
  final String agentId;
  final String agentName;
  final String? agentPhone;
  final String? agentImageUrl;
  final List<String> amenities;
  final List<Review> reviews;
  final double averageRating;
  final int reviewCount;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.price,
    required this.location,
    required this.city,
    required this.state,
    this.latitude,
    this.longitude,
    this.bedrooms,
    this.bathrooms,
    required this.area,
    List<String>? imageUrls,
    required this.agentId,
    required this.agentName,
    this.agentPhone,
    this.agentImageUrl,
    List<String>? amenities,
    List<Review>? reviews,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : imageUrls = imageUrls ?? [],
        amenities = amenities ?? [],
        reviews = reviews ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PropertyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PropertyModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: PropertyType.values.firstWhere(
        (e) => e.value == (data['type'] ?? 'apartment'),
        orElse: () => PropertyType.apartment,
      ),
      status: PropertyStatus.values.firstWhere(
        (e) => e.value == (data['status'] ?? 'forSale'),
        orElse: () => PropertyStatus.forSale,
      ),
      price: (data['price'] ?? 0.0).toDouble(),
      location: data['location'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      bedrooms: data['bedrooms'],
      bathrooms: data['bathrooms'],
      area: (data['area'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      agentId: data['agentId'] ?? '',
      agentName: data['agentName'] ?? '',
      agentPhone: data['agentPhone'],
      agentImageUrl: data['agentImageUrl'],
      amenities: List<String>.from(data['amenities'] ?? []),
      reviews: (data['reviews'] as List<dynamic>?)
              ?.map((r) => Review.fromMap(r as Map<String, dynamic>))
              .toList() ??
          [],
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.value,
      'status': status.value,
      'price': price,
      'location': location,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'imageUrls': imageUrls,
      'agentId': agentId,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'agentImageUrl': agentImageUrl,
      'amenities': amenities,
      'reviews': reviews.map((r) => r.toMap()).toList(),
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get formattedPrice {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)} Lac';
    } else {
      return '₹${price.toStringAsFixed(0)}';
    }
  }

  PropertyModel copyWith({
    String? id,
    String? title,
    String? description,
    PropertyType? type,
    PropertyStatus? status,
    double? price,
    String? location,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    double? area,
    List<String>? imageUrls,
    String? agentId,
    String? agentName,
    String? agentPhone,
    String? agentImageUrl,
    List<String>? amenities,
    List<Review>? reviews,
    double? averageRating,
    int? reviewCount,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      price: price ?? this.price,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      imageUrls: imageUrls ?? this.imageUrls,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
      agentImageUrl: agentImageUrl ?? this.agentImageUrl,
      amenities: amenities ?? this.amenities,
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
