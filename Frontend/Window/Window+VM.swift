//
//  Window+VM.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine

extension Window {

    struct ViewModel {

        class Interface: ObservableObject, Identifiable {

            @Published var tabsCountText: String = ""
            @Published var tabsHeaderHidden = true
            @Published var selectedTabVM: Tab.Content.ViewModel.Interface

            let tabsHeader: Tab.Header.ViewModel.Interface
            let goBackButton: Controls.Button.ViewModel.Interface
            let searchBarVM: Controls.SearchBar.ViewModel.Interface
            let shieldButtonVM: Controls.Button.ViewModel.Interface
            let goForwardButton: Controls.Button.ViewModel.Interface
            let newPageButtonVM: Controls.Button.ViewModel.Interface
            let overviewButtonVM: Controls.Button.ViewModel.Interface
            let preferencesButtonVM: Controls.Button.ViewModel.Interface

            init(

                tabsHeader: Tab.Header.ViewModel.Interface,
                selectedTabVM: Tab.Content.ViewModel.Interface,
                goBackButton: Controls.Button.ViewModel.Interface,
                searchBarVM: Controls.SearchBar.ViewModel.Interface,
                shieldButtonVM: Controls.Button.ViewModel.Interface,
                goForwardButton: Controls.Button.ViewModel.Interface,
                newPageButtonVM: Controls.Button.ViewModel.Interface,
                overviewButtonVM: Controls.Button.ViewModel.Interface,
                preferencesButtonVM: Controls.Button.ViewModel.Interface

            ) {
                self.tabsHeader = tabsHeader
                self.searchBarVM = searchBarVM
                self.goBackButton = goBackButton
                self.selectedTabVM = selectedTabVM
                self.shieldButtonVM = shieldButtonVM
                self.goForwardButton = goForwardButton
                self.newPageButtonVM = newPageButtonVM
                self.overviewButtonVM = overviewButtonVM
                self.preferencesButtonVM = preferencesButtonVM
            }

        } // Interface

    } // ViewModel

} // Window
