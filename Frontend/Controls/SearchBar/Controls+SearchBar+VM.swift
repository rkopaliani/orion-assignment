//
//  Controls+SearchBar+VM.swift
//  Frontend
//
//  Created by script on 13.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI

extension Controls.SearchBar {

    struct ViewModel {

        class Interface: ObservableObject {

            let profilesButtonVM: Controls.Button.ViewModel.Interface

            @Published var title: String = ""
            @Published var prompt: String = ""
            @Published var urlText: String = ""

            var onCommitAction: (() -> Void)?

            init(profilesButtonVM: Controls.Button.ViewModel.Interface) {

                self.profilesButtonVM = profilesButtonVM
            }
        }

        // MARK: -

        final class Impl: Interface {

            init(configure: (Interface) -> Void = { _ in }) {

                super.init(

                    profilesButtonVM: Controls.Button.ViewModel.Impl {

                        $0.kind = .systemIcon
                        $0.icon = "circle.fill"
                    }
                )

                configure(self)
            }

        } // Impl

    } // ViewModel

} // Controls.SearchBar
