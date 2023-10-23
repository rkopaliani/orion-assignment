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

            Tab.Content.ViewModel.Factory.register(with: container, scheduler: scheduler)
        }
    }

    private final class Impl: Interface {

        init(resolver: Resolver, scheduler: AnyScheduler) {

            self.resolver = resolver
            self.scheduler = scheduler

            self.model = resolver.resolve(Model.Interface.self)!

            super.init(

                tabsHeader: Tab.Header.ViewModel.Impl { _ in },
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

                self?.selectedTabContentVM?.onGoBack()
            }
            goForwardButton.action = { [weak self] in

                self?.selectedTabContentVM?.onGoForward()
            }
            newPageButtonVM.action = { [weak self] in

                self?.openNewTab()
            }
            searchBarVM.onCommitAction = { [weak self] in

                guard let self, let url = URL(string: self.searchBarVM.urlText) else {

                    return
                }
                self.selectedTabContentVM?.onLoadUrl(url)
            }

            $selectedTabContentVM

                .removeDuplicates()
                .receive(on: scheduler)
                .unwrap()
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

                    tabVM.webViewVM.$url

                        .receive(on: self.scheduler)
                        .map { $0?.relativeString ?? "" }
                        .weakAssign(to: \.urlText, on: self.searchBarVM)
                        .store(in: &cancellables)
                }
                .store(in: &cancellables)

//            subject.tabs
//
//                .receive(on: scheduler)
//                .flattenMap(transform: createTab(item:))
//                .weakAssign(to: \.tabVMs, on: tabsHeader)
//                .store(in: &cancellables)

            tabsHeader.$tabVMs

//            subject.tabs
//
                .receive(on: scheduler)
                .map { $0.count }
                .map { "\($0) Tabs" }
                .weakAssign(to: \.tabsCountText, on: self)
                .store(in: &cancellables)

            // just creating empty tab
            // no state restoration here
            openNewTab()
        }

        // MARK: - Privates

        private typealias Model = Window.Model
        private typealias TextIds = Window.Assets.TextIds

        private typealias TabVM = Tab.Content.ViewModel
        private typealias TabItemVM = Tab.Header.Item.ViewModel

        private let resolver: Resolver
        private let scheduler: AnyScheduler

        private let model: Model.Interface

        private var tabContentVMs: Set<TabVM.Interface> = Set()
        private var cancellables = Set<AnyCancellable>()
        private var tabCancellables = Set<AnyCancellable>()

        private func createTab(item contentViewModel: TabVM.Interface) -> TabItemVM.Interface {

            let itemViewModel = TabItemVM.Impl {

                $0.icon = nil

                if let url = contentViewModel.webViewVM.url {

                    $0.title = url.host() ?? url.relativeString

                } else {

                    $0.title = "Empty Tab"
                }
            }

            itemViewModel.$selected

                .receive(on: scheduler)
                .filter { $0 }
                .sink { [weak self] _ in

                    self?.selectedTabContentVM = contentViewModel
                }
                .store(in: &cancellables)

            contentViewModel.$title

                .receive(on: scheduler)
                .unwrap()
                .filter { !$0.isEmpty }
                .weakAssign(to: \.title, on: itemViewModel)
                .store(in: &cancellables)

            contentViewModel.webViewVM.$url

                .unwrap()
                .removeDuplicates()
                .flatMap { [weak self] in

                    guard let self else {

                        return Just<NSImage?>(nil).eraseToAnyPublisher()
                    }

                    return self.model.websiteFavIcon(for: $0)
                }
                .unwrap()
                .map { Image(nsImage: $0) }
                .receive(on: scheduler)
                .weakAssign(to: \.icon, on: itemViewModel)
                .store(in: &cancellables)

            itemViewModel.onCloseAction = { [weak self, itemViewModel] in

                guard let self else {

                    return
                }

                self.tabContentVMs.remove(contentViewModel)
                self.tabsHeader.tabVMs.removeAll { $0 == itemViewModel }
                self.updateTabSelection()
            }
            itemViewModel.onAction = { [weak self, itemViewModel] in

                guard let self else {

                    return
                }

                self.updateTabSelection(with: itemViewModel)
            }

            return itemViewModel
        }

        private func openNewTab() {

            let newTabVM = resolver.resolve(Tab.Content.ViewModel.Interface.self)!
            let tabItemVM = createTab(item: newTabVM)
            tabsHeader.tabVMs.append(tabItemVM)
            updateTabSelection()
        }

        private func updateTabSelection(with tabItem: TabItemVM.Interface? = nil) {

            let tabItems = tabsHeader.tabVMs
            guard let selectedTabItem = tabItem ?? tabItems.last else {
                /// probably should close browser window here
                return
            }

            for tabItem in tabItems {

                tabItem.selected = tabItem == selectedTabItem
            }
        }

    } // Impl

} // Window.ViewModel

extension CurrentValueSubject where Output: RangeReplaceableCollection, Output.Element: Equatable {

    func append(_ element: Output.Element) {

        var value = self.value
        value.append(element)
        self.value = value
    }

    func remove(_ element: Output.Element) {

        var value = self.value
        value.removeAll { $0 == element }
        self.value = value
    }
}
