// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:flutter_tools/src/base/logger.dart';
import 'package:flutter_tools/src/isolated/native_assets/native_assets.dart';
import 'package:flutter_tools/src/resident_runner.dart';
import 'package:flutter_tools/src/run_hot.dart';
import 'package:native_assets_builder/native_assets_builder.dart'
    as native_assets_builder;
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:package_config/package_config_types.dart';

/// Mocks all logic instead of using `package:native_assets_builder`, which
/// relies on doing process calls to `pub` and the local file system.
class FakeNativeAssetsBuildRunner implements NativeAssetsBuildRunner {
  FakeNativeAssetsBuildRunner({
    this.hasPackageConfigResult = true,
    this.packagesWithNativeAssetsResult = const <Package>[],
    this.dryRunResult = const FakeNativeAssetsBuilderResult(),
    this.buildResult = const FakeNativeAssetsBuilderResult(),
    CCompilerConfig? cCompilerConfigResult,
    CCompilerConfig? ndkCCompilerConfigResult,
  })  : cCompilerConfigResult = cCompilerConfigResult ?? CCompilerConfig(),
        ndkCCompilerConfigResult = ndkCCompilerConfigResult ?? CCompilerConfig();

  final native_assets_builder.BuildResult buildResult;
  final native_assets_builder.DryRunResult dryRunResult;
  final bool hasPackageConfigResult;
  final List<Package> packagesWithNativeAssetsResult;
  final CCompilerConfig cCompilerConfigResult;
  final CCompilerConfig ndkCCompilerConfigResult;

  int buildInvocations = 0;
  int dryRunInvocations = 0;
  int hasPackageConfigInvocations = 0;
  int packagesWithNativeAssetsInvocations = 0;

  @override
  Future<native_assets_builder.BuildResult> build({
    required bool includeParentEnvironment,
    required BuildMode buildMode,
    required LinkModePreference linkModePreference,
    required Target target,
    required Uri workingDirectory,
    CCompilerConfig? cCompilerConfig,
    int? targetAndroidNdkApi,
    IOSSdk? targetIOSSdk,
  }) async {
    buildInvocations++;
    return buildResult;
  }

  @override
  Future<native_assets_builder.DryRunResult> dryRun({
    required bool includeParentEnvironment,
    required LinkModePreference linkModePreference,
    required OS targetOS,
    required Uri workingDirectory,
  }) async {
    dryRunInvocations++;
    return dryRunResult;
  }

  @override
  Future<bool> hasPackageConfig() async {
    hasPackageConfigInvocations++;
    return hasPackageConfigResult;
  }

  @override
  Future<List<Package>> packagesWithNativeAssets() async {
    packagesWithNativeAssetsInvocations++;
    return packagesWithNativeAssetsResult;
  }

  @override
  Future<CCompilerConfig> get cCompilerConfig async => cCompilerConfigResult;

  @override
  Future<CCompilerConfig> get ndkCCompilerConfig async => cCompilerConfigResult;
}

final class FakeNativeAssetsBuilderResult
    implements native_assets_builder.BuildResult {
  const FakeNativeAssetsBuilderResult({
    this.assets = const <Asset>[],
    this.dependencies = const <Uri>[],
    this.success = true,
  });

  @override
  final List<Asset> assets;

  @override
  final List<Uri> dependencies;

  @override
  final bool success;
}

class FakeHotRunnerNativeAssetsBuilder implements HotRunnerNativeAssetsBuilder {
  FakeHotRunnerNativeAssetsBuilder(this.buildRunner);

  final NativeAssetsBuildRunner buildRunner;

  @override
  Future<Uri?> dryRun({
    required Uri projectUri,
    required FileSystem fileSystem,
    required List<FlutterDevice> flutterDevices,
    required PackageConfig packageConfig,
    required Logger logger,
  }) {
    return dryRunNativeAssets(
      projectUri: projectUri,
      fileSystem: fileSystem,
      buildRunner: buildRunner,
      flutterDevices: flutterDevices,
    );
  }
}
