import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _pageController = PageController();
  bool _showFullDescription = false;
  double _userRating = 0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareProperty() {
    Share.share(
      'Check out this property: ${widget.property.title}\n'
      'Location: ${widget.property.location}, ${widget.property.city}\n'
      'Price: ${widget.property.formattedPrice}\n'
      'Visit Bharosa Real Estate app for more details!',
    );
  }

  Future<void> _submitReview() async {
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to write a review')),
      );
      return;
    }

    final propertyProvider = context.read<PropertyProvider>();
    final success = await propertyProvider.addReview(
      propertyId: widget.property.id,
      userId: authProvider.currentUser!.uid,
      userName: authProvider.currentUser!.name,
      userImageUrl: authProvider.currentUser!.profileImageUrl,
      rating: _userRating,
      comment: _reviewController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _userRating = 0;
        _reviewController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isFav = authProvider.isFavorite(widget.property.id);
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Image Carousel App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF1565C0),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.red : Colors.white,
                    ),
                    onPressed: () =>
                        authProvider.toggleFavorite(widget.property.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    onPressed: _shareProperty,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageCarousel(),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const Divider(height: 32),
                      _buildDetailsSection(),
                      const Divider(height: 32),
                      _buildAmenitiesSection(),
                      const Divider(height: 32),
                      _buildAgentSection(),
                      const Divider(height: 32),
                      _buildDescriptionSection(),
                      if (widget.property.reviews.isNotEmpty) ...[
                        const Divider(height: 32),
                        _buildReviewsSection(),
                      ],
                      const Divider(height: 32),
                      _buildAddReviewSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          bottomNavigationBar: _buildBottomBar(),
        );
      },
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.property.imageUrls;
    if (images.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.home_rounded, size: 80, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (_) => setState(() {}),
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey.shade300),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey, size: 48),
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: images.length,
                effect: const WormEffect(
                  dotColor: Colors.white54,
                  activeDotColor: Colors.white,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.property.type.displayName,
                style: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.property.status == PropertyStatus.forSale
                    ? Colors.green.withAlpha(26)
                    : Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.property.status.displayName,
                style: TextStyle(
                  color: widget.property.status == PropertyStatus.forSale
                      ? Colors.green
                      : Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            if (widget.property.reviewCount > 0) ...[
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 2),
              Text(
                widget.property.averageRating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                ' (${widget.property.reviewCount})',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.property.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${widget.property.location}, ${widget.property.city}, ${widget.property.state}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.property.formattedPrice,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        if (widget.property.status == PropertyStatus.forRent)
          Text(
            'per month',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            if (widget.property.bedrooms != null)
              _buildDetailItem(
                  Icons.bed_outlined, '${widget.property.bedrooms} Bedrooms'),
            if (widget.property.bathrooms != null)
              _buildDetailItem(Icons.bathtub_outlined,
                  '${widget.property.bathrooms} Bathrooms'),
            _buildDetailItem(Icons.square_foot_rounded,
                '${widget.property.area.toInt()} sq ft'),
            _buildDetailItem(
                Icons.calendar_today_outlined,
                DateFormat('MMM yyyy')
                    .format(widget.property.createdAt)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1565C0)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    if (widget.property.amenities.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.property.amenities
              .map((amenity) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 14, color: Color(0xFF1565C0)),
                        const SizedBox(width: 6),
                        Text(
                          amenity,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAgentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Listed By',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF1565C0).withAlpha(51),
                backgroundImage: widget.property.agentImageUrl != null
                    ? CachedNetworkImageProvider(
                        widget.property.agentImageUrl!)
                    : null,
                child: widget.property.agentImageUrl == null
                    ? Text(
                        widget.property.agentName.isNotEmpty
                            ? widget.property.agentName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property.agentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Property Agent',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (widget.property.agentPhone != null) ...[
                IconButton(
                  onPressed: () =>
                      _makePhoneCall(widget.property.agentPhone!),
                  icon: const Icon(Icons.phone, color: Color(0xFF1565C0)),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1565C0).withAlpha(26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      _sendWhatsApp(widget.property.agentPhone!),
                  icon: const Icon(Icons.chat, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withAlpha(26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.property.description,
          style: TextStyle(
            color: Colors.grey.shade700,
            height: 1.6,
          ),
          maxLines: _showFullDescription ? null : 4,
          overflow: _showFullDescription ? null : TextOverflow.ellipsis,
        ),
        if (widget.property.description.length > 200)
          TextButton(
            onPressed: () => setState(
                () => _showFullDescription = !_showFullDescription),
            child: Text(_showFullDescription ? 'Show Less' : 'Read More'),
          ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.property.reviewCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.property.reviews.take(5).map(
              (review) => _buildReviewItem(review),
            ),
      ],
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF1565C0).withAlpha(51),
                backgroundImage: review.userImageUrl != null
                    ? CachedNetworkImageProvider(review.userImageUrl!)
                    : null,
                child: review.userImageUrl == null
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(review.createdAt),
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Colors.amber, size: 16),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write a Review',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: RatingBar.builder(
            initialRating: _userRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 36,
            itemBuilder: (context, _) =>
                const Icon(Icons.star_rounded, color: Colors.amber),
            onRatingUpdate: (rating) => setState(() => _userRating = rating),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reviewController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share your experience with this property...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Submit Review'),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.property.agentPhone != null
                  ? () => _makePhoneCall(widget.property.agentPhone!)
                  : null,
              icon: const Icon(Icons.phone),
              label: const Text('Call Agent'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF1565C0)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.property.agentPhone != null
                  ? () => _sendWhatsApp(widget.property.agentPhone!)
                  : null,
              icon: const Icon(Icons.chat),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
