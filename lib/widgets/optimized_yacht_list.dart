import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../src/base/yacht/model/yachts_model.dart';

/// Optimized yacht list widget for better performance
class OptimizedYachtList extends StatelessWidget {
  final List<YachtsModel> yachts;
  final Function(YachtsModel) onYachtTap;
  final ScrollController? scrollController;

  const OptimizedYachtList({
    Key? key,
    required this.yachts,
    required this.onYachtTap,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: yachts.length,
      // Add caching for better performance
      cacheExtent: 500,
      itemBuilder: (context, index) {
        final yacht = yachts[index];
        return OptimizedYachtCard(
          yacht: yacht,
          onTap: () => onYachtTap(yacht),
        );
      },
    );
  }
}

/// Optimized yacht card with performance improvements
class OptimizedYachtCard extends StatelessWidget {
  final YachtsModel yacht;
  final VoidCallback onTap;

  const OptimizedYachtCard({
    Key? key,
    required this.yacht,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Optimized image loading
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: yacht.images?.first ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.sailing, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                  memCacheWidth: 160, // Optimize memory usage
                  memCacheHeight: 160,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yacht.name ?? 'Unknown Yacht',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (yacht.location?.address != null)
                      Text(
                        yacht.location!.address!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    if (yacht.price != null)
                      Text(
                        '\$${yacht.price}/day',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Optimized grid view for yacht listings
class OptimizedYachtGrid extends StatelessWidget {
  final List<YachtsModel> yachts;
  final Function(YachtsModel) onYachtTap;
  final ScrollController? scrollController;

  const OptimizedYachtGrid({
    Key? key,
    required this.yachts,
    required this.onYachtTap,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: yachts.length,
      cacheExtent: 800,
      itemBuilder: (context, index) {
        final yacht = yachts[index];
        return OptimizedYachtGridCard(
          yacht: yacht,
          onTap: () => onYachtTap(yacht),
        );
      },
    );
  }
}

class OptimizedYachtGridCard extends StatelessWidget {
  final YachtsModel yacht;
  final VoidCallback onTap;

  const OptimizedYachtGridCard({
    Key? key,
    required this.yacht,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CachedNetworkImage(
                imageUrl: yacht.images?.first ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.sailing, color: Colors.grey, size: 32),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 32),
                  ),
                ),
                memCacheWidth: 300,
                memCacheHeight: 200,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      yacht.name ?? 'Unknown Yacht',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (yacht.price != null)
                      Text(
                        '\$${yacht.price}/day',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}