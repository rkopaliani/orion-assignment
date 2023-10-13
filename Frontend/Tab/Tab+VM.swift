//
//  Tab+VM.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine

extension Tab {

    struct ViewModel {

        class Interface: ObservableObject, Identifiable {

            let webViewVM: Controls.WebView.ViewModel.Interface

            init(webViewVM: Controls.WebView.ViewModel.Interface) {
                self.webViewVM = webViewVM
            }

        } // Interface

    } // ViewModel

} // Tab
