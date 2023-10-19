//
//  Window+Model+Impl.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import AppKit
import Combine
import OSLog

import FavIcon
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

            Tab.Content.Model.Factory.register(with: container)
        }
    }

    private final class Impl: Interface {

        init(resolver: Resolver) {

            self.resolver = resolver

            // MARK: - Resolve your dependencies here
        }

        // MARK: - Interface

        func websiteFavIcon(for url: URL) -> AnyPublisher<NSImage?, Never> {

            Deferred {

                Future { promise in

                    do {

                        try FavIcon.downloadPreferred(url, width: 32, height: 32) { downloadResult in

                            if case let .success(image) = downloadResult {

                                promise(.success(image))

                            } else {

                                // we ignore error for now
                                promise(.success(nil))
                            }

                        }

                    } catch {

                        promise(.success(nil))
                    }
                }
            }
            .eraseToAnyPublisher()
        }

        // MARK: - Privates

        private let resolver: Resolver

        private var subscriptions = Set<AnyCancellable>()

    } // Impl

} // Window.Model
