//
//  HexagonMap.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/13/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import CoreGraphics

func +(lhs: Hex, rhs: Hex) -> Hex {
    return Hex(q: lhs.q + rhs.q, r: lhs.r + rhs.r, s: lhs.s + rhs.s)
}

func *(lhs: Hex, rhs: Hex) -> Hex {
    return Hex(q: lhs.q * rhs.q, r: lhs.r * rhs.r, s: lhs.s * rhs.s)
}

func -(lhs: Hex, rhs: Hex) -> Hex {
    return Hex(q: lhs.q - rhs.q, r: lhs.r - rhs.r, s: lhs.s - rhs.s)
}

struct Hex : Equatable, Hashable, Identifiable{
    let q, r, s: Int
    
    var id: String {
        return "\(q)" + "\(r)" + "\(s)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(q)
        hasher.combine(r)
        hasher.combine(s)
    }
    
    var corners: [Point] = []
    let weight: Int = Int.random(in: 1...99)
    
    static let directions = [
        Hex(q: 1, r: 0, s: -1),
        Hex(q: 1, r: -1, s: 0),
        Hex(q: 0, r: -1, s: 1),
        Hex(q: -1, r: 0, s: 1),
        Hex(q: -1, r: 1, s: 0),
        Hex(q: 0, r: 1, s: -1)
    ]
    
    init(q: Int, r: Int) {
        self.init(q: q, r: r, s: -q - r)
    }
    
    init(q: Double, r: Double) {
       self.init(q: q, r: r, s: -q - r)
    }
    
    init(q: Double, r: Double, s: Double) {
        var rx = round(q)
        var ry = round(r)
        var rz = round(s)

        let x_diff = abs(rx - q)
        let y_diff = abs(ry - r)
        let z_diff = abs(rz - s)

        if (x_diff > y_diff && x_diff > z_diff) {
            rx = -ry-rz
        } else if (y_diff > z_diff) {
            ry = -rx-rz
        } else{
            rz = -rx-ry
        }

        self.init(q: Int(rx), r: Int(ry), s: Int(rz))
    }
    
    init(q: Int, r: Int, s: Int) {
        self.q = q
        self.r = r
        self.s = s
        preparePoints(Global.layout)
    }
    
    mutating func preparePoints(_ layout: Layout) {
        self.corners = layout.getPolygonCorners(hex: self).map { Point(x: $0.x, y: $0.y) }
    }
    
    func allNeighbors(_ map: Map) -> Set<Hex> {
        var result: Set<Hex> = Set()
        for i in 0...5 {
            let neightbor = Hex.neighbor(self, direction: i)
            if let hexInMap = map.getData(neightbor) {
                result.insert(hexInMap)
            }
        }
        return result
    }
    
    func isValidInMap(_ map: Map) -> Bool {
        return map.points.contains(self)
    }

    static func ==(lhs: Hex, rhs: Hex) -> Bool {
        return lhs.q == rhs.q && lhs.r == rhs.r && lhs.s == rhs.s
    }
    
    static func length(_ hex: Hex) -> Int {
        return (abs(hex.q) + abs(hex.r) + abs(hex.s)) / 2
    }
    
    static func distance(_ start: Hex, _ end: Hex) -> Int {
        return length(start - end)
    }
    
    static func neighbor(_ hex: Hex, direction: Int) -> Hex{
        return hex + Hex.directions[direction]
    }
    
    static func lerpHelper(_ a: Int, _ b: Int, _ t: Double) -> Double {
        return Double(a) + Double(b - a) * t
    }
    
    static func lerp(_ start: Hex, _ end: Hex, _ t: Double) -> Hex {
        return Hex(q: Hex.lerpHelper(start.q, end.q, t),
                   r: Hex.lerpHelper(start.r, end.r, t),
                   s: Hex.lerpHelper(start.s, end.s, t))
    }
    
