//
//  EventHandler.swift
//  Command-Server
//
//  Created by Tony White on 2017-03-15.
//  Copyright © 2017 Tony White. All rights reserved.
//

import Foundation

protocol EventHandler {
    func handleEvent(event: Event)
}
