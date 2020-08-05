//
//  ImmediatePanGestureRecognizer.swift
//  Drawsana
//
//  Created by Steve Landey on 8/14/18.
//  Copyright © 2018 Asana. All rights reserved.
//

import UIKit

/**
 Replaces a tap gesture recognizer and a pan gesture recognizer with just one
 gesture recognizer.

 Lifecycle:
 * Touch begins, state -> .began (all other touches are completely ignored)
 * Touch moves, state -> .changed
 * Touch ends
   * If touch moved more than 10px away from the origin at some point, then
     `hasExceededTapThreshold` was set to `true`. Target may use this to
     distinguish a pan from a tap when the gesture has ended and act
     accordingly.

 This behavior is better than using a regular UIPanGestureRecognizer because
 that class ignores the first ~20px of the touch while it figures out if you
 "really" want to pan. This is a drawing program, so that's not good.
 */
class ImmediatePanGestureRecognizer: UIGestureRecognizer {
  
  var onDoubleTap: ((CGPoint) -> Void)?
  
  var tapThreshold: CGFloat = 10
  // If gesture ends and this value is `true`, then the user's finger moved
  // more than `tapThreshold` points during the gesture, i.e. it is not a tap.
  private(set) var hasExceededTapThreshold = false

  private var startPoint: CGPoint = .zero
  private var lastLastPoint: CGPoint = .zero
  private var lastLastTime: CFTimeInterval = 0
  private var lastPoint: CGPoint = .zero
  private var lastTime: CFTimeInterval = 0
  private var trackedTouch: UITouch?
  
  private var waitForBeginProcess = false
  private var hasSomeChange = false
  private var lastEndTime: CFTimeInterval = 0
  private var lastEndLength: CGFloat = -1.0

  var velocity: CGPoint? {
    guard let view = view, let trackedTouch = trackedTouch else { return nil }
    let delta = trackedTouch.location(in: view) - lastLastPoint
    let deltaT = CGFloat(lastTime - lastLastTime)
    return CGPoint(x: delta.x / deltaT , y: delta.y - deltaT)
  }

  override func location(in view: UIView?) -> CGPoint {
    guard let view = view else {
      return lastPoint
    }
    return view.convert(lastPoint, to: view)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    guard touches.count == 1, trackedTouch == nil, let firstTouch = touches.first, let view = view else { return }
    trackedTouch = firstTouch
    startPoint = firstTouch.location(in: view)
    lastPoint = startPoint
    lastTime = CFAbsoluteTimeGetCurrent()
    lastLastPoint = startPoint
    lastLastTime = lastTime
    
    waitForBeginProcess = true
    hasSomeChange = false
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    guard
      waitForBeginProcess || state == .began || state == .changed,
      let view = view,
      let trackedTouch = trackedTouch,
      touches.contains(trackedTouch) else
    {
      return
    }
    
    hasSomeChange = true
    if waitForBeginProcess {
      state = .began
      waitForBeginProcess = false
    }
    
    lastLastTime = lastTime
    lastLastPoint = lastPoint
    lastTime = CFAbsoluteTimeGetCurrent()
    lastPoint = trackedTouch.location(in: view)
    if (lastPoint - startPoint).length >= tapThreshold {
      hasExceededTapThreshold = true
    }
    
    state = .changed
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    
    guard
      waitForBeginProcess || state == .began || state == .changed,
      let trackedTouch = trackedTouch,
      touches.contains(trackedTouch) else
    {
      return
    }
    
    let time = CFAbsoluteTimeGetCurrent()
    let len  = (lastPoint - startPoint).length
    if time - lastEndTime < 0.4 && lastEndLength == len {
      onDoubleTap?(lastPoint)
    }
    
    lastEndTime = time
    lastEndLength = len
    
    //print((lastPoint - startPoint).length)
    
    if !hasSomeChange && len < tapThreshold {
      //state = .failed
    }else{
      state = .ended
    }
    
    DispatchQueue.main.async {
      self.reset()
    }
  }

  override func reset() {
    super.reset()
    trackedTouch = nil
    hasExceededTapThreshold = false
    waitForBeginProcess = false
    hasSomeChange = false
  }
}
