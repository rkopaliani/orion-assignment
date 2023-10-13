//
//  Controls+Button.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

extension Controls {

    struct Button {

        enum Kind: CustomStringConvertible {

            case plain
            case systemIcon

            // MARK: CustomStringConvertible

            var description: String {

                switch self {
                case .plain: return "plain"
                case .systemIcon: return "systemIcon"
                }
            }

        } // Kind

    } // Button

} // Controls
