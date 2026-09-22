//
//  TiCutoutviewModule.swift
//  TiCutoutView
//
//  Copyright (c) 2026 DesignByMind LLC.
//

import TitaniumKit
import UIKit

@objc(TiCutoutviewModule)
class TiCutoutviewModule: TiModule {
  func moduleGUID() -> String {
    return "b7e8bea8-ca9f-4636-87db-f7aed2901594"
  }

  override func moduleId() -> String! {
    return "ti.cutoutview"
  }

  override func startup() {
    super.startup()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var PLACEMENT_TOP_LEFT: String {
    return "topLeft"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var PLACEMENT_TOP: String {
    return "top"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var PLACEMENT_TOP_RIGHT: String {
    return "topRight"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var PLACEMENT_RIGHT: String {
    return "right"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var PLACEMENT_BOTTOM_RIGHT: String {
    return "bottomRight"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var PLACEMENT_BOTTOM: String {
    return "bottom"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var PLACEMENT_BOTTOM_LEFT: String {
    return "bottomLeft"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var PLACEMENT_LEFT: String {
    return "left"
  }

  // Backward-compatible constant from version 0.1.0.
  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var CORNER_BOTTOM_LEFT: String {
    return PLACEMENT_BOTTOM_LEFT
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var SHAPE_CIRCLE: String {
    return "circle"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var SHAPE_RECTANGLE: String {
    return "rectangle"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var MATERIAL_SOLID: String {
    return "solid"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var MATERIAL_BLUR: String {
    return "blur"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var MATERIAL_GLASS: String {
    return "glass"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var GLASS_STYLE_REGULAR: String {
    return "regular"
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc public var GLASS_STYLE_CLEAR: String {
    return "clear"
  }
}
