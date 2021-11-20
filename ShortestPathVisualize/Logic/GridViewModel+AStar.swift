//
//  GridViewModel+Dijkstra.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/16/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI


extension GridViewModel {
    func findPathAStar() {
        findPathDijkstra { left, right -> Int in
            Hex.distance(left, right) * 20
        }
    }
}
