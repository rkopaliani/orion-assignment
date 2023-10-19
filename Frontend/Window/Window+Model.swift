//
//  Window+Model.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import AppKit
import Combine

protocol Window_Model_Interface {

    func websiteFavIcon(for url: URL) -> AnyPublisher<NSImage?, Never>

} // Window_Model_Interface

extension Window {

    struct Model {

        typealias Interface = Window_Model_Interface

    } // Model

} // Window
