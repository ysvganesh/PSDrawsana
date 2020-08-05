//
//  AnnotationModel.swift
//  Drawsana Demo
//
//  Created by YSVGanesh on 23/07/20.
//  Copyright © 2020 Asana. All rights reserved.
//

import Foundation

struct Annotations: Decodable {
  let annotations: [CanvasModel]
}

struct CanvasModel: Decodable {
  let color: String
  let type: String
  let width: Double
  let height: Double
  
  let points: [String: Double]?
  
  let pointX: [Double]?
  let pointY: [Double]?
  
  var scaleWidth: Double {
    return 375.0 / width
  }
  
  var scaleHeight: Double {
    return 210.0 / height
  }
  
  var shapeFormat: [String: Any] {
    get {
      
      var dic = [
        "id": UUID().uuidString,
        "strokeWidth" : 2,
        "strokeColor": color
        ] as [String : Any]
      
      switch type {
      case "brush":
        dic["type"] = "Pen"
        dic["isEraser"] = false
        dic["isFinished"] = true
        
        guard let xValues = self.pointX, let yValues = self.pointY, xValues.count > 0 else { return [:] }
        
        
        var segments = [[String: Any]]()
        
        let xScale = scaleWidth
        let yScale = scaleHeight
        
        for (i, value) in xValues.enumerated() {
          
          if i+1 < xValues.count {
            let seg = ["a": [value * xScale, yValues[i] * yScale],
                       "b": [xValues[i+1] * xScale, yValues[i+1] * yScale],
                       "width" : 2
              ] as [String : Any]
            segments.append(seg)
          }
          
        }
        
        dic["segments"] = segments
        
        dic["start"] = [xValues[0] * xScale, yValues[0] * yScale]
        
      case "arrow":
        dic["type"] = "Line"
        dic["arrowStyle"] = "standard"
        dic["strokeWidth"] = 5
        guard let points = self.points else { return [:] }
        
        let startX = points["startX"] ?? 0.0
        let startY = points["startY"] ?? 0.0
        let endX = points["endX"] ?? 0.0
        let endY = points["endY"] ?? 0.0
        
        let a = [startX * scaleWidth, startY * scaleHeight]
        let b = [endX * scaleWidth, endY * scaleHeight]
        
        dic["a"] = a
        dic["b"] = b
        
      case "ellipse":
        dic["type"] = "Ellipse"
        guard let points = self.points else { return [:] }
        
        let startX = points["startX"] ?? 0.0
        let startY = points["startY"] ?? 0.0
        let width = points["width"] ?? 0.0
        let height = points["height"] ?? 0.0
        
        let a = [startX * scaleWidth, startY * scaleHeight]
        let b = [a[0] + (width * scaleWidth), a[1] + (height * scaleHeight)]
        
        dic["a"] = a
        dic["b"] = b
        
      case "rect":
        dic["type"] = "Rectangle"
        guard let points = self.points else { return [:] }
        
        let startX = points["startX"] ?? 0.0
        let startY = points["startY"] ?? 0.0
        let width = points["width"] ?? 0.0
        let height = points["height"] ?? 0.0
        
        let a = [startX * scaleWidth, startY * scaleHeight]
        let b = [a[0] + (width * scaleWidth), a[1] + (height * scaleHeight)]
        
        dic["a"] = a
        dic["b"] = b
        
      default: break
      }
      
      return dic
    }
  }
}
