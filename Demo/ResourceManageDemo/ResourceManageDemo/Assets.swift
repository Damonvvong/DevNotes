// SwiftGen xcassets template for Asprin
import UIKit

enum Asset {
  static let damonwong = ImageAsset(name: "Damonwong")
}

struct ImageAsset {
    fileprivate var name: String
    var image: UIImage {
        let bundle = Bundle(for: BundleToken.self)
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        guard let result = image else { 
            fatalError("Unable to load image named \(name).") 
        }
        return result
    }
}

final class BundleToken { }


