// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the local database interface.
/// In the main.dart file, we will override this with our ObjectBox implementation.

@ProviderFor(localDatabase)
final localDatabaseProvider = LocalDatabaseProvider._();

/// Provider for the local database interface.
/// In the main.dart file, we will override this with our ObjectBox implementation.

final class LocalDatabaseProvider
    extends $FunctionalProvider<ILocalDatabase, ILocalDatabase, ILocalDatabase>
    with $Provider<ILocalDatabase> {
  /// Provider for the local database interface.
  /// In the main.dart file, we will override this with our ObjectBox implementation.
  LocalDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDatabaseHash();

  @$internal
  @override
  $ProviderElement<ILocalDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ILocalDatabase create(Ref ref) {
    return localDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ILocalDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ILocalDatabase>(value),
    );
  }
}

String _$localDatabaseHash() => r'4dd5917ad1ea108c99f0df15b4c405c8cc6ec1e0';

/// Provider for the embedding engine interface.
/// In the main.dart file, we will override this with our TFLite implementation.

@ProviderFor(embeddingEngine)
final embeddingEngineProvider = EmbeddingEngineProvider._();

/// Provider for the embedding engine interface.
/// In the main.dart file, we will override this with our TFLite implementation.

final class EmbeddingEngineProvider
    extends
        $FunctionalProvider<
          IEmbeddingEngine,
          IEmbeddingEngine,
          IEmbeddingEngine
        >
    with $Provider<IEmbeddingEngine> {
  /// Provider for the embedding engine interface.
  /// In the main.dart file, we will override this with our TFLite implementation.
  EmbeddingEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'embeddingEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$embeddingEngineHash();

  @$internal
  @override
  $ProviderElement<IEmbeddingEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IEmbeddingEngine create(Ref ref) {
    return embeddingEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IEmbeddingEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IEmbeddingEngine>(value),
    );
  }
}

String _$embeddingEngineHash() => r'81054e612eaa3fe9930bbb9b46d46bbf045703c7';

/// The main controller for managing inventory items.
/// It uses the abstract interfaces, ensuring it never touches ObjectBox or TFLite directly.

@ProviderFor(Inventory)
final inventoryProvider = InventoryProvider._();

/// The main controller for managing inventory items.
/// It uses the abstract interfaces, ensuring it never touches ObjectBox or TFLite directly.
final class InventoryProvider extends $AsyncNotifierProvider<Inventory, void> {
  /// The main controller for managing inventory items.
  /// It uses the abstract interfaces, ensuring it never touches ObjectBox or TFLite directly.
  InventoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryHash();

  @$internal
  @override
  Inventory create() => Inventory();
}

String _$inventoryHash() => r'a33a6714517303dadd0e16a69b8520fd88cb0dfe';

/// The main controller for managing inventory items.
/// It uses the abstract interfaces, ensuring it never touches ObjectBox or TFLite directly.

abstract class _$Inventory extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
