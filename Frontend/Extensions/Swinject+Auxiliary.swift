//
//  Swinject+Auxiliary.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Swinject

extension Container {

    /// Defines synchronized pair of DI container and its resolver.
    ///
    public struct SyncPair {

        /// Gets container for DI registrations.
        ///
        public let container = Container()

        /// Gets synchronized (thread safe) DI resolver for the container.
        ///
        public let resolver: Resolver

        public init() {

            self.resolver = container.synchronize()
        }

    } // SyncPair

    /// Gets shared (global) pair of DI container and its synchronized (thread safe) resolver.
    ///
    public static let `default` = SyncPair()

} // Container
