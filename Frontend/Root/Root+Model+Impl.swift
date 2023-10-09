//
//  Root+Model+Impl.swift
//  Frontend
//
//  Created by script on 09.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import OSLog

import Swinject

private let logger = Logger(category: "Root.Model")

extension Root.Model {

    struct Factory {

        static func register(with container: Container) {

            let threadSafeResolver = container.synchronize()

            container.register(Interface.self) { _ in

                Impl(resolver: threadSafeResolver)
            }
            .inObjectScope(.transient)
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

} // Root.Model
