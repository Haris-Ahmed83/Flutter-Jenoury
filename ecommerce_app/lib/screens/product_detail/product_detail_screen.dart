import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../utils/helpers.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isInCart = cart.isInCart(widget.product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryBadge(),
                  const SizedBox(height: 12),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildRatingRow(),
                  const SizedBox(height: 20),
                  _buildPriceRow(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                  const SizedBox(height: 16),
                  _buildTotalRow(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(isInCart),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFFF8F9FA),
          child: Hero(
            tag: 'product_${widget.product.id}',
            child: CachedNetworkImage(
              imageUrl: widget.product.image,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.image_not_supported_outlined,
                size: 64,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        Helpers.capitalizeEachWord(widget.product.category),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.product.title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
        height: 1.3,
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final rating = widget.product.rating.rate;
          if (index < rating.floor()) {
            return const Icon(Icons.star, color: AppTheme.starColor, size: 20);
          } else if (index < rating.ceil() && rating % 1 != 0) {
            return const Icon(Icons.star_half,
                color: AppTheme.starColor, size: 20);
          }
          return const Icon(Icons.star_border,
              color: AppTheme.starColor, size: 20);
        }),
        const SizedBox(width: 8),
        Text(
          '${widget.product.rating.rate}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${widget.product.rating.count} reviews)',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          Helpers.formatCurrency(widget.product.price),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'In Stock',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(
              () => _isDescriptionExpanded = !_isDescriptionExpanded),
          child: AnimatedCrossFade(
            firstChild: Text(
              widget.product.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
            secondChild: Text(
              widget.product.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
            crossFadeState: _isDescriptionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ),
        if (widget.product.description.length > 100)
          GestureDetector(
            onTap: () => setState(
                () => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _isDescriptionExpanded ? 'Read less' : 'Read more',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildQtyButton(Icons.remove, () {
                if (_quantity > 1) setState(() => _quantity--);
              }),
              Container(
                width: 48,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildQtyButton(Icons.add, () {
                setState(() => _quantity++);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 20, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            Helpers.formatCurrency(widget.product.price * _quantity),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isInCart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.bottomBarShadow,
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              final cart =
                  Provider.of<CartProvider>(context, listen: false);
              cart.addToCart(widget.product, quantity: _quantity);
              Helpers.showSnackBar(
                context,
                '${widget.product.title} added to cart',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isInCart ? AppTheme.accentColor : AppTheme.primaryColor,
            ),
            child: Text(
              isInCart ? 'Update Cart' : 'Add to Cart',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
