//
//  TiCutoutviewViewProxy.swift
//  TiCutoutView
//
//  Copyright (c) 2026 DesignByMind LLC.
//

import QuartzCore
import TitaniumKit
import UIKit

private func tiCutoutviewDictionary(_ value: Any?) -> [String: Any]? {
  if let dictionary = value as? [String: Any] {
    return dictionary
  }

  if let dictionary = value as? [AnyHashable: Any] {
    var result = [String: Any]()
    for (key, value) in dictionary {
      result[String(describing: key)] = value
    }
    return result
  }

  return nil
}

private func tiCutoutviewSize(_ value: Any?, fallback: CGSize) -> CGSize {
  if let dictionary = tiCutoutviewDictionary(value) {
    return CGSize(
      width: max(0, CGFloat(TiUtils.doubleValue(dictionary["width"], def: Double(fallback.width)))),
      height: max(
        0,
        CGFloat(TiUtils.doubleValue(dictionary["height"], def: Double(fallback.height)))
      )
    )
  }

  let side = max(0, CGFloat(TiUtils.doubleValue(value, def: Double(fallback.width))))
  return CGSize(width: side, height: side)
}

private enum TiCutoutviewPlacement: String {
  case topLeft
  case top
  case topRight
  case right
  case bottomRight
  case bottom
  case bottomLeft
  case left

  static func from(_ value: Any?, fallback: TiCutoutviewPlacement = .bottomLeft)
    -> TiCutoutviewPlacement
  {
    guard let name = TiUtils.stringValue(value) else {
      return fallback
    }

    return TiCutoutviewPlacement(rawValue: name) ?? fallback
  }

  var isCorner: Bool {
    switch self {
    case .topLeft, .topRight, .bottomRight, .bottomLeft:
      return true
    case .top, .right, .bottom, .left:
      return false
    }
  }
}

private enum TiCutoutviewShape: String {
  case circle
  case rectangle

  static func from(_ value: Any?, fallback: TiCutoutviewShape = .circle) -> TiCutoutviewShape {
    guard let name = TiUtils.stringValue(value) else {
      return fallback
    }

    if name == "square" {
      return .rectangle
    }

    return TiCutoutviewShape(rawValue: name) ?? fallback
  }
}

private enum TiCutoutviewMaterial: String {
  case solid
  case blur
  case glass

  static func from(_ value: Any?, fallback: TiCutoutviewMaterial = .solid) -> TiCutoutviewMaterial {
    guard let name = TiUtils.stringValue(value) else {
      return fallback
    }

    if name == "liquidGlass" {
      return .glass
    }

    return TiCutoutviewMaterial(rawValue: name) ?? fallback
  }
}

private enum TiCutoutviewAnimationTiming: String {
  case linear
  case easeIn
  case easeOut
  case easeInOut
  case spring

  static func from(_ value: Any?) -> TiCutoutviewAnimationTiming {
    guard let name = TiUtils.stringValue(value) else {
      return .easeInOut
    }

    return TiCutoutviewAnimationTiming(rawValue: name) ?? .easeInOut
  }
}

private struct TiCutoutviewCornerRadii {
  var topLeft: CGFloat = 0
  var topRight: CGFloat = 0
  var bottomRight: CGFloat = 0
  var bottomLeft: CGFloat = 0

  static func from(_ value: Any?) -> TiCutoutviewCornerRadii {
    if let dictionary = tiCutoutviewDictionary(value) {
      return TiCutoutviewCornerRadii(
        topLeft: nonnegative(dictionary["topLeft"]),
        topRight: nonnegative(dictionary["topRight"]),
        bottomRight: nonnegative(dictionary["bottomRight"]),
        bottomLeft: nonnegative(dictionary["bottomLeft"])
      )
    }

    let radius = nonnegative(value)
    return TiCutoutviewCornerRadii(
      topLeft: radius,
      topRight: radius,
      bottomRight: radius,
      bottomLeft: radius
    )
  }

  func mirroredHorizontally() -> TiCutoutviewCornerRadii {
    return TiCutoutviewCornerRadii(
      topLeft: topRight,
      topRight: topLeft,
      bottomRight: bottomLeft,
      bottomLeft: bottomRight
    )
  }

  func mirroredVertically() -> TiCutoutviewCornerRadii {
    return TiCutoutviewCornerRadii(
      topLeft: bottomLeft,
      topRight: bottomRight,
      bottomRight: topRight,
      bottomLeft: topLeft
    )
  }

  private static func nonnegative(_ value: Any?) -> CGFloat {
    return max(0, CGFloat(TiUtils.doubleValue(value, def: 0)))
  }
}

private struct TiCutoutviewShapeState {
  var placement: TiCutoutviewPlacement = .bottomLeft
  var shape: TiCutoutviewShape = .circle
  var radius: CGFloat = 54
  var size = CGSize(width: 108, height: 108)
  var cornerRadius: CGFloat = 0
  var centerOffset = CGPoint.zero
  var smoothing: CGFloat = 12
  var alignment: CGFloat = 0.5

  func interpolated(to target: TiCutoutviewShapeState, progress: CGFloat)
    -> TiCutoutviewShapeState
  {
    let amount = progress

    if placement != target.placement || shape != target.shape {
      if amount < 0.5 {
        let phase = amount * 2
        return TiCutoutviewShapeState(
          placement: placement,
          shape: shape,
          radius: radius + (0 - radius) * phase,
          size: CGSize(
            width: size.width + (0 - size.width) * phase,
            height: size.height + (0 - size.height) * phase
          ),
          cornerRadius: cornerRadius + (0 - cornerRadius) * phase,
          centerOffset: centerOffset,
          smoothing: smoothing + (0 - smoothing) * phase,
          alignment: alignment
        )
      }

      let phase = (amount - 0.5) * 2
      return TiCutoutviewShapeState(
        placement: target.placement,
        shape: target.shape,
        radius: target.radius * phase,
        size: CGSize(width: target.size.width * phase, height: target.size.height * phase),
        cornerRadius: target.cornerRadius * phase,
        centerOffset: target.centerOffset,
        smoothing: target.smoothing * phase,
        alignment: target.alignment
      )
    }

    return TiCutoutviewShapeState(
      placement: target.placement,
      shape: target.shape,
      radius: radius + (target.radius - radius) * amount,
      size: CGSize(
        width: size.width + (target.size.width - size.width) * amount,
        height: size.height + (target.size.height - size.height) * amount
      ),
      cornerRadius: cornerRadius + (target.cornerRadius - cornerRadius) * amount,
      centerOffset: CGPoint(
        x: centerOffset.x + (target.centerOffset.x - centerOffset.x) * amount,
        y: centerOffset.y + (target.centerOffset.y - centerOffset.y) * amount
      ),
      smoothing: smoothing + (target.smoothing - smoothing) * amount,
      alignment: alignment + (target.alignment - alignment) * amount
    )
  }
}

