//
//  Window+VM+Impl.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import OSLog

import SwiftUI
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

                selectedTabVM: resolver.resolve(Tab.ViewModel.Interface.self)!,
                tabsVM: Window.TabsView.ViewModel.Impl { _ in },
                goBackButton: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "chevron.backward"
                    $0.isDisabled = true
                },
                searchBarVM: Controls.SearchBar.ViewModel.Impl {

                    $0.title = "Search or enter website name"
                },
                shieldButtonVM: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "shield.lefthalf.filled"
                    $0.isDisabled = true
                },
                goForwardButton: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "chevron.forward"
                    $0.isDisabled = true
                },
                newPageButtonVM: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "plus"
                },
                overviewButtonVM: Controls.Button.ViewModel.Impl {

                    $0.kind = .systemIcon
                    $0.icon = "square.grid.2x2"
                    $0.isDisabled = true
                },
                preferencesButtonVM: Controls.Button.ViewModel.Impl {
                    $0.kind = .systemIcon
                    $0.icon = "gear"
                    $0.isDisabled = true
                }
            )

            goBackButton.action = { [weak self] in

                self?.selectedTabVM.goBack()
            }
            goForwardButton.action = { [weak self] in

                self?.selectedTabVM.goForward()
            }
            newPageButtonVM.action = { [weak self] in

                self?.openNewTab()
            }
            searchBarVM.onCommitAction = { [weak self] in

                guard let self, let url = URL(string: self.searchBarVM.urlText) else {

                    return
                }
                self.selectedTabVM.loadUrl(url)
            }

            $selectedTabVM

                .removeDuplicates()
                .receive(on: scheduler)
                .sink { [weak self] tabVM in

                    guard let self else {

                        return
                    }

                    self.tabCancellables.removeAll(keepingCapacity: true)

                    tabVM.$canGoBack

                        .receive(on: self.scheduler)
                        .map { !$0 }
                        .weakAssign(to: \.isDisabled, on: self.goBackButton)
                        .store(in: &self.tabCancellables)

                    tabVM.$canGoForward

                        .receive(on: self.scheduler)
                        .map { !$0 }
                        .weakAssign(to: \.isDisabled, on: self.goForwardButton)
                        .store(in: &self.tabCancellables)

                    tabVM.$url

                        .receive(on: self.scheduler)
                        .map { $0?.relativeString ?? "" }
                        .weakAssign(to: \.urlText, on: self.searchBarVM)
                        .store(in: &cancellables)
                }
                .store(in: &cancellables)

            subject.tabs

                .receive(on: scheduler)
                .flattenMap(transform: create(tabHeaderViewModel:))
                .weakAssign(to: \.tabVMs, on: tabsVM)
                .store(in: &cancellables)

            subject.tabs

                .receive(on: scheduler)
                .weakAssign(to: \.tabVMs, on: self)
                .store(in: &cancellables)

            subject.tabs

                .receive(on: scheduler)
                .map { $0.count }
                .map { "\($0) Tabs" }
                .weakAssign(to: \.tabsCountText, on: self)
                .store(in: &cancellables)

            // just creating empty tab
            // no state restoration here
            subject.tabs.send([selectedTabVM])
        }

        // MARK: - Privates

        private typealias Model = Window.Model
        private typealias TextIds = Window.Assets.TextIds
        private typealias TabViewModel = Window.TabsView.Tab.ViewModel

        private let resolver: Resolver
        private let scheduler: AnyScheduler

        private let model: Model.Interface
        private let subject = (

            tabs: CurrentValueSubject<[Tab.ViewModel.Interface], Never>([]),
            ()
        )

        private var cancellables = Set<AnyCancellable>()
        private var tabCancellables = Set<AnyCancellable>()

        private func create(tabHeaderViewModel viewModel: Tab.ViewModel.Interface) -> TabViewModel.Interface {

            let tabVM = TabViewModel.Impl {

                $0.icon = nil

                if let url = viewModel.url {

                    $0.title = url.host() ?? url.relativeString

                } else {

                    $0.title = "Empty Tab"
                }
            }

            viewModel.$url

                .removeDuplicates()
                .receive(on: scheduler)
                .map { $0?.host() }
                .unwrap()
                .sink(receiveValue: { title in
                    tabVM.title = title
                })
                .store(in: &cancellables)

            viewModel.$url

                .unwrap()
                .removeDuplicates()
                .flatMap {
                    self.model.websiteFavIcon(for: $0)
                }
                .unwrap()
                .map { Image(nsImage: $0) }
                .receive(on: scheduler)
                .sink(receiveValue: { image in

                    tabVM.icon = image
                })
                .store(in: &cancellables)

            return tabVM
        }

        private func openNewTab() {

            var tabs = subject.tabs.value
            let newTabVM = resolver.resolve(Tab.ViewModel.Interface.self)!
            tabs.append(newTabVM)
            subject.tabs.send(tabs)
            selectedTabVM = newTabVM
        }

    } // Impl

} // Window.ViewModel
