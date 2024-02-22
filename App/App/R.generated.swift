//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  #if os(iOS) || os(tvOS)
  /// This `R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    #endif

    fileprivate init() {}
  }
  #endif

  /// This `R.color` struct is generated, and contains static references to 1 colors.
  struct color {
    /// Color `AccentColor`.
    static let accentColor = Rswift.ColorResource(bundle: R.hostingBundle, name: "AccentColor")

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func accentColor(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.accentColor, compatibleWith: traitCollection)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func accentColor(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.accentColor.name)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.image` struct is generated, and contains static references to 6 images.
  struct image {
    /// Image `bets`.
    static let bets = Rswift.ImageResource(bundle: R.hostingBundle, name: "bets")
    /// Image `faq`.
    static let faq = Rswift.ImageResource(bundle: R.hostingBundle, name: "faq")
    /// Image `logo`.
    static let logo = Rswift.ImageResource(bundle: R.hostingBundle, name: "logo")
    /// Image `notification`.
    static let notification = Rswift.ImageResource(bundle: R.hostingBundle, name: "notification")
    /// Image `pay`.
    static let pay = Rswift.ImageResource(bundle: R.hostingBundle, name: "pay")
    /// Image `teams`.
    static let teams = Rswift.ImageResource(bundle: R.hostingBundle, name: "teams")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "bets", bundle: ..., traitCollection: ...)`
    static func bets(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.bets, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "faq", bundle: ..., traitCollection: ...)`
    static func faq(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.faq, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "logo", bundle: ..., traitCollection: ...)`
    static func logo(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.logo, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "notification", bundle: ..., traitCollection: ...)`
    static func notification(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.notification, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "pay", bundle: ..., traitCollection: ...)`
    static func pay(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.pay, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "teams", bundle: ..., traitCollection: ...)`
    static func teams(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.teams, compatibleWith: traitCollection)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.nib` struct is generated, and contains static references to 1 nibs.
  struct nib {
    /// Nib `MainView`.
    static let mainView = _R.nib._MainView()

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "MainView", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.mainView) instead")
    static func mainView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.mainView)
    }
    #endif

    static func mainView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
      return R.nib.mainView.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
    }

    fileprivate init() {}
  }

  /// This `R.string` struct is generated, and contains static references to 1 localization tables.
  struct string {
    /// This `R.string.localizable` struct is generated, and contains static references to 8 localization keys.
    struct localizable {
      /// en translation: PREDICTIONS
      ///
      /// Locales: en, ru
      static let tooltip_bets_title = Rswift.StringResource(key: "tooltip_bets_title", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "ru"], comment: nil)
      /// en translation: PURCHASES
      ///
      /// Locales: en, ru
      static let tooltip_paid_title = Rswift.StringResource(key: "tooltip_paid_title", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "ru"], comment: nil)
      /// en translation: Picks
      ///
      /// Locales: en, ru
      static let picks = Rswift.StringResource(key: "picks", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "ru"], comment: nil)
      /// en translation: Purchases
      ///
      /// Locales: en, ru
      static let paid_cap = Rswift.StringResource(key: "paid_cap", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "ru"], comment: nil)
      /// en translation: QUESTIONS
      ///
      /// Locales: en, ru
      static let tooltip_faq_title = Rswift.StringResource(key: "tooltip_faq_title", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "ru"], comment: nil)
      /// en translation: Questions
      ///
      /// Locales: en, ru
      static let questions = Rswift.StringResource(key: "questions", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "ru"], comment: nil)
      /// en translation: TEAMS
      ///
      /// Locales: en, ru
      static let tooltip_teams_title = Rswift.StringResource(key: "tooltip_teams_title", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "ru"], comment: nil)
      /// en translation: Teams
      ///
      /// Locales: en, ru
      static let teams_cap = Rswift.StringResource(key: "teams_cap", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "ru"], comment: nil)

      /// en translation: PREDICTIONS
      ///
      /// Locales: en, ru
      static func tooltip_bets_title(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("tooltip_bets_title", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "tooltip_bets_title"
        }

        return NSLocalizedString("tooltip_bets_title", bundle: bundle, comment: "")
      }

      /// en translation: PURCHASES
      ///
      /// Locales: en, ru
      static func tooltip_paid_title(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("tooltip_paid_title", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "tooltip_paid_title"
        }

        return NSLocalizedString("tooltip_paid_title", bundle: bundle, comment: "")
      }

      /// en translation: Picks
      ///
      /// Locales: en, ru
      static func picks(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("picks", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "picks"
        }

        return NSLocalizedString("picks", bundle: bundle, comment: "")
      }

      /// en translation: Purchases
      ///
      /// Locales: en, ru
      static func paid_cap(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("paid_cap", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "paid_cap"
        }

        return NSLocalizedString("paid_cap", bundle: bundle, comment: "")
      }

      /// en translation: QUESTIONS
      ///
      /// Locales: en, ru
      static func tooltip_faq_title(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("tooltip_faq_title", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "tooltip_faq_title"
        }

        return NSLocalizedString("tooltip_faq_title", bundle: bundle, comment: "")
      }

      /// en translation: Questions
      ///
      /// Locales: en, ru
      static func questions(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("questions", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "questions"
        }

        return NSLocalizedString("questions", bundle: bundle, comment: "")
      }

      /// en translation: TEAMS
      ///
      /// Locales: en, ru
      static func tooltip_teams_title(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("tooltip_teams_title", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "tooltip_teams_title"
        }

        return NSLocalizedString("tooltip_teams_title", bundle: bundle, comment: "")
      }

      /// en translation: Teams
      ///
      /// Locales: en, ru
      static func teams_cap(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("teams_cap", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "teams_cap"
        }

        return NSLocalizedString("teams_cap", bundle: bundle, comment: "")
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    #if os(iOS) || os(tvOS)
    try nib.validate()
    #endif
    #if os(iOS) || os(tvOS)
    try storyboard.validate()
    #endif
  }

  #if os(iOS) || os(tvOS)
  struct nib: Rswift.Validatable {
    static func validate() throws {
      try _MainView.validate()
    }

    struct _MainView: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "MainView"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }

      static func validate() throws {
        if UIKit.UIImage(named: "bets", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'bets' is used in nib 'MainView', but couldn't be loaded.") }
        if UIKit.UIImage(named: "faq", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'faq' is used in nib 'MainView', but couldn't be loaded.") }
        if UIKit.UIImage(named: "pay", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'pay' is used in nib 'MainView', but couldn't be loaded.") }
        if UIKit.UIImage(named: "teams", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'teams' is used in nib 'MainView', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }
  #endif

  #if os(iOS) || os(tvOS)
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      #if os(iOS) || os(tvOS)
      try launchScreen.validate()
      #endif
    }

    #if os(iOS) || os(tvOS)
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = UIKit.UIViewController

      let bundle = R.hostingBundle
      let name = "LaunchScreen"

      static func validate() throws {
        if UIKit.UIImage(named: "logo", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'logo' is used in storyboard 'LaunchScreen', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    fileprivate init() {}
  }
  #endif

  fileprivate init() {}
}