private struct TiCutoutviewAnimationContext {
  let start: TiCutoutviewShapeState
  let target: TiCutoutviewShapeState
  let duration: TimeInterval
  let timing: TiCutoutviewAnimationTiming
  let dampingRatio: CGFloat
  let initialVelocity: CGFloat
  let generation: Int
  var startTime: CFTimeInterval?
}

private final class TiCutoutviewContentView: UIView {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    return hitView === self ? nil : hitView
  }
}

@objc(TiCutoutviewViewProxy)
class TiCutoutviewViewProxy: TiViewProxy {
  override func newView() -> TiUIView! {
    return TiCutoutviewView(frame: .zero)
  }

  @objc(animateCutout:)
  func animateCutout(_ argument: Any?) {
    let value = (argument as? [Any])?.first ?? argument
    guard let options = tiCutoutviewDictionary(value) else {
      NSLog("[TiCutoutView] animateCutout expects an options dictionary")
      return
    }

    for key in [
      "cutoutPlacement", "cutoutShape", "cutoutRadius", "cutoutSize", "cutoutCornerRadius",
      "cutoutCenterOffset", "cutoutSmoothing", "cutoutAlignment",
    ] {
      if let propertyValue = options[key] {
        replaceValue(propertyValue, forKey: key, notification: false)
      }
    }

    DispatchQueue.main.async { [weak self] in
      guard let self = self, let cutoutView = self.view as? TiCutoutviewView else {
        return
      }

      self.fireEvent("cutoutanimationstart", with: ["options": options])
      cutoutView.animateCutout(options: options) { [weak self] payload in
        self?.fireEvent("cutoutanimationcomplete", with: payload)
      }
    }
  }
}

@objc(TiCutoutviewView)
class TiCutoutviewView: TiUIView {
  private let shadowShapeLayer = CAShapeLayer()
  private let fillShapeLayer = CAShapeLayer()
  private let borderShapeLayer = CAShapeLayer()
  private let contentMaskLayer = CAShapeLayer()
  private let effectMaskLayer = CAShapeLayer()
  private let solidMaterialView = UIView(frame: .zero)
  private let effectMaterialView = UIView(frame: .zero)
  private let contentContainer = TiCutoutviewContentView(frame: .zero)
  private let borderOverlayView = UIView(frame: .zero)

  private var effectView: UIVisualEffectView?
  private var installedContentContainer = false
  private var currentPath: UIBezierPath?
  private var shapeState = TiCutoutviewShapeState()
  private var cornerRadii = TiCutoutviewCornerRadii()

  private var material = TiCutoutviewMaterial.solid
  private var blurStyleRawValue = UIBlurEffect.Style.systemMaterial.rawValue
  private var glassStyleName = "regular"
  private var glassTintColor: UIColor?
  private var glassInteractive = false

  private var fillColor = UIColor.white
  private var shapeBorderColor = UIColor.clear
  private var shapeBorderWidth: CGFloat = 0
  private var shapeShadowColor = UIColor.black
  private var shapeShadowOpacity: Float = 0
  private var shapeShadowRadius: CGFloat = 0
  private var shapeShadowOffset = CGSize.zero
  private var clipsContentToShape = true
  private var usesShapeAwareHitTesting = true

  private var animationGeneration = 0
  private var animationContext: TiCutoutviewAnimationContext?
  private var animationCompletion: (([String: Any]) -> Void)?
  private var displayLink: CADisplayLink?

  deinit {
    displayLink?.invalidate()
  }

  override func initializeState() {
    super.initializeState()

    backgroundColor = .clear
    clipsToBounds = false

    shadowShapeLayer.fillColor = UIColor.clear.cgColor
    shadowShapeLayer.shadowColor = shapeShadowColor.cgColor
    shadowShapeLayer.shadowOpacity = shapeShadowOpacity
    shadowShapeLayer.shadowRadius = shapeShadowRadius
    shadowShapeLayer.shadowOffset = shapeShadowOffset
    shadowShapeLayer.masksToBounds = false
    layer.insertSublayer(shadowShapeLayer, at: 0)

    solidMaterialView.backgroundColor = .clear
    solidMaterialView.isUserInteractionEnabled = false
    fillShapeLayer.fillColor = fillColor.cgColor
    solidMaterialView.layer.addSublayer(fillShapeLayer)
    super.addSubview(solidMaterialView)

    effectMaterialView.backgroundColor = .clear
    effectMaterialView.isUserInteractionEnabled = false
    effectMaskLayer.fillColor = UIColor.white.cgColor
    effectMaterialView.layer.mask = effectMaskLayer
    super.addSubview(effectMaterialView)

    contentContainer.backgroundColor = .clear
    contentContainer.clipsToBounds = false
    installedContentContainer = true
    super.addSubview(contentContainer)

    borderOverlayView.backgroundColor = .clear
    borderOverlayView.isUserInteractionEnabled = false
    borderShapeLayer.fillColor = UIColor.clear.cgColor
    borderShapeLayer.strokeColor = shapeBorderColor.cgColor
    borderShapeLayer.lineWidth = shapeBorderWidth
    borderShapeLayer.lineJoin = .round
    borderOverlayView.layer.addSublayer(borderShapeLayer)
    super.addSubview(borderOverlayView)

    updateMaterial()
    updateShape()
  }

  override func addSubview(_ view: UIView) {
    guard installedContentContainer, !isInternalView(view) else {
      super.addSubview(view)
      return
    }

    contentContainer.addSubview(view)
  }

  override func insertSubview(_ view: UIView, at index: Int) {
    guard installedContentContainer, !isInternalView(view) else {
      super.insertSubview(view, at: index)
      return
    }

    contentContainer.insertSubview(view, at: min(index, contentContainer.subviews.count))
  }

  override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
    guard installedContentContainer, !isInternalView(view) else {
      super.insertSubview(view, aboveSubview: siblingSubview)
      return
    }

