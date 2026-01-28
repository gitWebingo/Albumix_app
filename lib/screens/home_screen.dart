import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo.dart';
import '../providers/gallery_provider.dart';
import '../widgets/photo_tile.dart';
import 'people_tab.dart';
import 'category_photos_screen.dart';
import 'login_screen.dart';
import 'trash_screen.dart';
import 'favorites_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                elevation: 0,
                centerTitle: false,
                backgroundColor: const Color(0xFF020617),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'Albumix',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 24,
                        ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0F172A), Color(0xFF020617)],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline, size: 20),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TrashScreen()),
                    ),
                  ),
                  PopupMenuButton<SortOption>(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sort_rounded, size: 20),
                    ),
                    onSelected: (option) =>
                        context.read<GalleryProvider>().setSortOption(option),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: SortOption.dateNewest,
                        child: Text("Recent First"),
                      ),
                      const PopupMenuItem(
                        value: SortOption.dateOldest,
                        child: Text("Oldest First"),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded, size: 20),
                    ),
                    onPressed: () async {
                      final provider = context.read<GalleryProvider>();
                      await provider.logout();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                  storageService: provider.storageService)),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w800, letterSpacing: 1),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.w500),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: const UnderlineTabIndicator(
                      borderSide:
                          BorderSide(width: 3, color: Color(0xFF6366F1)),
                      insets: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    tabs: const [
                      Tab(text: 'Photos'),
                      Tab(text: 'Albums'),
                      Tab(text: 'People'),
                      Tab(text: 'Favorites'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Consumer<GalleryProvider>(
            builder: (context, provider, child) {
              return TabBarView(
                children: [
                  const PhotosTab(),
                  const AlbumsTab(),
                  const PeopleTab(),
                  const FavoritesTab(),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () =>
              context.read<GalleryProvider>().pickAndImportPhotos(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('IMPORT'),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF020617),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class PhotosTab extends StatefulWidget {
  const PhotosTab({super.key});

  @override
  State<PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends State<PhotosTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GalleryProvider>().fetchMoreAssets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.photos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final groupedPhotos = provider.photosByMonth;

        if (groupedPhotos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_not_supported_outlined,
                    size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  'No photos yet',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                TextButton(
                  onPressed: () => provider.pickAndImportPhotos(),
                  child: const Text('Import photos'),
                ),
              ],
            ),
          );
        }

        final List<Widget> slivers = [];
        for (var month in groupedPhotos.keys) {
          final monthPhotos = groupedPhotos[month]!;

          // Month Header Sliver
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      month.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Photos Grid Sliver
          slivers.add(
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (context, index) {
                  return PhotoTile(photos: monthPhotos, index: index);
                },
                childCount: monthPhotos.length,
              ),
            ),
          );
        }

        if (provider.isFetchingMore) {
          slivers.add(
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          );
        }

        return CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: slivers,
        );
      },
    );
  }
}

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount:
              categories.length + 1, // +1 for "Create New" or just use logic
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return _buildAddCategoryCard(context);
            }
            final category = categories[index];
            final count = provider.photos
                .whereType<Photo>()
                .where((p) => p.category == category)
                .length;

            final categoryPhotos = provider.photos
                .whereType<Photo>()
                .where((p) => p.category == category);
            final firstPhoto =
                categoryPhotos.isEmpty ? null : categoryPhotos.first;

            return _buildCategoryCard(
                context, category, count, firstPhoto?.path);
          },
        );
      },
    );
  }

  Widget _buildAddCategoryCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showAddCategoryDialog(context);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.create_new_folder_outlined,
                size: 40, color: Colors.white70),
            const SizedBox(height: 8),
            Text(
              'New Album',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String category, int count, String? imagePath) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPhotosScreen(category: category),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null)
              Image.file(
                io.File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[800]),
              )
            else
              Container(
                  color: Colors.grey[850],
                  child: const Icon(Icons.folder,
                      size: 40, color: Colors.white24)),
            Container(color: Colors.black45),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$count photos',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Album'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Album Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<GalleryProvider>().createCategory(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
