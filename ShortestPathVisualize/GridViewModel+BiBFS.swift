//
//  GridViewModel+Algorithm.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/16/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI

extension SelectedGridViewModel {
    
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
        self.timer?.schedule(deadline: .now(), repeating: stepTime)
        self.timer?.setEventHandler { [weak self] in
            
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    guard let `self` = self else { return }
                    let finished = self.bfs(queue1: &queue1, queue2: &queue2, visited1: &visited1, visited2: &visited2, checking: &self.checkingItems)
                    
                    let vs1 = Array(visited1.map { HexDisplay($0, Color.visited1) })
                    let vs2 = Array(visited2.map { HexDisplay($0, Color.visited2) })
                    
                    self.visitedDisplay = Array(vs1 + vs2)
                    
                    if finished == true {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            
                            let first = self.collisonItems.first!
                            let last = self.collisonItems.last!
                            
                            let distance1 = Hex.distance(first, startPoints.first!) + Hex.distance(first, startPoints.last!)
                            let distance2 = Hex.distance(last, startPoints.first!) + Hex.distance(last, startPoints.last!)
                            
                            var col: Hex
                            if distance1 < distance2 {
                                col = first
                            }else{
                                col = last
                            }
                            
                            self.addPath(startPoints.first!, to: col)
                            self.addPath(startPoints.last!, to: col)
                        }
                        
                        self.timer?.cancel()
                        self.timer = nil
                    }
                }
            }
            
        }
        self.timer?.resume()
    }
    
    func bfs(queue1: inout [Hex], queue2: inout [Hex], visited1: inout Set<Hex>, visited2: inout Set<Hex>, checking: inout [Hex]) -> Bool{
        
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
                collisonItems.append(contentsOf: [left, right])
            }else if visited1.contains(right) {
                collisonItems.append(contentsOf: [right])
            }else {
                collisonItems.append(contentsOf: [left])
            }
            
            return true
        }
        
        visited1.insert(left)
        visited2.insert(right)
        
        for neighbor in left.allNeighbors(self.gridData) {
            if !visited1.contains(neighbor) {
                queue1.append(neighbor)
            }
        }
        
        for neighbor in right.allNeighbors(self.gridData) {
            if !visited2.contains(neighbor){
                queue2.append(neighbor)
            }
        }
        
        return false
    }
}
