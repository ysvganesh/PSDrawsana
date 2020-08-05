//
//  ShapeModel.swift
//  Drawsana Demo
//
//  Created by YSVGanesh on 22/07/20.
//  Copyright © 2020 Asana. All rights reserved.
//

import Foundation

struct DrawsanaShapesModel: Decodable {
  let shapes: [ShapeModel]
  
  struct PenSegmentModel: Decodable {
    let a: [Double]
    let b: [Double]
    let width: Int
  }
  
  struct ShapeModel: Decodable {
    let id: String
    let strokeColor: String
    let type: String
    
    let strokeWidth = 5
    
    let segments: [PenSegmentModel]?
    
    let a: [Double]?
    let b: [Double]?
    
    var canvasFormat: [String: Any] {
      get {
        
        var typeStr = ""
        var points = [String : Any]()
        
        switch type {
        case "Pen":
          typeStr = "brush"
          
        case "Line":
          typeStr = "arrow"
          guard let a = self.a, let b = self.b else { return [:] }
          points = ["startX": a[0], "startY": a[1], "endX": b[0], "endY": b[1]]
        case "Ellipse":
          typeStr = "ellipse"
          guard let a = self.a, let b = self.b else { return [:] }
          points = ["startX": a[0], "startY": a[1], "width": a[0] - b[0], "height": a[1] - b[1]]
        case "Rectangle":
          typeStr = "rect"
          guard let a = self.a, let b = self.b else { return [:] }
          points = ["startX": a[0], "startY": a[1], "width": a[0] - b[0], "height": a[1] - b[1]]
        default: break
        }
        
        var dic = [
          "width": 895,
          "height": 504,
          "type": typeStr,
          "color": strokeColor
          ] as [String : Any]
        
        if type != "Pen" {
          dic["points"] = points
        }else{
          if let seg = segments {
            dic["pointX"] = seg.map{ $0.a[0] }
            dic["pointY"] = seg.map{ $0.a[1] }
          }
        }
        
        return dic
      }
    }
  }

}



