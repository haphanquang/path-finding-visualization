//
//  GridViewModel.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/14/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct HexDisplay: Identifiable, Hashable {
    init(_ data: Hex, color: Color, showWeight: Bool = false) {
        self.data = data
        self.color = color
        self.showWeight = showWeight
        self.id = data.id
    }
    
    let id: String
    let data: Hex
    let color: Color
    let showWeight: Bool
}

class GridViewModel: ObservableObject {
    @Published var algo: Int = 0
    @Published var gridData = Map(height: 0, width: 0, origin: .zero)
    @Published var hexes = [HexDisplay]()
    @Published var pathSum: Int = 0
    @Published var showWeight: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var wall = Set<Hex>()
    var willVisit = Set<Hex>()
    var visited = Set<Hex>()

    var destinations: [Hex] = []
    var checkingItems = Set<Hex>()
    var collisions = [Hex]()
    var shortestPath = [[Hex]]()
    
    var timer: DispatchSourceTimer?
    
    let stepTimeDij: DispatchTimeInterval = .milliseconds(200)
    let stepBi: DispatchTimeInterval = .milliseconds(200)
    
    func transform() {
        $algo.map { $0 > 0 }
            .assign(to: \.showWeight, on: self)
            .store(in: &cancellables)
    }
    
    func refresh() {
        self.hexes = createViews(
            in: self.gridData,
            wall: self.wall,
            destinations: self.destinations,
            visited: self.visited,
            willVisit: self.willVisit,
            checking: self.checkingItems,
            collisions: self.collisions,
            path: Array(self.shortestPath.joined()),
            algo: self.algo)
    }
    
    
    func block(_ point: CGPoint) {
        let hex = point.pixelToHex(Global.layout, map: self.gridData)
        self.wall.insert(hex)
        self.refresh()
    }
    
    func didTap(_ point: CGPoint) {
        guard self.destinations.count < 2 else {
            reset()
            self.refresh()
            return
        }
        
        let count = setDestination(at: point)
        self.refresh()
        if count == 2 {
            run()
        }
    }
    
    private func setDestination(at point: CGPoint) -> Int {
        let hex = point.pixelToHex(Global.layout, map: self.gridData)
        if !self.wall.contains(hex) {
            self.destinations.append(hex)
        }
        return destinations.count
    }
    
    private func run() {
        if algo == 0  {
            findPathBidirectional()
        }else {
            findPathDijkstra()
        }
    }
    
    private func reset() {
        timer?.cancel()
        timer = nil
        
        self.destinations.removeAll()
        self.visited.removeAll()
        self.willVisit.removeAll()
        self.checkingItems.removeAll()
        self.collisions.removeAll()
        self.wall.removeAll()
        self.shortestPath.removeAll()
        self.pathSum = 0
        self.refresh()
    }

    private func createViews(in map: Map,
                   wall: Set<Hex>,
                   destinations: [Hex],
                   visited: Set<Hex>,
                   willVisit: Set<Hex>,
                   checking: Set<Hex>,
                   collisions: [Hex],
                   path: [Hex],
                   algo: Int) -> [HexDisplay] {
        
        var willBeDraw = [HexDisplay]()
        let weight = (algo == 1)
        
        for hex in map.points {
            
            if wall.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .blocked, showWeight: false))
                continue
            }
            
            if path.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .finalPath, showWeight: weight))
                continue
            }
            
            if path.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .finalPath, showWeight: weight))
                continue
            }
            
            if destinations.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .selected, showWeight: weight))
                continue
            }
            
            if collisions.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .collision, showWeight: weight))
                continue
            }
            
            if checking.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .checking, showWeight: weight))
                continue
            }
            
            if willVisit.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .willVisit, showWeight: weight))
                continue
            }
            
            if visited.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .visited1, showWeight: weight))
                continue
            }
            
        }
        
        return willBeDraw
    }
}
