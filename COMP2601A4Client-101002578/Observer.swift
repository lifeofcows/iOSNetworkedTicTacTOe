//
//  Observer.swift
//  COMP2601A4Client-101002578
//
//  Created by Maxim Kuzmenko on 2017-03-28.
//  Copyright © 2017 Maxim Kuzmenko. All rights reserved.
//

import Foundation

protocol Observer {
    func didWin(verdict: Int, player: Int);
    var xMoves : [Int] { get }
    var oMoves :  [Int] { get }
    var moves : [Int] { get }
};
