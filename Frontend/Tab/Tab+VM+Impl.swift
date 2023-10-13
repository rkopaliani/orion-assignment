//
//  Tab+VM+Impl.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import OSLog

import Swinject

private let logger = Logger(category: "Tab.VM")

extension Tab.ViewModel {

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

            self.model = resolver.resolve(Model.Interface.self)!

            super.init(

                webViewVM: Controls.WebView.ViewModel.Impl { _ in

                }
            )
        }

        // MARK: - Privates

        private typealias Model = Tab.Model
        private typealias TextIds = Tab.Assets.TextIds

        private let resolver: Resolver
        private let scheduler: AnyScheduler

        private let model: Model.Interface

        private var cancellables = Set<AnyCancellable>()

    } // Impl

} // Tab.ViewModel
