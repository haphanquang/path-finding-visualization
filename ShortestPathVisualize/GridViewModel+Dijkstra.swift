//
//  GridViewModel+Dijkstra.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/16/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI

struct ShortestPath {
    var point: Hex
    var prev: Hex?
    var totalWeightToReach: Int
}

extension SelectedGridViewModel {
    
    func animateFindingPath() {
       
    }
    
    func findPath() {
        let location = self.selectedLocation
        let start = location.first!
        let target = location.last!
        
        var priorityQueue = PriorityQueue(elements: [ShortestPath(point: start, prev: nil, totalWeightToReach: 0)], priorityFunction: { $0.totalWeightToReach < $1.totalWeightToReach })
        
        var visited: [Hex] = []
        
        self.timer = DispatchSource.makeTimerSource()
        self.timer?.schedule(deadline: .now(), repeating: 0.05)
        self.timer?.setEventHandler { [weak self] in
            guard let `self` = self else { return }
            
            if priorityQueue.isEmpty {
                self.finished(visited)
                return
            }
            
            let checkpoint = priorityQueue.dequeue()!
            visited.append(checkpoint.point)
            
            if checkpoint.point == target {
                self.finished(visited)
                return
            }
            
            for neighbor in checkpoint.point.allNeighbors(self.gridData) {
                if visited.contains(neighbor) {
                    continue
                }
                let weight = checkpoint.point.weight + neighbor.weight
                let pathToNeighbor = ShortestPath(point: neighbor, prev: checkpoint.point, totalWeightToReach: weight)
                priorityQueue.enqueue(pathToNeighbor)
            }
            
            DispatchQueue.main.async {
                self.visitedDisplay = Array(visited.map { HexDisplay($0, .visited2) })
            }
            
        }
        self.timer?.resume()
    }
    
    func finished(_ path: [Hex]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.fixedPaths = [path]
        }
        
        self.timer?.cancel()
        self.timer = nil
    }
}
