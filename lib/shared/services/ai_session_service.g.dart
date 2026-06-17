// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_session_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiSessionServiceHash() => r'a7359be0a2371648e9f1884d79a2af5a55437e39';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [aiSessionService].
@ProviderFor(aiSessionService)
const aiSessionServiceProvider = AiSessionServiceFamily();

/// See also [aiSessionService].
class AiSessionServiceFamily extends Family<AiSessionService> {
  /// See also [aiSessionService].
  const AiSessionServiceFamily();

  /// See also [aiSessionService].
  AiSessionServiceProvider call(String sessionKey) {
    return AiSessionServiceProvider(sessionKey);
  }

  @override
  AiSessionServiceProvider getProviderOverride(
    covariant AiSessionServiceProvider provider,
  ) {
    return call(provider.sessionKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'aiSessionServiceProvider';
}

/// See also [aiSessionService].
class AiSessionServiceProvider extends AutoDisposeProvider<AiSessionService> {
  /// See also [aiSessionService].
  AiSessionServiceProvider(String sessionKey)
    : this._internal(
        (ref) => aiSessionService(ref as AiSessionServiceRef, sessionKey),
        from: aiSessionServiceProvider,
        name: r'aiSessionServiceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$aiSessionServiceHash,
        dependencies: AiSessionServiceFamily._dependencies,
        allTransitiveDependencies:
            AiSessionServiceFamily._allTransitiveDependencies,
        sessionKey: sessionKey,
      );

  AiSessionServiceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionKey,
  }) : super.internal();

  final String sessionKey;

  @override
  Override overrideWith(
    AiSessionService Function(AiSessionServiceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AiSessionServiceProvider._internal(
        (ref) => create(ref as AiSessionServiceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionKey: sessionKey,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AiSessionService> createElement() {
    return _AiSessionServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AiSessionServiceProvider && other.sessionKey == sessionKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AiSessionServiceRef on AutoDisposeProviderRef<AiSessionService> {
  /// The parameter `sessionKey` of this provider.
  String get sessionKey;
}

class _AiSessionServiceProviderElement
    extends AutoDisposeProviderElement<AiSessionService>
    with AiSessionServiceRef {
  _AiSessionServiceProviderElement(super.provider);

  @override
  String get sessionKey => (origin as AiSessionServiceProvider).sessionKey;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
