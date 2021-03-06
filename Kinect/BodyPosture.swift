//
//  BodyPosture.swift
//  Kinect
//
//  Created by Alexandru Nistor on 1/8/17.
//  Copyright © 2017 ASSIST. All rights reserved.
//

import Foundation
import AppKit
import SwiftyJSON

final class BodyPosture {
    // MARK: - Public Variables
    final var Points    : [Point3D]
    final var name      : String
    
    // MARK: - Constructors
    init() {
        Points = [Point3D]()
        name = ""
    }
    
    convenience init(text : String) {
        self.init()
        
        let values = text.components(separatedBy: ";")
        
        for val in values {
            if val == "" {
                continue
            }
            let coordinates = val.components(separatedBy: ",")
            
            let newScreenPoint = CGPoint(x: Int(coordinates[3])!, y: Int(coordinates[4])!)
            let point = Point3D(x: Float(coordinates[0])!,
                                y: Float(coordinates[1])!,
                                z: Float(coordinates[2])!,
                                screenPoint: newScreenPoint,
                                type_: coordinates[5])
            
            Points.append(point)
        }
    }
    
    convenience init(jsonData : JSON) {
        self.init()
        
        name = jsonData["name"].stringValue
        
        for point in jsonData["Points"].array! {
            Points.append(Point3D(jsonPoint: point))
        }
    }
    
    // MARK: - Public methods
    class func generateRandomPostures(frame : NSRect) -> BodyPosture {
        let posture = BodyPosture()
        
        for _ in 0 ..< 20 {
            
            let screenPoint = CGPoint(x: generateRandomNumber(min: Int(frame.minX), max: Int(frame.maxX)), y: generateRandomNumber(min: Int(frame.minY), max: Int(frame.maxY)))
            let type = arc4random_uniform(3)
            
            let TYPE = type == 0 ? "Head" : (type == 1 ? "HandLeft" : (type == 1 ? "HandRight" : ""))
            let X = Float(generateRandomNumber(min: 0, max: Int(frame.maxX)))
            let Y = Float(generateRandomNumber(min: 0, max: Int(frame.maxX)))
            let Z = Float(generateRandomNumber(min: 0, max: Int(frame.maxX)))
            let point = Point3D(x: X, y: Y, z: Z, screenPoint: screenPoint, type_: TYPE)
            
            posture.Points.append(point)
        }
        
        return posture
    }
    
    func distanta(toBody : BodyPosture) -> Double {
        var sum = 0.0
        for item1 in self.Points {
            for item2 in toBody.Points {
                if item1.name == item2.name {
                    sum += item1.sqrEuclideanDistance(b: item2)
                }
             }
        }
        
        return sum
    }
    
    func toImage(width : CGFloat, height : CGFloat) -> NSImageView {
        let imgView = NSImageView(frame: NSRect(x: 0.0, y: 0.0, width: width, height: height))
        
        for point in Points {
            let x = point.ScreenPoint.x
            let y = point.ScreenPoint.y
            var R : CGFloat = 5.0
            var color = NSColor()
            
            switch point.name {
                case "Head":
                color = NSColor.red
                R = 10
                case "HandLeft":
                color = NSColor.green
                R = 10
                case "HandRight":
                color = NSColor.blue
                R = 10
            default:
                color = NSColor.black
                R = 5
            }
            
            let positionOnScreen = NSRect(x: x - R, y: (height * 2) - y - R, width: 2 * R, height: 2 * R)
            let view = NSView(frame: positionOnScreen)
            view.setBackgroundColor(color)
            imgView.addSubview(view)
        }
        
        return imgView
    }
    
    func toString() -> String{
        var text = ""
        for point in Points {
            text += "\(String(format: "%.3f", point.X)), \(String(format: "%.3f", point.Y)), \(String(format: "%.3f", point.Z)), \(String(format: "%d", point.ScreenPoint.x)), \(String(format: "%d", point.ScreenPoint.y)), \(point.name)"
        }
        
        return text
    }
}

extension NSView {
    func setBackgroundColor(_ color: NSColor) {
        wantsLayer = true
        layer?.backgroundColor = color.cgColor
    }
}
