//
//  PriorityQueue.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/14/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation

struct PriorityQueue<Element: Equatable> {
    var heap: Heap<Element>
    
    var isEmpty: Bool {
        return heap.isEmpty
    }
    
    init(elements: [Element], priorityFunction: @escaping (Element, Element) -> Bool) {
        heap = Heap(elements: elements, priorityFunction: priorityFunction)
    }
    
    func getHighestPriority() -> Element? {
        return heap.getElement(at: 0)
    }
    
    mutating func enqueue(_ item: Element) {
        heap.enqueue(item)
    }
    
    mutating func dequeue() -> Element? {
        return heap.dequeue()
    }
    
    mutating func peek() -> Element? {
        return heap.peek()
    }
    
}

struct Heap<Element: Equatable> {
    var elements: [Element]
    let priorityFunction: (Element, Element) -> Bool
    
    init(elements: [Element], priorityFunction: @escaping (Element, Element) -> Bool) {
        self.elements = elements
        self.priorityFunction = priorityFunction
        buildHeap()
    }
    
    var isEmpty: Bool {
        return elements.count == 0
    }
    var count: Int {
        return elements.count
    }
    
    //Helper
    func isRoot(_ index: Int) -> Bool {
        return index == 0
    }
    func getLeftChildIndex(of index: Int) -> Int {
        return (2 * index) + 1
    }
    func getRightChildIndex(of index: Int) -> Int {
        return (2 * index) + 2
    }
    func getParentIndex(of index: Int) -> Int {
        return (index - 1) / 2
    }
    func getElement(at index: Int) -> Element? {
        guard index < elements.count else {
            return nil
        }
        return elements[index]
    }
    func isHigherPriority(at index: Int, than secondIndex: Int) -> Bool {
        let el1 = getElement(at: index)
        let el2 = getElement(at: secondIndex)
        if el1 == nil && el2 != nil {
            return false
        }
        if el2 == nil && el1 != nil {
            return true
        }
        if el2 == nil && el1 == nil {
            return false
        }
        return priorityFunction(el1!, el2!)
    }
    
    func getFamilyHighest(at index: Int) -> Int {
        let children1 = getLeftChildIndex(of: index)
        let children2 = getRightChildIndex(of: index)
        let maxChild = isHigherPriority(at: children1, than: children2) ? children1 : children2
        return isHigherPriority(at: index, than: maxChild) ? index : maxChild
    }
    
    mutating func swap(at index: Int, with secondIndex: Int) {
        guard index != secondIndex else {
            return
        }
        elements.swapAt(index, secondIndex)
    }
    
    
    //Heap sift function
    mutating func siftUp(at index: Int) {
        guard !isRoot(index) else { return }
        
        let parent = getParentIndex(of: index)
        if !isHigherPriority(at: index, than: parent) {
            return
        }
        
        swap(at: index, with: parent)
        siftUp(at: parent)
    }
    mutating func siftDown(at index: Int) {
        let highestIndex = getFamilyHighest(at: index)
        if index == highestIndex {
            return
        }
        swap(at: index, with: highestIndex)
        siftDown(at: highestIndex)
    }
    mutating func buildHeap() {
        for index in (0 ..< count / 2).reversed() {
            siftDown(at: index)
        }
    }
    
    //Queue function
    mutating func enqueue(_ element: Element) {
        //customize
//        for i in 0..<self.elements.count {
//            if self.elements[i] == element && priorityFunction(element, self.elements[i]) {
//                self.elements[i] = element
//                siftUp(at: i)
//                return
//            }
//        }
        
        elements.append(element)
        siftUp(at: count - 1)
    }
    
    mutating func dequeue() -> Element? {
        guard !isEmpty else { return nil }
        swap(at: 0, with: count - 1)
        let ele = elements.removeLast()
        if !isEmpty{
            siftDown(at: 0)
        }
        return ele
    }
    
    mutating func peek() -> Element? {
        return elements.first
    }
 }
