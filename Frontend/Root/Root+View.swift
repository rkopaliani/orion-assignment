//
//  Root+View.swift
//  Frontend
//
//  Created by script on 09.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI

import Swinject

extension Root {

    struct View: SwiftUI.View {

        @ObservedObject var viewModel: ViewModel.Interface

        var body: some SwiftUI.View {

            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()

        } // body

    } // View

} // Root

#if DEBUG

struct Root_Preview_Provider: PreviewProvider {

    static var previews: some SwiftUI.View {

        View(viewModel: staticContext.viewModel)
    }

    private typealias View = Root.View
    private typealias ViewModel = Root.ViewModel

    private final class Context: ObservableObject {

        let viewModel: ViewModel.Interface

        init(diPair: Container.SyncPair) {

            self.viewModel = diPair.container.resolve(ViewModel.Interface.self)!
        }

    } // Context

    private static var staticContext: Context = {

        initializeLogging()

        let diPair = Container.default

        ViewModel.Factory.register(

            with: diPair.container,
            scheduler: DispatchQueue.main.asAnyScheduler()
        )

        return .init(diPair: diPair)
    }()

} // Root_Preview_Provider

#endif
