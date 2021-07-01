//
//  GridViewModel+Algorithm.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/16/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI

extension GridViewModel {
    
    func addPath(_ from: Hex, to: Hex) {
        fixedPaths.append(Hex.line(from, to, map: self.gridData))
    }
    
    func findPathBidirectional () {
        let startPoints = self.selectedLocation
        var queue1 = [startPoints.first!]
        var queue2 = [startPoints.last!]
        
        var visited1: Set<Hex> = Set()
        var visited2: Set<Hex> = Set()
        
        self.timer = DispatchSource.makeTimerSource()
        self.timer?.schedule(deadline: .now(), repeating: stepBi)
        self.timer?.setEventHandler { [weak self] in
            
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    guard let `self` = self else { return }
                    
                    let finished = self.bfsStep(
                        queue1: &queue1,
                        queue2: &queue2,
                        visited1: &visited1,
                        visited2: &visited2,
                        checking: &self.checkingItems,
                        collissions: &self.collisonItems,
                        in: self.gridData
                    )
                    
                    let vs1 = Array(visited1.map { HexDisplay($0, Color.visited1) })
                    let vs2 = Array(visited2.map { HexDisplay($0, Color.visited2) })
                    self.visitedDisplay = Array(vs1 + vs2)
                    
                    if finished == true {
                        self.finish()
                    }
                }
            }
            
        }
        self.timer?.resume()
    }
    
    func bfsStep(
        queue1: inout [Hex],
        queue2: inout [Hex],
        visited1: inout Set<Hex>,
        visited2: inout Set<Hex>,
        checking: inout [Hex],
        collissions: inout [Hex],
        in map: Map) -> Bool {
        
        if queue1.isEmpty || queue2.isEmpty {
            return true
        }
        
        var left = queue1.removeFirst()
        while visited1.contains(left) {
            left = queue1.removeFirst()
            if queue1.isEmpty {
                return true
            }
        }
        
        var right = queue2.removeFirst()
        while visited2.contains(right) {
            right = queue2.removeFirst()
            if queue2.isEmpty {
                return true
            }
        }
            
        checking.removeAll()
        checking.append(contentsOf: [left, right])
        
        if visited1.contains(right) || visited2.contains(left) {
            checking.removeAll()
            if visited1.contains(right) && visited2.contains(left) {
                collissions.append(contentsOf: [left, right])
            }else if visited1.contains(right) {
                collissions.append(contentsOf: [right])
            }else {
                collissions.append(contentsOf: [left])
            }
            
            return true
        }
        
        visited1.insert(left)
        visited2.insert(right)
        
        for neighbor in left.allNeighbors(map) {
            if !visited1.contains(neighbor) {
                queue1.append(neighbor)
            }
        }
        
        for neighbor in right.allNeighbors(map) {
            if !visited2.contains(neighbor){
                queue2.append(neighbor)
            }
        }
        
        return false
    }
    
    func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let first = self.collisonItems.first!
            let last = self.collisonItems.last!
            
            let startPoint = self.selectedLocation.first!
            let endPoint = self.selectedLocation.last!
            
            let distance1 = Hex.distance(first, startPoint) + Hex.distance(first, endPoint)
            let distance2 = Hex.distance(last, startPoint) + Hex.distance(last, endPoint)
            
            var col: Hex
            if distance1 < distance2 {
                col = first
            }else{
                col = last
            }
            
            self.addPath(startPoint, to: col)
            self.addPath(endPoint, to: col)
        }
        
        self.timer?.cancel()
        self.timer = nil
    }
}
