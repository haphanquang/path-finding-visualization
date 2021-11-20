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
    var prevPath: PathWay?
    var tail: Hex
    var totalWeightToReach: Int
    
    init(point: Hex, prevPath: PathWay?, totalWeight: Int) {
        self.tail = point
        self.prevPath = prevPath
        self.totalWeightToReach = totalWeight
    }
}

extension PathWay: Equatable {
    static func == (lhs: PathWay, rhs: PathWay) -> Bool {
        return lhs.tail == rhs.tail
    }

}

typealias HeuristicFunction = ((_ lhs: Hex, _ rhs: Hex) -> Int)

extension GridViewModel {
    
    func findPathDijkstra(_ hFunction: HeuristicFunction? = nil) {
        let location = self.destinations
        let start = location.first!
        let target = location.last!
        
        var priorityQueue = PriorityQueue(
            elements: [PathWay(point: start, prevPath: nil, totalWeight: start.weight)],
            priorityFunction: { $0.totalWeightToReach < $1.totalWeightToReach })
        
        var visited: Set<Hex> = Set()
        var willVisited: Set<Hex> = Set()
        let blocked: Set<Hex> = Set(self.walls)
        
        self.timer = DispatchSource.makeTimerSource()
        self.timer?.schedule(deadline: .now(), repeating: stepDelay)
        self.timer?.setEventHandler { [weak self] in
            guard let `self` = self else { return }
            
            let currentPath = priorityQueue.dequeue()!
            
            visited.insert(currentPath.tail)
            willVisited.remove(currentPath.tail)
            
            DispatchQueue.main.async {
                self.pathSum = self.getGetPathWay(currentPath)
                    .reversed()
                    .map { "\($0.weight)"}
                    .joined(separator: " + ") + " = \(currentPath.totalWeightToReach)"
            }
            
            self.checkingItems = [currentPath.tail]
            self.shortestPath = [Array(self.getGetPathWay(currentPath).dropLast())]
            self.visited = visited
            
            if currentPath.tail == target {
                self.finished(self.getGetPathWay(currentPath), sum: currentPath.totalWeightToReach)
                return
            }
            
            
            for neighbor in currentPath.tail.neighbors(in: self.gridData) {
                if visited.contains(neighbor) || willVisited.contains(neighbor) || blocked.contains(neighbor) {
                    continue
                }
                
                willVisited.insert(neighbor)
                
                let weight = currentPath.totalWeightToReach
                    + neighbor.weight
                    + (hFunction?(start, neighbor) ?? 0)
                
                let pathToNeighbor = PathWay(
                    point: neighbor,
                    prevPath: currentPath,
                    totalWeight: weight)
                
                priorityQueue.enqueue(pathToNeighbor)
                
                if neighbor == target {
                    self.finished(self.getGetPathWay(pathToNeighbor), sum: weight)
                    return
                }
            }
            
            self.willVisit = willVisited
            
            if priorityQueue.isEmpty {
                self.finished(self.getGetPathWay(currentPath), sum: currentPath.totalWeightToReach)
                return
            }
            
            DispatchQueue.main.async {  [weak self] in
                withAnimation {
                    guard let self = self else { return }
                    self.refresh()
                }
            }
        }
        self.timer?.resume()
    }
    
    func finished(_ path: [Hex], sum: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            withAnimation {
                guard let self = self else { return }
                let a = Array(path.dropFirst().dropLast())
                self.shortestPath = [a]
                self.pathSum = path
                    .reversed()
                    .map { "\($0.weight)"}
                    .joined(separator: " + ") + " = \(sum)"
                self.refresh()
            }
        }
        self.timer?.cancel()
        self.timer = nil
    }
    
    func getGetPathWay(_ path: PathWay) -> [Hex] {
        var result = [path.tail]
        var prev = path.prevPath
        while let current = prev {
            result.append(current.tail)
            prev = current.prevPath
        }
        return result
    }
}
