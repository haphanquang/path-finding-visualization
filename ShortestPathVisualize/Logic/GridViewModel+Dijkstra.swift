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

extension PathWay: Equatable {
    static func == (lhs: PathWay, rhs: PathWay) -> Bool {
        return lhs.point == rhs.point
    }

}

extension GridViewModel {
    
    func findPathDijkstra() {
        let location = self.destinations
        let start = location.first!
        let target = location.last!
        
        var priorityQueue = PriorityQueue(
            elements: [PathWay(point: start, prevPath: nil, totalWeight: start.weight)],
            priorityFunction: { $0.totalWeightToReach < $1.totalWeightToReach })
        
        var visited: Set<Hex> = Set()
        var willVisited: Set<Hex> = Set()
        let blocked: Set<Hex> = Set(self.wall)
        
        self.timer = DispatchSource.makeTimerSource()
        self.timer?.schedule(deadline: .now(), repeating: stepDelay)
        self.timer?.setEventHandler { [weak self] in
            guard let `self` = self else { return }
            
            let checkpoint = priorityQueue.dequeue()!
            
            visited.insert(checkpoint.point)
            willVisited.remove(checkpoint.point)
            
            DispatchQueue.main.async {
                self.pathSum = self.getGetPathWay(checkpoint)
                    .reversed()
                    .map { "\($0.weight)"}
                    .joined(separator: " + ") + " = \(checkpoint.totalWeightToReach)"
            }
            
            self.checkingItems = [checkpoint.point]
            self.shortestPath = [Array(self.getGetPathWay(checkpoint).dropLast())]
            self.visited = visited
            
            if checkpoint.point == target {
                self.finished(self.getGetPathWay(checkpoint), sum: checkpoint.totalWeightToReach)
                return
            }
            
            
            for neighbor in checkpoint.point.allNeighbors(self.gridData) {
                if visited.contains(neighbor) || willVisited.contains(neighbor) || blocked.contains(neighbor) {
                    continue
                }
                
                willVisited.insert(neighbor)
                
                let weight = checkpoint.totalWeightToReach + neighbor.weight
                let pathToNeighbor = PathWay(point: neighbor, prevPath: checkpoint, totalWeight: weight)
                
                priorityQueue.enqueue(pathToNeighbor)
                
                if neighbor == target {
                    self.finished(self.getGetPathWay(pathToNeighbor), sum: weight)
                    return
                }
            }
            
            self.willVisit = willVisited
            
            if priorityQueue.isEmpty {
                self.finished(self.getGetPathWay(checkpoint),
                              sum: checkpoint.totalWeightToReach)
                return
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.refresh()
                }
            }
        }
        self.timer?.resume()
    }
    
    func finished(_ path: [Hex], sum: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            withAnimation {
                let a = Array(path.dropFirst().dropLast())
                self?.shortestPath = [a]
                self?.pathSum = path
                    .reversed()
                    .map { "\($0.weight)"}
                    .joined(separator: " + ") + " = \(sum)"
                self?.refresh()
            }
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
    
    func addVisitedNeighbor(_ point: Hex, path: PathWay) { }
}
