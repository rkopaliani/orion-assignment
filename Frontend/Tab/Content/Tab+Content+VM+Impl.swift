//
//  Tab+Content+VM+Impl.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import OSLog

import Swinject

private let logger = Logger(category: "Tab.VM")

extension Tab.Content.ViewModel {

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

            webViewVM.$canGoBack

                .removeDuplicates()
                .receive(on: scheduler)
                .weakAssign(to: \.canGoBack, on: self)
                .store(in: &cancellables)

            webViewVM.$canGoForward

                .removeDuplicates()
                .receive(on: scheduler)
                .weakAssign(to: \.canGoForward, on: self)
                .store(in: &cancellables)

            webViewVM.$url

                .removeDuplicates()
                .receive(on: scheduler)
                .weakAssign(to: \.url, on: self)
                .store(in: &cancellables)

            webViewVM.$title

                .removeDuplicates()
                .receive(on: scheduler)
                .weakAssign(to: \.title, on: self)
                .store(in: &cancellables)

        }

        // MARK: - Privates

        private typealias Model = Tab.Content.Model
        private typealias TextIds = Tab.Content.Assets.TextIds

        private let resolver: Resolver
        private let scheduler: AnyScheduler

        private let model: Model.Interface

        private var cancellables = Set<AnyCancellable>()

    } // Impl

} // Tab.Content.ViewModel
