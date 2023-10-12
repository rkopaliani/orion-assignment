//
//  Utilities+Localization.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import OSLog

private let logger = Logger(category: "Utilities.Localization")

/// Defines protocol for working with localization.
///
protocol Utilities_Localization_Interface {

    /// Gets current application language.
    ///
    var currentLanguage: Utilities.Localization.Language { get }

    /// Activates double length pseudo-language.
    ///
    /// Helps to make sure views reposition and resize appropriately for international text using pseudolocalizations.
    /// Default value is `false`.
    ///
    var doubleLengthPseudolanguage: Bool { get set }

    /// Returns translated string for the given key.
    ///
    subscript(_ key: String) -> String { get }

    /// Sets up application language, so that it will in range of actually supported languages.
    ///
    /// - parameter desiredLocale: Optional "desired" locale to override user preferred languages.
    ///                            In use by SwiftUI previews to force desired language.
    ///
    func setUpAppLanguage(desired desiredLocale: Locale?)

} // Utilities_Localization_Interface

// swiftlint:disable nslocalizedstring_key

extension Utilities {

    // MARK: -

    open class Localization: Utilities_Localization_Interface {

        public typealias Interface = Utilities_Localization_Interface

        /// Defines list of possible application languages.
        ///
        /// Format of case values should correspond to a `Locale` identifier.
        ///
        public enum Language: String, Codable, CustomStringConvertible, CaseIterable {

            // MARK: -

            case english = "en"
            case norwegian = "no"

            // MARK: -

            public var locale: Locale {

                Locale(identifier: rawValue)
            }

            // MARK: - CustomStringConvertible

            public var description: String {

                "'\(rawValue)'"
            }

            // MARK: - File Privates:

            /// Determines whether given locale (by its id) is compatible with this language.
            ///
            /// For example: `english` ("en") is compatible with "en", "en-US", "en-GB" but NOT with "ru" or "ru-US".
            ///
            fileprivate func isCompatible(with otherLocalId: String) -> Bool {

                let thisLocale = self.locale
                let otherLocale = Locale(identifier: otherLocalId)

                // Main priority is language code, then language script, and finally the region.

                guard let thisId = thisLocale.language.languageCode?.identifier,
                      let otherId = otherLocale.language.languageCode?.identifier,
                      thisId == otherId else {

                    return false
                }

                if let thisScriptCode = thisLocale.language.script?.identifier,
                    thisScriptCode != otherLocale.language.script?.identifier {

                    return false
                }

                if let thisRegion = thisLocale.region?.identifier, thisRegion != otherLocale.region?.identifier {

                    return false
                }

                return true
            }

        } // Language

        public init(with bundle: Bundle, stringsTableName: String? = nil) {

            self.bundle = bundle
            self.stringsTableName = stringsTableName

            logger.info("Supported languages are \(Language.allCases).")
        }

        // MARK: - Interface

        public private(set) var currentLanguage = Language.english

        public var doubleLengthPseudolanguage = false

        public func setUpAppLanguage(desired desiredLocale: Locale?) {

            logger.trace("Setting up app language (desired=\(desiredLocale.description())...")

            let langIdsToUse: [String]
            if let desiredLocale = desiredLocale {

                langIdsToUse = [desiredLocale.identifier]

            } else {

                langIdsToUse = Self.collectPreferredLanguages()
                logger.trace("Preferred languages are \(langIdsToUse).")
            }

            // Filter the user's preferred languages by "supported" as well.
            // If none is left then we will just use our list of supported languages.
            //
            var appLangIds = langIdsToUse

                .compactMap { userPrefLangId -> (lang: Language, id: String)? in

                    let maybeLanguage = Language.allCases.first { $0.isCompatible(with: userPrefLangId) }
                    guard let language = maybeLanguage else {

                        return nil
                    }

                    return (lang: language, id: userPrefLangId)
                }

            if appLangIds.isEmpty {

                logger.trace(
                    """
                    None of user preferred languages are supported\
                     - fallback to '\(Language.allCases.first?.locale.identifier ?? "en")'.
                    """
                )
                appLangIds = Language.allCases.map { (lang: $0, id: $0.locale.identifier) }
            }

            if let appLang = appLangIds.first?.lang {

                currentLanguage = appLang
            }

            // Try to open "language" sub-bundle (the `.lproj` one)
            //   if threre is need to override preferred languages.
            //
            if desiredLocale != nil, let langBundlePath = bundle.path(

                forResource: currentLanguage.rawValue,
                ofType: "lproj"

            ) {

                languageBundle = Bundle(path: langBundlePath)

            } else {

                languageBundle = nil
            }

            logger.debug("App languages are '\(appLangIds)'.")
        }

        public subscript(_ key: String) -> String {

            guard !key.isEmpty else {

                return ""
            }

            // Try first language specific bundle (if any),
            //   and only then fallback to the default one.
            //
            if let languageBundle = languageBundle {

                let result = NSLocalizedString(

                    key, tableName: stringsTableName, bundle: languageBundle, comment: ""
                )
                if result != key {

                    return doubleLengthPseudolanguage ? "\(result)\(result)" : result
                }
            }

            let result = NSLocalizedString(key, tableName: stringsTableName, bundle: bundle, comment: "")
            return doubleLengthPseudolanguage ? "\(result)\(result)" : result
        }

        // MARK: - Privates:

        private let bundle: Bundle
        private let stringsTableName: String?

        private var languageBundle: Bundle?

        private static func collectPreferredLanguages() -> [String] {

            Locale.preferredLanguages
        }
    }

} // Utilities
