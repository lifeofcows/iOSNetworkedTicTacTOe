//
//  EventStream.swift
//  Command-Server
//
//  Created by Tony White on 2017-03-15.
//  Copyright © 2017 Tony White. All rights reserved.
//

import Foundation

typealias Socket = GCDAsyncSocket
typealias SocketDelegate = GCDAsyncSocketDelegate

protocol EventStreamInput {
    func get()
    func get(data: Data) -> Event
}

protocol EventOutputStream {
    func put(event: Event)
}

protocol Closeable {
    func close()
}

protocol EventStream: EventStreamInput, EventOutputStream, Closeable {
}
