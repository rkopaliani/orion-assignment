//
//  SwiftUI+PreviewProvider.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import OSLog
import SwiftUI

import Swinject

// All below is in use by previews only.
#if DEBUG

private let logger = Logger(category: "SwiftUI.PreviewProvider", subsystem: "com.orion.frontend.preview")

extension PreviewProvider {

    public static func initializeLogging() {

        logger.info(
            """

            ⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻ \(self)

            """
        )
        Container.loggingFunction = {

            logger.fault("\($0)")
        }
    }

}

#endif
