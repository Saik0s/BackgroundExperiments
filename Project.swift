//
// Project.swift
//

import ProjectDescription

let project = Project(
  name: "BackgroundExperiments",

  options: .options(
    textSettings: .textSettings(
      indentWidth: 2,
      tabWidth: 2
    )
  ),

  settings: .settings(
    base: SettingsDictionary().automaticCodeSigning(devTeam: "8A76N862C8"),
    defaultSettings: .recommended
  ),

  targets: [
    // MARK: - App

    .target(
      name: "BackgroundExperimentsApp",
      destinations: .iOS,
      product: .app,
      bundleId: "me.igortarasenko.BackgroundExperimentsApp",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .extendingDefault(
        with: [
          "UILaunchStoryboardName": "LaunchScreen.storyboard",
          "NSSupportsLiveActivities": true,
          "UIBackgroundModes": [
            "audio",
            "processing",
            "remote-notification",
          ],
          "BGTaskSchedulerPermittedIdentifiers": [
            "$(PRODUCT_BUNDLE_IDENTIFIER)",
          ],
        ]
      ),
      sources: "App/Sources/**",
      resources: "App/Resources/**",
      entitlements: .dictionary([
        "aps-environment": "development",
        "com.apple.security.application-groups": "group.me.igortarasenko.BackgroundExperimentsApp",
      ]),
      dependencies: [
        .target(name: "ProgressWidget"),
        .target(name: "Common"),
      ]
    ),
    .target(
      name: "ProgressWidget",
      destinations: .iOS,
      product: .appExtension,
      bundleId: "me.igortarasenko.BackgroundExperimentsApp.ProgressWidget",
      infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "$(PRODUCT_NAME)",
        "NSSupportsLiveActivities": true,
        "NSExtension": [
          "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
        ],
      ]),
      sources: "ProgressWidget/Sources/**",
      resources: "ProgressWidget/Resources/**",
      entitlements: .dictionary([
        "aps-environment": "development",
        "com.apple.security.application-groups": "group.me.igortarasenko.BackgroundExperimentsApp",
      ]),
      dependencies: [
        .target(name: "Common"),
      ]
    ),
    .target(
      name: "Common",
      destinations: .iOS,
      product: .framework,
      productName: "Common",
      bundleId: "me.igortarasenko.BackgroundExperimentsApp.Common",
      deploymentTargets: .iOS("17.0"),
      sources: "Common/Sources/**",
      resources: "Common/Resources/**"
    ),
  ]
)