    static func line(_ start: Hex, _ to: Hex, map: Map) -> [Hex] {
        let distance = Hex.distance(start, to)
        var results: [Hex] = []
        
        for i in 0...distance {
            let lerp = Hex.lerp(start, to, 1.0 / Double(distance) * Double(i))
            if let data = map.getData(lerp) {
                results.append(data)
            }
        }
        return results
    }
}

struct Orientation {
    let f0,f1,f2,f3: Double
    let b0,b1,b2,b3: Double
    let startAngle: Double
    
    static let pointy = Orientation(f0: sqrt(3.0), f1: sqrt(3.0) / 2.0, f2: 0.0, f3: 3.0 / 2.0,
                                    b0: sqrt(3.0) / 3.0, b1: -1.0 / 3.0, b2: 0.0, b3: 2.0 / 3.0,
                                    startAngle: 0.5)
    static let flat = Orientation(f0: 3.0 / 2.0, f1: 0.0, f2: sqrt(3.0) / 2.0, f3: sqrt(3.0),
                                  b0: 2.0 / 3.0, b1: 0.0, b2: -1.0 / 3.0, b3: sqrt(3.0) / 3.0,
                                  startAngle: 0.0)
}

struct Layout {
    let orientation: Orientation
    let size: CGSize
    var origin: CGPoint
    
    func getCornerOffset(corner: Int) -> CGPoint {
        let angle = 2 * Double.pi * (orientation.startAngle + Double(corner)) / 6
        return CGPoint(x: size.width * CGFloat(cos(angle)), y: size.height * CGFloat(sin(angle)))
    }
    
    func getPolygonCorners(hex: Hex) -> [CGPoint] {
        var result: [CGPoint] = []
        let center = CGPoint.hexToPixel(self, hex)
        for i in 0..<6 {
            let offset = getCornerOffset(corner: i)
            result.append(CGPoint(x: center.x + offset.x, y: center.y + offset.y))
        }
        return result
    }
    
    mutating func changeOrigin(_ point: CGPoint) {
        origin = point
    }
}

struct Map {
    var layout: Layout = Global.layout
    let heights: [Hex: Double] = [:]
    var points: Set<Hex> = Set()

    
    init(size: CGSize, origin: CGPoint) {
        self.init(height: Int(size.height / Global.layout.size.height), width: Int(size.width / Global.layout.size.width), origin: origin)
    }
    
    init(height: Int, width: Int, origin: CGPoint) {
        for i in 0...height {
            let offset = Int(i / 2)
            for j in -offset...(width - offset) {
                let hex = Hex(q: j, r: i)
                points.insert(hex)
            }
        }
    }
    
    func getData(_ hex: Hex) -> Hex?{
        return points.first(where: { $0 == hex })
    }
}


struct Global {
    static let layout = Layout(orientation: .pointy, size: CGSize.init(width: 20, height: 20), origin: .zero)
}

struct Point : Hashable {
    let x: CGFloat
    let y: CGFloat
}
extension CGPoint {
    static func hexToPixel(_ layout: Layout, _ hex: Hex) -> CGPoint {
        let orientation = layout.orientation
        let x = CGFloat((orientation.f0 * Double(hex.q) + orientation.f1 * Double(hex.r)) * Double(layout.size.width))
        let y = CGFloat((orientation.f2 * Double(hex.q) + orientation.f3 * Double(hex.r)) * Double(layout.size.height))
        return CGPoint(x: x + layout.origin.x, y: y + layout.origin.y)
    }
    
    func pixelToHex(_ layout: Layout, map: Map) -> Hex {
        let orientation = layout.orientation
        let point = CGPoint(x: (self.x - layout.origin.x) / layout.size.width
                            , y: (self.y - layout.origin.y) / layout.size.height)
        let q = orientation.b0 * Double(point.x) + orientation.b1 * Double(point.y)
        let r = orientation.b2 * Double(point.x) + orientation.b3 * Double(point.y)
        let hex = Hex(q: q, r: r)
        if let data = map.getData(hex) {
            return data
        }else{
            return hex
        }
    }
}
