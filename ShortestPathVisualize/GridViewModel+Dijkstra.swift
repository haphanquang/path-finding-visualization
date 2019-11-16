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
        self.timer = DispatchSource.makeTimerSource()
        self.timer?.schedule(deadline: .now(), repeating: 0.25)
        self.timer?.setEventHandler { [weak self] in
            
        }
        self.timer?.resume()
    }
    
    func findPath() {
        let location = Array(self.selectedLocation)
        let start = location.first!
        let target = location.last!
        var priorityQueue = PriorityQueue(elements: [ShortestPath(point: start, prev: nil, totalWeightToReach: 0)], priorityFunction: { $0.totalWeightToReach < $1.totalWeightToReach })
    
        var visited: [Hex] = []
        
        while !priorityQueue.isEmpty {
            let checkpoint = priorityQueue.dequeue()!
            
            visited.append(checkpoint.point)
            
            if checkpoint.point == target {
                break
            }
            
            for neighbor in checkpoint.point.allNeighbors(self.gridData) {
                if visited.contains(neighbor) {
                    continue
                }
                let weight = checkpoint.point.weight + neighbor.weight
                let pathToNeighbor = ShortestPath(point: neighbor, prev: checkpoint.point, totalWeightToReach: weight)
                
                priorityQueue.enqueue(pathToNeighbor)
            }
        }
        
        finished(visited)
    }
    
    func finished(_ path: [Hex]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.fixedPaths = [path]
        }
        
        self.timer?.cancel()
        self.timer = nil
    }
}
