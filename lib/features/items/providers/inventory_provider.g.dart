// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the local database interface.

@ProviderFor(localDatabase)
final localDatabaseProvider = LocalDatabaseProvider._();

/// Provider for the local database interface.

final class LocalDatabaseProvider
    extends $FunctionalProvider<ILocalDatabase, ILocalDatabase, ILocalDatabase>
    with $Provider<ILocalDatabase> {
  /// Provider for the local database interface.
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

String _$localDatabaseHash() => r'e810ee54c5c05c87fbca199a4a80aee472bb970c';

/// Provider for the embedding engine interface.

@ProviderFor(embeddingEngine)
final embeddingEngineProvider = EmbeddingEngineProvider._();

/// Provider for the embedding engine interface.

final class EmbeddingEngineProvider
    extends
        $FunctionalProvider<
          IEmbeddingEngine,
          IEmbeddingEngine,
          IEmbeddingEngine
        >
    with $Provider<IEmbeddingEngine> {
  /// Provider for the embedding engine interface.
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

String _$embeddingEngineHash() => r'b1d2074dc555a46d979a84eaa5c65946c150b4e2';

/// Provider for the object detection interface.

@ProviderFor(objectDetectionEngine)
final objectDetectionEngineProvider = ObjectDetectionEngineProvider._();

/// Provider for the object detection interface.

final class ObjectDetectionEngineProvider
    extends
        $FunctionalProvider<
          IObjectDetectionEngine,
          IObjectDetectionEngine,
          IObjectDetectionEngine
        >
    with $Provider<IObjectDetectionEngine> {
  /// Provider for the object detection interface.
  ObjectDetectionEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'objectDetectionEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$objectDetectionEngineHash();

  @$internal
  @override
  $ProviderElement<IObjectDetectionEngine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IObjectDetectionEngine create(Ref ref) {
    return objectDetectionEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IObjectDetectionEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IObjectDetectionEngine>(value),
    );
  }
}

String _$objectDetectionEngineHash() =>
    r'c90219cb2a88e9eacc00aa43b2bd4bc3b714b97f';

/// Provider for the vision LLM interface.

@ProviderFor(visionLLMEngine)
final visionLLMEngineProvider = VisionLLMEngineProvider._();

/// Provider for the vision LLM interface.

final class VisionLLMEngineProvider
    extends
        $FunctionalProvider<
          IVisionLLMEngine,
          IVisionLLMEngine,
          IVisionLLMEngine
        >
    with $Provider<IVisionLLMEngine> {
  /// Provider for the vision LLM interface.
  VisionLLMEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visionLLMEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visionLLMEngineHash();

  @$internal
  @override
  $ProviderElement<IVisionLLMEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IVisionLLMEngine create(Ref ref) {
    return visionLLMEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IVisionLLMEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IVisionLLMEngine>(value),
    );
  }
}

String _$visionLLMEngineHash() => r'cf76d18720ef93c1d06174c0e2dc2e13ee708a77';

/// The main controller for managing inventory items.

@ProviderFor(Inventory)
final inventoryProvider = InventoryProvider._();

/// The main controller for managing inventory items.
final class InventoryProvider extends $AsyncNotifierProvider<Inventory, void> {
  /// The main controller for managing inventory items.
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

String _$inventoryHash() => r'f3b029194599aafa80694ca58c2e47fd7775e7f5';

/// The main controller for managing inventory items.

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
