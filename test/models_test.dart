import 'package:flutter_test/flutter_test.dart';
import 'package:bharosa_real_estate/models/property_model.dart';
import 'package:bharosa_real_estate/models/user_model.dart';

void main() {
  group('PropertyModel', () {
    test('formattedPrice returns crores for large amount', () {
      final property = _buildProperty(price: 15000000);
      expect(property.formattedPrice, contains('Cr'));
    });

    test('formattedPrice returns lakhs for medium amount', () {
      final property = _buildProperty(price: 5500000);
      expect(property.formattedPrice, contains('Lac'));
    });

    test('formattedPrice returns raw price for small amount', () {
      final property = _buildProperty(price: 50000);
      expect(property.formattedPrice, startsWith('₹'));
    });

    test('copyWith creates a new instance with updated fields', () {
      final property = _buildProperty(price: 1000000);
      final updated = property.copyWith(price: 2000000, title: 'New Title');
      expect(updated.price, 2000000);
      expect(updated.title, 'New Title');
      expect(updated.id, property.id);
    });

    test('PropertyType displayName is correct', () {
      expect(PropertyType.apartment.displayName, 'Apartment');
      expect(PropertyType.house.displayName, 'House');
      expect(PropertyType.commercial.displayName, 'Commercial');
      expect(PropertyType.land.displayName, 'Land');
    });

    test('PropertyStatus displayName is correct', () {
      expect(PropertyStatus.forSale.displayName, 'For Sale');
      expect(PropertyStatus.forRent.displayName, 'For Rent');
      expect(PropertyStatus.sold.displayName, 'Sold');
      expect(PropertyStatus.rented.displayName, 'Rented');
    });
  });

  group('UserModel', () {
    test('UserModel creates with defaults', () {
      final user = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        email: 'test@example.com',
        phone: '+919876543210',
        userType: 'buyer',
      );
      expect(user.favoriteProperties, isEmpty);
      expect(user.userType, 'buyer');
    });

    test('copyWith creates updated user model', () {
      final user = UserModel(
        uid: 'uid',
        name: 'Original',
        email: 'test@example.com',
        phone: '1234567890',
        userType: 'buyer',
      );
      final updated = user.copyWith(name: 'Updated', bio: 'New bio');
      expect(updated.name, 'Updated');
      expect(updated.bio, 'New bio');
      expect(updated.uid, user.uid);
    });

    test('toFirestore returns correct map', () {
      final user = UserModel(
        uid: 'uid',
        name: 'Test',
        email: 'test@example.com',
        phone: '1234567890',
        userType: 'agent',
      );
      final map = user.toFirestore();
      expect(map['name'], 'Test');
      expect(map['email'], 'test@example.com');
      expect(map['userType'], 'agent');
    });
  });

  group('Review', () {
    test('Review.fromMap creates correctly', () {
      final map = {
        'userId': 'u1',
        'userName': 'Alice',
        'rating': 4.5,
        'comment': 'Great property!',
      };
      final review = Review.fromMap(map);
      expect(review.userId, 'u1');
      expect(review.rating, 4.5);
      expect(review.comment, 'Great property!');
    });

    test('Review.toMap returns correct map', () {
      final review = Review(
        userId: 'u1',
        userName: 'Bob',
        rating: 3.5,
        comment: 'Good location',
      );
      final map = review.toMap();
      expect(map['userId'], 'u1');
      expect(map['rating'], 3.5);
    });
  });
}

PropertyModel _buildProperty({double price = 1000000}) {
  return PropertyModel(
    id: 'test-id',
    title: 'Test Property',
    description: 'A test property description',
    type: PropertyType.apartment,
    status: PropertyStatus.forSale,
    price: price,
    location: 'Test Location',
    city: 'Mumbai',
    state: 'Maharashtra',
    area: 1200,
    agentId: 'agent-1',
    agentName: 'Test Agent',
  );
}
