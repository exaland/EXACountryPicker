#if canImport(UIKit)
import UIKit

extension UIImage {
    /// Returns a resized copy of the image keeping aspect ratio.
    ///
    /// This is used internally by `EXACountryPicker` to make flags fit the desired row height.
    func fitImage(size targetSize: CGSize) -> UIImage {
        guard targetSize.width > 0, targetSize.height > 0 else { return self }

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleRatio = min(widthRatio, heightRatio)

        let newSize = CGSize(width: size.width * scaleRatio, height: size.height * scaleRatio)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = self.scale

        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /**
        Returns a copy of the image with rounded corners.
     */
    func setRadius(_ radius: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = self.scale

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            let rect = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
            self.draw(in: rect)
        }

    }

    /// Creates a solid color image (useful as a placeholder when a flag is missing).
    static func ex_solidColor(_ color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
#endif
