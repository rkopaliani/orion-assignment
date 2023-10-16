//
//  Window+VM+Impl.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import OSLog

import Swinject

private let logger = Logger(category: "Window.VM")

extension Window.ViewModel {

    struct Factory {

        static func register(with container: Container, scheduler: AnyScheduler) {

            let threadSafeResolver = container.synchronize()

            container.register(Interface.self) { _ in

                Impl(resolver: threadSafeResolver, scheduler: scheduler)
            }
            .inObjectScope(.transient)

            Tab.ViewModel.Factory.register(with: container, scheduler: scheduler)
        }
    }

    private final class Impl: Interface {

        init(resolver: Resolver, scheduler: AnyScheduler) {

            self.resolver = resolver
            self.scheduler = scheduler

            self.model = resolver.resolve(Model.Interface.self)!

            super.init(

                goBackButton: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "chevron.backward"
                },
                searchBarVM: Controls.SearchBar.ViewModel.Impl {

                    $0.title = "Search or enter website name"
                },
                shieldButtonVM: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "shield.lefthalf.filled"
                },
                goForwardButton: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "chevron.forward"
                },
                newPageButtonVM: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "plus"
                },
                overviewButtonVM: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "square.grid.2x2"
                },
                preferencesButtonVM: Controls.Button.ViewModel.Impl {
                    $0.kind = .systemIcon
                    $0.icon = "gear"
                }
            )

            preferencesButtonVM.action = { [weak self] in

                let tabsViewModel = resolver.resolve(Tab.ViewModel.Interface.self)!
                self?.tabVMs.append(tabsViewModel)
            }
            searchBarVM.onCommitAction = { [weak self] in

                guard let self else {
                    return
                }
                guard let url = URL(string: self.searchBarVM.urlText), let currentTab = self.tabVMs.first else {
                    return
                }
                currentTab.webViewVM.url = url
            }
        }

        // MARK: - Privates

        private typealias Model = Window.Model
        private typealias TextIds = Window.Assets.TextIds

        private let resolver: Resolver
        private let scheduler: AnyScheduler

        private let model: Model.Interface

        private var cancellables = Set<AnyCancellable>()

    } // Impl

} // Window.ViewModel
