//
//  Window+View.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI
import WebKit

import Swinject

extension Window {

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

} // Window

#if DEBUG

struct Window_Preview_Provider: PreviewProvider {

    static var previews: some SwiftUI.View {

        View(viewModel: staticContext.viewModel)
    }

    private typealias View = Window.View
    private typealias Model = Window.Model
    private typealias ViewModel = Window.ViewModel

    private final class Context: ObservableObject {

        let viewModel: ViewModel.Interface

        init(diPair: Container.SyncPair) {

            self.viewModel = diPair.container.resolve(ViewModel.Interface.self)!
        }

    } // Context

    private static var staticContext: Context = {

        initializeLogging()

        let diPair = Container.default

        let scheduler = DispatchQueue.main.asAnyScheduler()
        Model.Factory.register(with: diPair.container)
        ViewModel.Factory.register(

            with: diPair.container,
            scheduler: scheduler
        )

        return .init(diPair: diPair)
    }()

} // Window_Preview_Provider

#endif
