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

enum Algo: Int, CaseIterable {
    case biDirectional = 0, dijkstra, aStar
}

class GridViewModel: ObservableObject {
    @Published var algo: Algo = .biDirectional
    @Published var gridData = Map(height: 0, width: 0, origin: .zero)
    @Published var hexes = [HexDisplay]()
    @Published var pathSum: String = ""
    @Published var showWeight: Bool = false
    @Published var speed: CGFloat = 0.5
    
    private static let stepTime: CGFloat = 150
    
    var stepDelay: DispatchTimeInterval = .milliseconds(Int(GridViewModel.stepTime))
    private var cancellables = Set<AnyCancellable>()
    
    var walls = Set<Hex>()
    var willVisit = Set<Hex>()
    var visited = Set<Hex>()

    var destinations: [Hex] = []
    var checkingItems = Set<Hex>()
    var collisions = [Hex]()
    var shortestPath = [[Hex]]()
    
    var timer: DispatchSourceTimer?
    
    func transform() {
        $algo.map { $0 != .biDirectional }
            .assign(to: \.showWeight, on: self)
            .store(in: &cancellables)
        
        $speed.map { (1.1 - $0) * GridViewModel.stepTime }
            .map { .milliseconds(Int($0)) }
            .assign(to: \.stepDelay, on: self)
            .store(in: &cancellables)
    }
    
    
    func block(_ point: CGPoint) {
        var hex = point.pixelToHex(Global.layout, map: self.gridData)
        hex.weight = -1
        self.walls.insert(hex)
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
        if !self.walls.contains(hex) {
            self.destinations.append(hex)
        }
        return destinations.count
    }
    
    private func run() {
        switch algo {
        case .biDirectional:
            findPathBidirectional()
        case .dijkstra:
            findPathDijkstra()
        case .aStar:
            findPathAStar()
        }
    }
    
    private func reset() {
        timer?.cancel()
        timer = nil
        self.destinations = []
        self.visited = []
        self.willVisit = []
        self.checkingItems = []
        self.collisions = []
        self.walls = []
        self.shortestPath = []
        self.pathSum = ""
        self.refresh()
    }
    
    func randomWalls() {
        guard self.walls.isEmpty else {
            self.walls = []
            self.refresh()
            return
        }
        
        let percent = self.gridData.points.count / 5
        while walls.count < percent {
            if var hex = self.gridData.random() {
                hex.weight = -1
                self.walls.insert(hex)
            }
        }
        self.refresh()
    }
}

extension GridViewModel {
    func refresh() {
        self.hexes = createViews(
            in: self.gridData,
            wall: self.walls,
            destinations: self.destinations,
            visited: self.visited,
            willVisit: self.willVisit,
            checking: self.checkingItems,
            collisions: self.collisions,
            path: Array(self.shortestPath.joined()),
            showWeight: (algo == .dijkstra))
    }
    
    private func createViews(
        in map: Map,
        wall: Set<Hex>,
        destinations: [Hex],
        visited: Set<Hex>,
        willVisit: Set<Hex>,
        checking: Set<Hex>,
        collisions: [Hex],
        path: [Hex],
        showWeight: Bool
    ) -> [HexDisplay] {
        var willBeDraw = [HexDisplay]()
        
        for var hex in map.points {
            
            if wall.contains(hex) {
                hex.weight = -1
                willBeDraw.append(HexDisplay(hex, color: .blocked, showWeight: false))
                continue
            }
            
            if path.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .finalPath, showWeight: showWeight))
                continue
            }
            
            if path.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .finalPath, showWeight: showWeight))
                continue
            }
            
            if destinations.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .selected, showWeight: showWeight))
                continue
            }
            
            if collisions.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .collision, showWeight: showWeight))
                continue
            }
            
            if checking.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .checking, showWeight: showWeight))
                continue
            }
            
            if willVisit.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .willVisit, showWeight: showWeight))
                continue
            }
            
            if visited.contains(hex) {
                willBeDraw.append(HexDisplay(hex, color: .visited1, showWeight: showWeight))
                continue
            }
            
        }
        return willBeDraw
    }
}
