//
//  GridViewModel+Dijkstra.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/16/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI

class PathWay {
    var prevPath: PathWay? = nil
    var point: Hex
    var totalWeightToReach: Int
    
    init(point: Hex, prevPath: PathWay?, totalWeight: Int) {
        self.point = point
        self.prevPath = prevPath
        self.totalWeightToReach = totalWeight
    }
}

extension SelectedGridViewModel {
    
    func animateFindingPath() {
       
    }
    
    func findPath() {
        let location = self.selectedLocation
        let start = location.first!
        let target = location.last!
        
        var priorityQueue = PriorityQueue(elements: [PathWay(point: start, prevPath: nil, totalWeight: 0)], priorityFunction: { $0.totalWeightToReach < $1.totalWeightToReach })
        
        var visited: [Hex] = []
        
        self.timer = DispatchSource.makeTimerSource()
        self.timer?.schedule(deadline: .now(), repeating: 0.1)
        self.timer?.setEventHandler { [weak self] in
            guard let `self` = self else { return }
            
            let checkpoint = priorityQueue.dequeue()!
            visited.append(checkpoint.point)
            
            DispatchQueue.main.async {
                self.visitedDisplay = Array(visited.map { HexDisplay($0, .visited2) })
            }
            
            if checkpoint.point == target {
                self.finished(self.getGetPathWay(checkpoint))
                return
            }
            
            for neighbor in checkpoint.point.allNeighbors(self.gridData) {
                if visited.contains(neighbor) {
                    continue
                }
                
                let weight = checkpoint.totalWeightToReach + neighbor.weight
                let pathToNeighbor = PathWay(point: neighbor, prevPath: checkpoint, totalWeight: weight)
                priorityQueue.enqueue(pathToNeighbor)
                
                if neighbor == target {
                    self.finished(self.getGetPathWay(pathToNeighbor))
                    return
                }
            }
            
            if priorityQueue.isEmpty {
                self.finished(self.getGetPathWay(checkpoint))
                return
            }
        }
        self.timer?.resume()
    }
    
    func finished(_ path: [Hex]) {
        print(path.count)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let a = Array(path.dropFirst().dropLast())
            self.fixedPaths = [a]
        }
        
        self.timer?.cancel()
        self.timer = nil
    }
    
    func getGetPathWay(_ path: PathWay) -> [Hex] {
        var result = [path.point]
        var prev = path.prevPath
        while prev != nil {
            result.append(prev!.point)
            prev = prev?.prevPath
        }
        return result
    }
}
