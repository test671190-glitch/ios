import TKUIKit
import UIKit

/// The marks the app shows for itself.
enum BrandMarks {
    /// Beside a connected dapp in the settings list.
    static var small: UIImage {
        .TKUIKit.Icons.Size20.tonkeeprDemoModeSmall
    }

    /// The staking-pool badge, sitting in a row of full-colour discs.
    static var stakingPoolBadge: UIImage {
        .TKUIKit.Icons.Size44.tonkeeprDemoModeLogo
    }

    /// The tile that stands for this app beside a dapp's own icon on the connect screens.
    enum AppIcon {
        /// Raster artwork with the gradient baked in, so it fills the tile and takes no tint.
        static let image: UIImage = .TKUIKit.Artwork.Brand.keeperAppIcon
        static let tintColor: UIColor? = nil
        static let contentMode: UIView.ContentMode = .scaleAspectFill
    }
}
