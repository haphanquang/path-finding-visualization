//
//  GridViewModel.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/14/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI

class SelectedGridViewModel : ObservableObject {
    @Published var gridData = Map(height: 0, width: 0, origin: .zero)
    @Published var selectedLocation: Set<Hex> = Set()
    
    @Published var visitedDisplay1: [Hex] = []
    @Published var visitedDisplay2: [Hex] = []
    
    @Published var checkingItems: [Hex] = []
    @Published var collisonItems: [Hex] = []
    
    @Published var fixedPaths: [[Hex]] = []
    
    private var timer: DispatchSourceTimer?
    
    func transform() {
        
    }
    
    func tapped(_ point: CGPoint) {
        if self.selectedLocation.count == 2 {
            
            self.selectedLocation.removeAll()
            self.visitedDisplay1.removeAll()
            self.visitedDisplay2.removeAll()
            self.checkingItems.removeAll()
            self.collisonItems.removeAll()
            self.fixedPaths.removeAll()
            
            timer?.cancel()
            timer = nil
            return
        }
        
        self.selectedLocation.insert(point.pixelToHex(Global.layout))
        
        if self.selectedLocation.count == 2 {
            findPath()
        }
    }
    
    func findPath () {
        let startPoints = Array(self.selectedLocation)
        var queue1 = [startPoints.first!]
        var queue2 = [startPoints.last!]
        
        var visited1: Set<Hex> = Set()
        var visited2: Set<Hex> = Set()
        
        self.timer = DispatchSource.makeTimerSource()
        self.timer?.schedule(deadline: .now(), repeating: 0.25)
        self.timer?.setEventHandler { [weak self] in
            
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    guard let `self` = self else { return }
                    let finished = self.bfs(queue1: &queue1, queue2: &queue2, visited1: &visited1, visited2: &visited2, checking: &self.checkingItems)
                    
                    self.visitedDisplay1 = Array(visited1)
                    self.visitedDisplay2 = Array(visited2)
                    
                    if finished == true {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            self.addPath(startPoints.first!, to: self.collisonItems.first!)
                            self.addPath(startPoints.last!, to: self.collisonItems.last!)
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
                collisonItems.append(contentsOf: [left])
            }else if visited1.contains(right) {
                collisonItems.append(contentsOf: [right])
            }else {
                collisonItems.append(contentsOf: [left])
            }
            
            return true
        }
        
        visited1.insert(left)
        visited2.insert(right)
        
        for neighbor in left.allNeighbors() {
            if !visited1.contains(neighbor) && neighbor.isValidInMap(self.gridData) {
                queue1.append(neighbor)
            }
        }
        
        for neighbor in right.allNeighbors() {
            if !visited2.contains(neighbor) && neighbor.isValidInMap(self.gridData) {
                queue2.append(neighbor)
            }
        }
        
        return false
    }
    
    func addPath(_ from: Hex, to: Hex) {
        fixedPaths.append(Hex.line(from, to))
    }
}
