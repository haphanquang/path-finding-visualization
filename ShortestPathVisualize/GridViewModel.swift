//
//  GridViewModel.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/14/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI

struct HexDisplay : Identifiable{
    var id: String {
        return data.id
    }
    
    init(_ data: Hex, _ color: Color) {
        self.data = data
        self.color = color
    }
    
    var data: Hex
    var color: Color
}

class GridViewModel : ObservableObject {
    @Published var algo: Int = 0
    @Published var gridData = Map(height: 0, width: 0, origin: .zero)
    
    @Published var willVisitedDisplay: [Hex] = []
    @Published var visitedDisplay: [HexDisplay] = []
    @Published var blockedItems: [Hex] = []
    
    @Published var selectedLocation: [Hex] = []
    
    @Published var checkingItems: [Hex] = []
    @Published var collisonItems: [Hex] = []
    
    @Published var fixedPaths: [[Hex]] = []
    @Published var pathSum: Int = 0
    
    var timer: DispatchSourceTimer?
    
    let stepTimeDij: DispatchTimeInterval = .milliseconds(250)
    let stepBi: DispatchTimeInterval = .milliseconds(250)
    
    func transform() {
        
    }
    
    
    func blockPoint(_ point: CGPoint) {
        self.blockedItems.append(point.pixelToHex(Global.layout, map: self.gridData))
    }
    
    func tapped(_ point: CGPoint) {
        
        if self.selectedLocation.count == 2 {
            
            timer?.cancel()
            timer = nil
            
            self.selectedLocation.removeAll()
            self.visitedDisplay.removeAll()
            self.willVisitedDisplay.removeAll()
            self.checkingItems.removeAll()
            self.collisonItems.removeAll()
            self.blockedItems.removeAll()
            self.fixedPaths.removeAll()
            self.pathSum = 0
        
            return
        }
        
        let hex = point.pixelToHex(Global.layout, map: self.gridData)
        
        if self.blockedItems.contains(hex) {
            return
        }
        self.selectedLocation.append(hex)
        
        if self.selectedLocation.count == 2 {
            if algo == 0  {
                findPathBidirectional()
            }else {
                findPathDijkstra()
            }
        }
    }

}
