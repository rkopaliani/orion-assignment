//
//  Tab+Model+Impl.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import OSLog

import Swinject

private let logger = Logger(category: "Tab.Model")

extension Tab.Model {

    struct Factory {

        static func register(with container: Container, scheduler: AnyScheduler) {

            let threadSafeResolver = container.synchronize()

            container.register(Interface.self) { _ in

                Impl(resolver: threadSafeResolver, scheduler: scheduler)
            }
            .inObjectScope(.transient)
        }
    }

    private final class Impl: Interface {

        init(resolver: Resolver, scheduler: AnyScheduler) {

            self.resolver = resolver
            self.scheduler = scheduler

            // MARK: - Resolve your dependencies here

        }

        // MARK: - Interface

        // MARK: - Privates

        private let resolver: Resolver
        private let scheduler: AnyScheduler

        private var subscriptions = Set<AnyCancellable>()

    } // Impl

} // Tab.Model