    if siblingSubview.superview === contentContainer {
      contentContainer.insertSubview(view, aboveSubview: siblingSubview)
    } else {
      contentContainer.addSubview(view)
    }
  }

  override func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
    guard installedContentContainer, !isInternalView(view) else {
      super.insertSubview(view, belowSubview: siblingSubview)
      return
    }

    if siblingSubview.superview === contentContainer {
      contentContainer.insertSubview(view, belowSubview: siblingSubview)
    } else {
      contentContainer.addSubview(view)
    }
  }

  override func frameSizeChanged(_ frame: CGRect, bounds: CGRect) {
    super.frameSizeChanged(frame, bounds: bounds)
    updateShape()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    prepareRootLayerForShapeShadow()
    updateShape()
  }

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    guard super.point(inside: point, with: event) else {
      return false
    }

    guard usesShapeAwareHitTesting, let currentPath = currentPath else {
      return true
    }

    return currentPath.contains(point)
  }

  override func touchedContentView(with event: UIEvent!) -> Bool {
    if material == .glass, glassInteractive, let effectView = effectView,
      let touches = event?.allTouches
    {
      for touch in touches {
        guard let touchedView = touch.view else {
          continue
        }

        if touchedView === effectView || touchedView.isDescendant(of: effectView) {
          return true
        }
      }
    }

    return super.touchedContentView(with: event)
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCutoutPlacement_:)
  func setCutoutPlacement_(_ value: Any?) {
    cancelCutoutAnimation(notify: true)
    shapeState.placement = TiCutoutviewPlacement.from(value, fallback: shapeState.placement)
    updateShape()
  }

  // Backward-compatible alias from version 0.1.0.
  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCutoutCorner_:)
  func setCutoutCorner_(_ value: Any?) {
    setCutoutPlacement_(value)
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCutoutRadius_:)
  func setCutoutRadius_(_ value: Any?) {
    cancelCutoutAnimation(notify: true)
    shapeState.radius = max(0, CGFloat(TiUtils.doubleValue(value, def: 54)))
    updateShape()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCutoutShape_:)
  func setCutoutShape_(_ value: Any?) {
    cancelCutoutAnimation(notify: true)
    shapeState.shape = TiCutoutviewShape.from(value, fallback: shapeState.shape)
    updateShape()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCutoutSize_:)
  func setCutoutSize_(_ value: Any?) {
    cancelCutoutAnimation(notify: true)
    shapeState.size = tiCutoutviewSize(value, fallback: shapeState.size)
    updateShape()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCutoutCornerRadius_:)
  func setCutoutCornerRadius_(_ value: Any?) {
    cancelCutoutAnimation(notify: true)
    shapeState.cornerRadius = max(0, CGFloat(TiUtils.doubleValue(value, def: 0)))
    updateShape()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCutoutCenterOffset_:)
  func setCutoutCenterOffset_(_ value: Any?) {
    cancelCutoutAnimation(notify: true)
    shapeState.centerOffset = TiUtils.pointValue(value)
    updateShape()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCutoutSmoothing_:)
  func setCutoutSmoothing_(_ value: Any?) {
    cancelCutoutAnimation(notify: true)
    shapeState.smoothing = max(0, CGFloat(TiUtils.doubleValue(value, def: 12)))
    updateShape()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCutoutAlignment_:)
  func setCutoutAlignment_(_ value: Any?) {
    cancelCutoutAnimation(notify: true)
    shapeState.alignment = min(1, max(0, CGFloat(TiUtils.doubleValue(value, def: 0.5))))
    updateShape()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setMaterial_:)
  func setMaterial_(_ value: Any?) {
    material = TiCutoutviewMaterial.from(value, fallback: material)
    updateMaterial()
    updateAppearance()
    updateShape()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setBlurStyle_:)
  func setBlurStyle_(_ value: Any?) {
    blurStyleRawValue = Int(
      TiUtils.intValue(value, def: Int32(UIBlurEffect.Style.systemMaterial.rawValue)))
    updateMaterial()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setGlassStyle_:)
  func setGlassStyle_(_ value: Any?) {
    let requestedStyle = TiUtils.stringValue(value) ?? "regular"
    glassStyleName = requestedStyle == "clear" ? "clear" : "regular"
    updateMaterial()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setGlassTintColor_:)
  func setGlassTintColor_(_ value: Any?) {
    glassTintColor = TiUtils.colorValue(value)?.color
    updateMaterial()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setGlassInteractive_:)
  func setGlassInteractive_(_ value: Any?) {
    glassInteractive = TiUtils.boolValue(value, def: false)
    updateMaterial()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setFillColor_:)
  func setFillColor_(_ value: Any?) {
    fillColor = TiUtils.colorValue(value)?.color ?? .clear
    updateAppearance()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setCornerRadius_:)
  func setCornerRadius_(_ value: Any?) {
    cornerRadii = TiCutoutviewCornerRadii.from(value)
    updateShape()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setBorderColor_:)
  func setBorderColor_(_ value: Any?) {
    shapeBorderColor = TiUtils.colorValue(value)?.color ?? .clear
    updateAppearance()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setBorderWidth_:)
  func setBorderWidth_(_ value: Any?) {
    shapeBorderWidth = max(0, CGFloat(TiUtils.doubleValue(value, def: 0)))
    updateAppearance()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setShadowColor_:)
  func setShadowColor_(_ value: Any?) {
    shapeShadowColor = TiUtils.colorValue(value)?.color ?? .clear
    updateAppearance()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setShadowOpacity_:)
  func setShadowOpacity_(_ value: Any?) {
    shapeShadowOpacity = Float(min(1, max(0, TiUtils.doubleValue(value, def: 0))))
    updateAppearance()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setShadowRadius_:)
  func setShadowRadius_(_ value: Any?) {
    shapeShadowRadius = max(0, CGFloat(TiUtils.doubleValue(value, def: 0)))
    updateAppearance()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setShadowOffset_:)
  func setShadowOffset_(_ value: Any?) {
    let point = TiUtils.pointValue(value)
    shapeShadowOffset = CGSize(width: point.x, height: point.y)
    updateAppearance()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setClipContentToShape_:)
  func setClipContentToShape_(_ value: Any?) {
    clipsContentToShape = TiUtils.boolValue(value, def: true)
    updateContentMask()
  }

  // swift-format-ignore: AlwaysUseLowerCamelCase
  @objc(setShapeAwareHitTesting_:)
  func setShapeAwareHitTesting_(_ value: Any?) {
    usesShapeAwareHitTesting = TiUtils.boolValue(value, def: true)
  }

  func animateCutout(options: [String: Any], completion: @escaping ([String: Any]) -> Void) {
    cancelCutoutAnimation(notify: true)

    var target = shapeState
    if let placement = options["cutoutPlacement"] ?? options["placement"] {
      target.placement = TiCutoutviewPlacement.from(placement, fallback: target.placement)
    }
    if let shape = options["cutoutShape"] ?? options["shape"] {
      target.shape = TiCutoutviewShape.from(shape, fallback: target.shape)
    }
    if let radius = options["cutoutRadius"] ?? options["radius"] {
      target.radius = max(0, CGFloat(TiUtils.doubleValue(radius, def: Double(target.radius))))
    }
    if let size = options["cutoutSize"] ?? options["size"] {
      target.size = tiCutoutviewSize(size, fallback: target.size)
    }
    if let cornerRadius = options["cutoutCornerRadius"] ?? options["shapeCornerRadius"] {
      target.cornerRadius = max(
        0,
        CGFloat(TiUtils.doubleValue(cornerRadius, def: Double(target.cornerRadius)))
      )
    }
    if let offset = options["cutoutCenterOffset"] ?? options["centerOffset"] {
      target.centerOffset = TiUtils.pointValue(offset)
    }
    if let smoothing = options["cutoutSmoothing"] ?? options["smoothing"] {
      target.smoothing = max(
        0,
        CGFloat(TiUtils.doubleValue(smoothing, def: Double(target.smoothing)))
      )
    }
    if let alignment = options["cutoutAlignment"] ?? options["alignment"] {
      target.alignment = min(
        1,
        max(0, CGFloat(TiUtils.doubleValue(alignment, def: Double(target.alignment))))
      )
    }

    let respectsReducedMotion = TiUtils.boolValue(options["respectReducedMotion"], def: true)
    let requestedDuration = max(0, TiUtils.doubleValue(options["duration"], def: 400) / 1000)
    let duration =
      respectsReducedMotion && UIAccessibility.isReduceMotionEnabled
      ? 0 : requestedDuration
    let delay = max(0, TiUtils.doubleValue(options["delay"], def: 0) / 1000)
    let timing = TiCutoutviewAnimationTiming.from(options["timing"])
    let dampingRatio = min(
      1,
      max(0.05, CGFloat(TiUtils.doubleValue(options["dampingRatio"], def: 0.78)))
    )
    let initialVelocity = max(
      0,
      CGFloat(TiUtils.doubleValue(options["initialVelocity"], def: 0.2))
    )

    animationGeneration += 1
    let generation = animationGeneration
    let start = shapeState
    animationCompletion = completion

    let startAnimation = { [weak self] in
      guard let self = self, self.animationGeneration == generation else {
        return
      }

      if duration == 0 {
        self.shapeState = target
        self.updateShape()
        self.finishCutoutAnimation(finished: true, generation: generation)
        return
      }

      self.animationContext = TiCutoutviewAnimationContext(
        start: start,
        target: target,
        duration: duration,
        timing: timing,
        dampingRatio: dampingRatio,
        initialVelocity: initialVelocity,
        generation: generation,
        startTime: nil
      )
      let displayLink = CADisplayLink(
        target: self, selector: #selector(self.handleCutoutAnimation(_:)))
      displayLink.add(to: .main, forMode: .common)
      self.displayLink = displayLink
    }

    if delay > 0 {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: startAnimation)
    } else {
      startAnimation()
    }
  }

  @objc private func handleCutoutAnimation(_ displayLink: CADisplayLink) {
    guard var context = animationContext else {
      displayLink.invalidate()
      self.displayLink = nil
      return
    }

    if context.startTime == nil {
      context.startTime = displayLink.timestamp
      animationContext = context
    }

    let elapsed = displayLink.timestamp - (context.startTime ?? displayLink.timestamp)
    let linearProgress = min(1, max(0, elapsed / context.duration))
    let easedProgress = animationProgress(
      linearProgress,
      timing: context.timing,
      dampingRatio: context.dampingRatio,
      initialVelocity: context.initialVelocity
    )

    shapeState = context.start.interpolated(to: context.target, progress: easedProgress)
    updateShape()

    if linearProgress >= 1 {
      shapeState = context.target
      updateShape()
      finishCutoutAnimation(finished: true, generation: context.generation)
    }
  }

  private func animationProgress(
    _ progress: CGFloat,
    timing: TiCutoutviewAnimationTiming,
    dampingRatio: CGFloat,
    initialVelocity: CGFloat
  ) -> CGFloat {
    switch timing {
    case .linear:
      return progress
    case .easeIn:
      return progress * progress
    case .easeOut:
      return 1 - pow(1 - progress, 2)
    case .easeInOut:
      if progress < 0.5 {
        return 2 * progress * progress
      }
      return 1 - pow(-2 * progress + 2, 2) / 2
    case .spring:
      if progress >= 1 {
        return 1
      }
      let decay = exp(-dampingRatio * 8 * progress)
      let frequency = 10 + initialVelocity * 2
      return 1 - decay * cos(frequency * progress)
    }
  }

  private func cancelCutoutAnimation(notify: Bool) {
    guard displayLink != nil || animationContext != nil || animationCompletion != nil else {
      return
    }

    animationGeneration += 1
    displayLink?.invalidate()
    displayLink = nil
    animationContext = nil

    if notify {
      let completion = animationCompletion
      animationCompletion = nil
      completion?(animationPayload(finished: false))
    } else {
      animationCompletion = nil
    }
  }

  private func finishCutoutAnimation(finished: Bool, generation: Int) {
    guard animationGeneration == generation else {
      return
    }

    displayLink?.invalidate()
    displayLink = nil
    animationContext = nil
    let completion = animationCompletion
    animationCompletion = nil
    completion?(animationPayload(finished: finished))
  }

  private func animationPayload(finished: Bool) -> [String: Any] {
    return [
      "finished": finished,
      "cutoutPlacement": shapeState.placement.rawValue,
      "cutoutShape": shapeState.shape.rawValue,
      "cutoutRadius": shapeState.radius,
      "cutoutSize": ["width": shapeState.size.width, "height": shapeState.size.height],
      "cutoutCornerRadius": shapeState.cornerRadius,
      "cutoutCenterOffset": ["x": shapeState.centerOffset.x, "y": shapeState.centerOffset.y],
      "cutoutSmoothing": shapeState.smoothing,
      "cutoutAlignment": shapeState.alignment,
    ]
  }

  private func updateMaterial() {
    switch material {
    case .solid:
      effectView?.removeFromSuperview()
      effectView = nil
      effectMaterialView.isHidden = true
      effectMaterialView.isUserInteractionEnabled = false
      solidMaterialView.isHidden = false
    case .blur:
      solidMaterialView.isHidden = true
      effectMaterialView.isHidden = false
      effectMaterialView.isUserInteractionEnabled = false
      let style = UIBlurEffect.Style(rawValue: blurStyleRawValue) ?? .systemMaterial
      installEffect(UIBlurEffect(style: style))
    case .glass:
      solidMaterialView.isHidden = true
      effectMaterialView.isHidden = false
      effectMaterialView.isUserInteractionEnabled = glassInteractive
      if #available(iOS 26.0, *) {
        let style: UIGlassEffect.Style = glassStyleName == "clear" ? .clear : .regular
        let effect = UIGlassEffect(style: style)
        effect.isInteractive = glassInteractive
        effect.tintColor = glassTintColor
        installEffect(effect)
      } else {
        installEffect(UIBlurEffect(style: .systemMaterial))
      }
    }

    bringInternalViewsToFront()
  }

  private func installEffect(_ effect: UIVisualEffect) {
    let visualEffectView: UIVisualEffectView
    if let effectView = effectView {
      visualEffectView = effectView
      visualEffectView.effect = effect
    } else {
      visualEffectView = UIVisualEffectView(effect: effect)
      visualEffectView.backgroundColor = .clear
      visualEffectView.isUserInteractionEnabled = false
      effectView = visualEffectView
      effectMaterialView.addSubview(visualEffectView)
    }

    visualEffectView.isUserInteractionEnabled = material == .glass && glassInteractive

    if let currentPath = currentPath {
      updateEffectMask(path: currentPath)
    }
  }

  private func updateAppearance() {
    withoutImplicitAnimations {
      shadowShapeLayer.shadowColor = shapeShadowColor.cgColor
      shadowShapeLayer.shadowOpacity = shapeShadowOpacity
      shadowShapeLayer.shadowRadius = shapeShadowRadius
      shadowShapeLayer.shadowOffset = shapeShadowOffset

      fillShapeLayer.fillColor = fillColor.cgColor
      borderShapeLayer.strokeColor = shapeBorderColor.cgColor
      borderShapeLayer.lineWidth = shapeBorderWidth
    }
  }

  private func updateShape() {
    guard bounds.width > 0, bounds.height > 0 else {
      return
    }

    let path = makeCutoutPath(in: bounds, state: shapeState)
    currentPath = path

    withoutImplicitAnimations {
      shadowShapeLayer.frame = bounds
      solidMaterialView.frame = bounds
      fillShapeLayer.frame = solidMaterialView.bounds
      effectMaterialView.frame = bounds
      effectMaskLayer.frame = effectMaterialView.bounds
      effectMaskLayer.path = path.cgPath
      effectView?.frame = effectMaterialView.bounds
      contentContainer.frame = bounds
      contentMaskLayer.frame = bounds
      borderOverlayView.frame = bounds
      borderShapeLayer.frame = borderOverlayView.bounds

      shadowShapeLayer.path = path.cgPath
      shadowShapeLayer.shadowPath = path.cgPath
      fillShapeLayer.path = path.cgPath
      contentMaskLayer.path = path.cgPath
      borderShapeLayer.path = path.cgPath
    }

    updateEffectMask(path: path)
    updateAppearance()
    updateContentMask()
    bringInternalViewsToFront()
  }

  private func updateEffectMask(path: UIBezierPath) {
    withoutImplicitAnimations {
      effectMaskLayer.frame = effectMaterialView.bounds
      effectMaskLayer.path = path.cgPath
    }
  }

  private func updateContentMask() {
    withoutImplicitAnimations {
      contentContainer.layer.mask = clipsContentToShape ? contentMaskLayer : nil
    }
  }

  private func makeCutoutPath(in rect: CGRect, state: TiCutoutviewShapeState) -> UIBezierPath {
    switch state.shape {
    case .circle:
      guard state.radius > 0.01 else {
        return makeRoundedRectPath(in: rect, radii: cornerRadii)
      }
    case .rectangle:
      guard state.size.width > 0.01, state.size.height > 0.01 else {
        return makeRoundedRectPath(in: rect, radii: cornerRadii)
      }
    }

    if state.placement.isCorner {
      return makeCornerCutoutPath(in: rect, state: state)
    }

    return makeEdgeCutoutPath(in: rect, state: state)
  }

  private func makeCornerCutoutPath(in rect: CGRect, state: TiCutoutviewShapeState)
    -> UIBezierPath
  {
    let horizontalMirror = state.placement == .bottomRight || state.placement == .topRight
    let verticalMirror = state.placement == .topLeft || state.placement == .topRight
    var canonicalRadii = cornerRadii
    if horizontalMirror {
      canonicalRadii = canonicalRadii.mirroredHorizontally()
    }
    if verticalMirror {
      canonicalRadii = canonicalRadii.mirroredVertically()
    }

    let canonicalOffset = CGPoint(
      x: horizontalMirror ? -state.centerOffset.x : state.centerOffset.x,
      y: verticalMirror ? -state.centerOffset.y : state.centerOffset.y
    )
    let path: UIBezierPath
    switch state.shape {
    case .circle:
      path = makeCanonicalBottomLeftCornerPath(
        in: rect,
        radius: state.radius,
        smoothing: state.smoothing,
        centerOffset: canonicalOffset,
        radii: canonicalRadii
      )
    case .rectangle:
      path = makeCanonicalBottomLeftRectanglePath(
        in: rect,
        size: state.size,
        cutoutCornerRadius: state.cornerRadius,
        smoothing: state.smoothing,
        centerOffset: canonicalOffset,
        radii: canonicalRadii
      )
    }

    var transform = CGAffineTransform.identity
    if horizontalMirror {
      transform = transform.translatedBy(x: rect.width, y: 0).scaledBy(x: -1, y: 1)
    }
    if verticalMirror {
      transform = transform.translatedBy(x: 0, y: rect.height).scaledBy(x: 1, y: -1)
    }
    path.apply(transform)
    return path
  }

  private func makeEdgeCutoutPath(in rect: CGRect, state: TiCutoutviewShapeState)
    -> UIBezierPath
  {
    let isVerticalEdge = state.placement == .left || state.placement == .right
    let canonicalRect = CGRect(
      x: 0,
      y: 0,
      width: isVerticalEdge ? rect.height : rect.width,
      height: isVerticalEdge ? rect.width : rect.height
    )

    let canonicalRadii: TiCutoutviewCornerRadii
    let canonicalOffset: CGPoint
    let canonicalSize =
      isVerticalEdge
      ? CGSize(width: state.size.height, height: state.size.width) : state.size
    let transform: CGAffineTransform

    switch state.placement {
    case .bottom:
      canonicalRadii = cornerRadii
      canonicalOffset = state.centerOffset
      transform = .identity
    case .top:
      canonicalRadii = cornerRadii.mirroredVertically()
      canonicalOffset = CGPoint(x: state.centerOffset.x, y: -state.centerOffset.y)
      transform = CGAffineTransform(translationX: 0, y: rect.height).scaledBy(x: 1, y: -1)
    case .left:
      canonicalRadii = TiCutoutviewCornerRadii(
        topLeft: cornerRadii.topRight,
        topRight: cornerRadii.bottomRight,
        bottomRight: cornerRadii.bottomLeft,
        bottomLeft: cornerRadii.topLeft
      )
      canonicalOffset = CGPoint(x: state.centerOffset.y, y: -state.centerOffset.x)
      transform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: rect.width, ty: 0)
    case .right:
      canonicalRadii = TiCutoutviewCornerRadii(
        topLeft: cornerRadii.topLeft,
        topRight: cornerRadii.bottomLeft,
        bottomRight: cornerRadii.bottomRight,
        bottomLeft: cornerRadii.topRight
      )
      canonicalOffset = CGPoint(x: state.centerOffset.y, y: state.centerOffset.x)
      transform = CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)
    default:
      return makeRoundedRectPath(in: rect, radii: cornerRadii)
    }

    let path: UIBezierPath
    switch state.shape {
    case .circle:
      path = makeCanonicalBottomEdgePath(
        in: canonicalRect,
        radius: state.radius,
        smoothing: state.smoothing,
        alignment: state.alignment,
        centerOffset: canonicalOffset,
        radii: canonicalRadii
      )
    case .rectangle:
      path = makeCanonicalBottomEdgeRectanglePath(
        in: canonicalRect,
        size: canonicalSize,
        cutoutCornerRadius: state.cornerRadius,
        smoothing: state.smoothing,
        alignment: state.alignment,
        centerOffset: canonicalOffset,
        radii: canonicalRadii
      )
    }
    path.apply(transform)
    return path
  }

  private func makeCanonicalBottomLeftCornerPath(
    in rect: CGRect,
    radius requestedRadius: CGFloat,
    smoothing requestedSmoothing: CGFloat,
    centerOffset: CGPoint,
    radii: TiCutoutviewCornerRadii
  ) -> UIBezierPath {
    let width = rect.width
    let height = rect.height
    let maximumCornerRadius = min(width, height) / 2

    let topLeft = min(radii.topLeft, maximumCornerRadius)
    let topRight = min(radii.topRight, maximumCornerRadius)
    let bottomRight = min(radii.bottomRight, maximumCornerRadius)

    let radius = min(requestedRadius, min(width, height))
    let smoothing = min(requestedSmoothing, radius)
    let center = CGPoint(x: centerOffset.x, y: height + centerOffset.y)

    let joinAngle = min(.pi / 4, max(0.01, atan2(max(smoothing, 0.5), max(radius, 0.5))))
    let bottomArcPoint = CGPoint(
      x: center.x + radius * cos(joinAngle),
      y: center.y - radius * sin(joinAngle)
    )
    let leftArcPoint = CGPoint(
      x: center.x + radius * sin(joinAngle),
      y: center.y - radius * cos(joinAngle)
    )

    let bottomShoulder = CGPoint(
      x: min(width - bottomRight, max(0, center.x + radius + smoothing)),
      y: height
    )
    let leftShoulder = CGPoint(
      x: 0,
      y: max(topLeft, min(height, center.y - radius - smoothing))
    )

    let path = UIBezierPath()
    path.move(to: CGPoint(x: topLeft, y: 0))
    path.addLine(to: CGPoint(x: width - topRight, y: 0))
    addTopRightCorner(to: path, width: width, radius: topRight)
    path.addLine(to: CGPoint(x: width, y: height - bottomRight))
    addBottomRightCorner(to: path, width: width, height: height, radius: bottomRight)
    path.addLine(to: bottomShoulder)

    let shoulderControl = max(1, smoothing * 0.55)
    path.addCurve(
      to: bottomArcPoint,
      controlPoint1: CGPoint(x: bottomShoulder.x - shoulderControl, y: bottomShoulder.y),
      controlPoint2: CGPoint(
        x: bottomArcPoint.x + sin(joinAngle) * shoulderControl,
        y: bottomArcPoint.y + cos(joinAngle) * shoulderControl
      )
    )
    path.addArc(
      withCenter: center,
      radius: radius,
      startAngle: -joinAngle,
      endAngle: -(.pi / 2 - joinAngle),
      clockwise: false
    )
    path.addCurve(
      to: leftShoulder,
      controlPoint1: CGPoint(
        x: leftArcPoint.x - cos(joinAngle) * shoulderControl,
        y: leftArcPoint.y - sin(joinAngle) * shoulderControl
      ),
      controlPoint2: CGPoint(x: leftShoulder.x, y: leftShoulder.y + shoulderControl)
    )

    path.addLine(to: CGPoint(x: 0, y: topLeft))
    addTopLeftCorner(to: path, radius: topLeft)
    path.close()
    return path
  }

  private func makeCanonicalBottomEdgePath(
    in rect: CGRect,
    radius requestedRadius: CGFloat,
    smoothing requestedSmoothing: CGFloat,
    alignment: CGFloat,
    centerOffset: CGPoint,
    radii: TiCutoutviewCornerRadii
  ) -> UIBezierPath {
    let width = rect.width
    let height = rect.height
    let maximumCornerRadius = min(width, height) / 2
    let topLeft = min(radii.topLeft, maximumCornerRadius)
    let topRight = min(radii.topRight, maximumCornerRadius)
    let bottomRight = min(radii.bottomRight, maximumCornerRadius)
    let bottomLeft = min(radii.bottomLeft, maximumCornerRadius)

    let availableWidth = max(0, width - bottomLeft - bottomRight)
    let radius = min(requestedRadius, min(height, availableWidth / 2))
    let maximumSmoothing = max(0, availableWidth / 2 - radius)
    let smoothing = min(requestedSmoothing, radius, maximumSmoothing)
    let minimumCenter = bottomLeft + radius + smoothing
    let maximumCenter = width - bottomRight - radius - smoothing
    let requestedCenterX = width * min(1, max(0, alignment)) + centerOffset.x
    let centerX =
      minimumCenter <= maximumCenter
      ? min(maximumCenter, max(minimumCenter, requestedCenterX)) : width / 2
    let center = CGPoint(x: centerX, y: height + centerOffset.y)

    let joinAngle = min(.pi / 4, max(0.01, atan2(max(smoothing, 0.5), max(radius, 0.5))))
    let rightArcPoint = CGPoint(
      x: center.x + radius * cos(joinAngle),
      y: center.y - radius * sin(joinAngle)
    )
    let leftArcPoint = CGPoint(
      x: center.x - radius * cos(joinAngle),
      y: center.y - radius * sin(joinAngle)
    )
    let rightShoulder = CGPoint(x: center.x + radius + smoothing, y: height)
    let leftShoulder = CGPoint(x: center.x - radius - smoothing, y: height)
    let shoulderControl = max(1, smoothing * 0.55)

    let path = UIBezierPath()
    path.move(to: CGPoint(x: topLeft, y: 0))
    path.addLine(to: CGPoint(x: width - topRight, y: 0))
    addTopRightCorner(to: path, width: width, radius: topRight)
    path.addLine(to: CGPoint(x: width, y: height - bottomRight))
    addBottomRightCorner(to: path, width: width, height: height, radius: bottomRight)
    path.addLine(to: rightShoulder)
    path.addCurve(
      to: rightArcPoint,
      controlPoint1: CGPoint(x: rightShoulder.x - shoulderControl, y: height),
      controlPoint2: CGPoint(
        x: rightArcPoint.x + sin(joinAngle) * shoulderControl,
        y: rightArcPoint.y + cos(joinAngle) * shoulderControl
      )
    )
    path.addArc(
      withCenter: center,
      radius: radius,
      startAngle: -joinAngle,
      endAngle: -.pi + joinAngle,
      clockwise: false
    )
    path.addCurve(
      to: leftShoulder,
      controlPoint1: CGPoint(
        x: leftArcPoint.x - sin(joinAngle) * shoulderControl,
        y: leftArcPoint.y + cos(joinAngle) * shoulderControl
      ),
      controlPoint2: CGPoint(x: leftShoulder.x + shoulderControl, y: height)
    )
    path.addLine(to: CGPoint(x: bottomLeft, y: height))
    addBottomLeftCorner(to: path, height: height, radius: bottomLeft)
    path.addLine(to: CGPoint(x: 0, y: topLeft))
    addTopLeftCorner(to: path, radius: topLeft)
    path.close()
    return path
  }

  private func makeCanonicalBottomLeftRectanglePath(
    in rect: CGRect,
    size requestedSize: CGSize,
    cutoutCornerRadius requestedCornerRadius: CGFloat,
    smoothing requestedSmoothing: CGFloat,
    centerOffset: CGPoint,
    radii: TiCutoutviewCornerRadii
  ) -> UIBezierPath {
    let width = rect.width
    let height = rect.height
    let maximumCornerRadius = min(width, height) / 2
    let topLeft = min(radii.topLeft, maximumCornerRadius)
    let topRight = min(radii.topRight, maximumCornerRadius)
    let bottomRight = min(radii.bottomRight, maximumCornerRadius)
    let center = CGPoint(x: centerOffset.x, y: height + centerOffset.y)
    let cutoutRight = min(
      width - bottomRight,
      max(0, center.x + max(0, requestedSize.width) / 2)
    )
    let cutoutTop = max(
      topLeft,
      min(height, center.y - max(0, requestedSize.height) / 2)
    )
    let cutoutDepth = height - cutoutTop

    guard cutoutRight > 0.01, cutoutDepth > 0.01 else {
      return makeRoundedRectPath(in: rect, radii: radii)
    }

    let cutoutCornerRadius = min(
      max(0, requestedCornerRadius),
      cutoutRight / 2,
      cutoutDepth / 2
    )
    let maximumSmoothing = min(
      max(0, width - bottomRight - cutoutRight),
      max(0, cutoutTop - topLeft),
      max(0, cutoutRight - cutoutCornerRadius),
      max(0, cutoutDepth - cutoutCornerRadius)
    )
    let smoothing = min(max(0, requestedSmoothing), maximumSmoothing)
    let bottomShoulder = CGPoint(x: cutoutRight + smoothing, y: height)
    let rightWallStart = CGPoint(x: cutoutRight, y: height - smoothing)
    let leftShoulder = CGPoint(x: 0, y: cutoutTop - smoothing)

    let path = UIBezierPath()
    path.move(to: CGPoint(x: topLeft, y: 0))
    path.addLine(to: CGPoint(x: width - topRight, y: 0))
    addTopRightCorner(to: path, width: width, radius: topRight)
    path.addLine(to: CGPoint(x: width, y: height - bottomRight))
    addBottomRightCorner(to: path, width: width, height: height, radius: bottomRight)
    path.addLine(to: bottomShoulder)

    if smoothing > 0 {
      path.addCurve(
        to: rightWallStart,
        controlPoint1: CGPoint(x: bottomShoulder.x - smoothing * 0.55, y: height),
        controlPoint2: CGPoint(x: cutoutRight, y: height - smoothing * 0.45)
      )
    } else {
      path.addLine(to: rightWallStart)
    }

    path.addLine(to: CGPoint(x: cutoutRight, y: cutoutTop + cutoutCornerRadius))
    if cutoutCornerRadius > 0 {
      path.addQuadCurve(
        to: CGPoint(x: cutoutRight - cutoutCornerRadius, y: cutoutTop),
        controlPoint: CGPoint(x: cutoutRight, y: cutoutTop)
      )
    }
    path.addLine(to: CGPoint(x: smoothing, y: cutoutTop))

    if smoothing > 0 {
      path.addCurve(
        to: leftShoulder,
        controlPoint1: CGPoint(x: smoothing * 0.45, y: cutoutTop),
        controlPoint2: CGPoint(x: 0, y: cutoutTop - smoothing * 0.45)
      )
    } else {
      path.addLine(to: leftShoulder)
    }

    path.addLine(to: CGPoint(x: 0, y: topLeft))
    addTopLeftCorner(to: path, radius: topLeft)
    path.close()
    return path
  }

  private func makeCanonicalBottomEdgeRectanglePath(
    in rect: CGRect,
    size requestedSize: CGSize,
    cutoutCornerRadius requestedCornerRadius: CGFloat,
    smoothing requestedSmoothing: CGFloat,
    alignment: CGFloat,
    centerOffset: CGPoint,
    radii: TiCutoutviewCornerRadii
  ) -> UIBezierPath {
    let width = rect.width
    let height = rect.height
    let maximumCornerRadius = min(width, height) / 2
    let topLeft = min(radii.topLeft, maximumCornerRadius)
    let topRight = min(radii.topRight, maximumCornerRadius)
    let bottomRight = min(radii.bottomRight, maximumCornerRadius)
    let bottomLeft = min(radii.bottomLeft, maximumCornerRadius)
    let availableWidth = max(0, width - bottomLeft - bottomRight)
    let cutoutWidth = min(max(0, requestedSize.width), availableWidth)
    let centerY = height + centerOffset.y
    let cutoutTop = max(0, min(height, centerY - max(0, requestedSize.height) / 2))
    let cutoutDepth = height - cutoutTop

    guard cutoutWidth > 0.01, cutoutDepth > 0.01 else {
      return makeRoundedRectPath(in: rect, radii: radii)
    }

    let cutoutCornerRadius = min(
      max(0, requestedCornerRadius),
      cutoutWidth / 2,
      cutoutDepth / 2
    )
    let maximumSmoothing = min(
      max(0, (availableWidth - cutoutWidth) / 2),
      max(0, cutoutDepth - cutoutCornerRadius)
    )
    let smoothing = min(max(0, requestedSmoothing), maximumSmoothing)
    let halfWidth = cutoutWidth / 2
    let minimumCenter = bottomLeft + halfWidth + smoothing
    let maximumCenter = width - bottomRight - halfWidth - smoothing
    let requestedCenterX = width * min(1, max(0, alignment)) + centerOffset.x
    let centerX =
      minimumCenter <= maximumCenter
      ? min(maximumCenter, max(minimumCenter, requestedCenterX)) : width / 2
    let cutoutLeft = centerX - halfWidth
    let cutoutRight = centerX + halfWidth
    let rightShoulder = CGPoint(x: cutoutRight + smoothing, y: height)
    let rightWallStart = CGPoint(x: cutoutRight, y: height - smoothing)
    let leftWallEnd = CGPoint(x: cutoutLeft, y: height - smoothing)
    let leftShoulder = CGPoint(x: cutoutLeft - smoothing, y: height)

    let path = UIBezierPath()
    path.move(to: CGPoint(x: topLeft, y: 0))
    path.addLine(to: CGPoint(x: width - topRight, y: 0))
    addTopRightCorner(to: path, width: width, radius: topRight)
    path.addLine(to: CGPoint(x: width, y: height - bottomRight))
    addBottomRightCorner(to: path, width: width, height: height, radius: bottomRight)
    path.addLine(to: rightShoulder)

    if smoothing > 0 {
      path.addCurve(
        to: rightWallStart,
        controlPoint1: CGPoint(x: rightShoulder.x - smoothing * 0.55, y: height),
        controlPoint2: CGPoint(x: cutoutRight, y: height - smoothing * 0.45)
      )
    } else {
      path.addLine(to: rightWallStart)
    }

    path.addLine(to: CGPoint(x: cutoutRight, y: cutoutTop + cutoutCornerRadius))
    if cutoutCornerRadius > 0 {
      path.addQuadCurve(
        to: CGPoint(x: cutoutRight - cutoutCornerRadius, y: cutoutTop),
        controlPoint: CGPoint(x: cutoutRight, y: cutoutTop)
      )
    }
    path.addLine(to: CGPoint(x: cutoutLeft + cutoutCornerRadius, y: cutoutTop))
    if cutoutCornerRadius > 0 {
      path.addQuadCurve(
        to: CGPoint(x: cutoutLeft, y: cutoutTop + cutoutCornerRadius),
        controlPoint: CGPoint(x: cutoutLeft, y: cutoutTop)
      )
    }
    path.addLine(to: leftWallEnd)

    if smoothing > 0 {
      path.addCurve(
        to: leftShoulder,
        controlPoint1: CGPoint(x: cutoutLeft, y: height - smoothing * 0.45),
        controlPoint2: CGPoint(x: leftShoulder.x + smoothing * 0.55, y: height)
      )
    } else {
      path.addLine(to: leftShoulder)
    }

    path.addLine(to: CGPoint(x: bottomLeft, y: height))
    addBottomLeftCorner(to: path, height: height, radius: bottomLeft)
    path.addLine(to: CGPoint(x: 0, y: topLeft))
    addTopLeftCorner(to: path, radius: topLeft)
    path.close()
    return path
  }

  private func makeRoundedRectPath(in rect: CGRect, radii: TiCutoutviewCornerRadii)
    -> UIBezierPath
  {
    let width = rect.width
    let height = rect.height
    let maximumCornerRadius = min(width, height) / 2
    let topLeft = min(radii.topLeft, maximumCornerRadius)
    let topRight = min(radii.topRight, maximumCornerRadius)
    let bottomRight = min(radii.bottomRight, maximumCornerRadius)
    let bottomLeft = min(radii.bottomLeft, maximumCornerRadius)

    let path = UIBezierPath()
    path.move(to: CGPoint(x: topLeft, y: 0))
    path.addLine(to: CGPoint(x: width - topRight, y: 0))
    addTopRightCorner(to: path, width: width, radius: topRight)
    path.addLine(to: CGPoint(x: width, y: height - bottomRight))
    addBottomRightCorner(to: path, width: width, height: height, radius: bottomRight)
    path.addLine(to: CGPoint(x: bottomLeft, y: height))
    addBottomLeftCorner(to: path, height: height, radius: bottomLeft)
    path.addLine(to: CGPoint(x: 0, y: topLeft))
    addTopLeftCorner(to: path, radius: topLeft)
    path.close()
    return path
  }

  private func addTopRightCorner(to path: UIBezierPath, width: CGFloat, radius: CGFloat) {
    guard radius > 0 else {
      path.addLine(to: CGPoint(x: width, y: 0))
      return
    }
    path.addArc(
      withCenter: CGPoint(x: width - radius, y: radius),
      radius: radius,
      startAngle: -.pi / 2,
      endAngle: 0,
      clockwise: true
    )
  }

  private func addBottomRightCorner(
    to path: UIBezierPath,
    width: CGFloat,
    height: CGFloat,
    radius: CGFloat
  ) {
    guard radius > 0 else {
      path.addLine(to: CGPoint(x: width, y: height))
      return
    }
    path.addArc(
      withCenter: CGPoint(x: width - radius, y: height - radius),
      radius: radius,
      startAngle: 0,
      endAngle: .pi / 2,
      clockwise: true
    )
  }

  private func addBottomLeftCorner(to path: UIBezierPath, height: CGFloat, radius: CGFloat) {
    guard radius > 0 else {
      path.addLine(to: CGPoint(x: 0, y: height))
      return
    }
    path.addArc(
      withCenter: CGPoint(x: radius, y: height - radius),
      radius: radius,
      startAngle: .pi / 2,
      endAngle: .pi,
      clockwise: true
    )
  }

  private func addTopLeftCorner(to path: UIBezierPath, radius: CGFloat) {
    guard radius > 0 else {
      path.addLine(to: .zero)
      return
    }
    path.addArc(
      withCenter: CGPoint(x: radius, y: radius),
      radius: radius,
      startAngle: .pi,
      endAngle: -.pi / 2,
      clockwise: true
    )
  }

  private func isInternalView(_ view: UIView) -> Bool {
    return view === solidMaterialView || view === effectMaterialView || view === contentContainer
      || view === borderOverlayView || view === effectView
  }

  private func bringInternalViewsToFront() {
    super.insertSubview(effectMaterialView, aboveSubview: solidMaterialView)
    super.bringSubviewToFront(contentContainer)
    super.bringSubviewToFront(borderOverlayView)
  }

  private func withoutImplicitAnimations(_ changes: () -> Void) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    changes()
    CATransaction.commit()
  }

  private func prepareRootLayerForShapeShadow() {
    clipsToBounds = false
    layer.masksToBounds = false
  }
}
