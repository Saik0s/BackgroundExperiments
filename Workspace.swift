//
// Workspace.swift
//

import ProjectDescription

let workspace = Workspace(
  name: "BackgroundExperiments",
  projects: ["."],
  generationOptions: .options(
    lastXcodeUpgradeCheck: Version(15, 3, 0)
  )
)
