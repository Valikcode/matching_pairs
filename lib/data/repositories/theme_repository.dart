import 'package:matching_pairs/data/models/theme_pack.dart';
import 'package:matching_pairs/data/sources/theme_local_cache.dart';
import 'package:matching_pairs/data/sources/theme_remote_source.dart';

class ThemeRepository {
  final ThemeRemoteSource remoteSource;
  final ThemeLocalCache localCache;

  ThemeRepository({ThemeRemoteSource? remoteSource, ThemeLocalCache? localCache})
    : remoteSource = remoteSource ?? ThemeRemoteSource(),
      localCache = localCache ?? ThemeLocalCache();

  Future<List<ThemePack>> getThemes({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await localCache.getThemes();
      if (cached.isNotEmpty) return cached;
    }

    try {
      final remote = await remoteSource.fetchThemes();
      if (remote.isNotEmpty) {
        await localCache.saveThemes(remote);
        return remote;
      }
    } catch (_) {}

    return await localCache.getThemes();
  }
}
