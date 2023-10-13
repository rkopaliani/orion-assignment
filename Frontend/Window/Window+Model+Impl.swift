//
//  Window+Model+Impl.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import OSLog

import Swinject

private let logger = Logger(category: "Window.Model")

extension Window.Model {

    struct Factory {

        static func register(with container: Container) {

            let threadSafeResolver = container.synchronize()

            container.register(Interface.self) { _ in

                Impl(resolver: threadSafeResolver)
            }
            .inObjectScope(.transient)

            Tab.Model.Factory.register(with: container)
        }
    }

    private final class Impl: Interface {

        init(resolver: Resolver) {

            self.resolver = resolver

            // MARK: - Resolve your dependencies here
        }

        // MARK: - Interface

        // MARK: - Privates

        private let resolver: Resolver

        private var subscriptions = Set<AnyCancellable>()

    } // Impl

} // Window.Model
