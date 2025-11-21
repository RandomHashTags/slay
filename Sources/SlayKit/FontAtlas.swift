
import Freetype2

// https://freetype.org/freetype2/docs/tutorial/step1.html
public struct FontAtlas: ~Copyable, @unchecked Sendable {
    public private(set) var textureWidth = 0
    public private(set) var textureHeight = 0
    public private(set) var glyphs = [UInt32:Glyph]()
    public private(set) var pixelData = [UInt8]() // single channel

    private var library:FT_Library! = nil
    private var face:FT_Face! = nil

    public init?(
        ttfPath: String,
        pixelSize: Int,
        characters: [UInt32] = Array(32...126)
    ) {
        // initialize FreeType
        guard FT_Init_FreeType(&library) == 0 else {
            return nil
        }
        guard newFace(ttfPath: ttfPath, pixelSize: pixelSize) == nil else {
            return nil
        }
        setup(characters: characters)
    }

    // MARK: Deinit
    deinit {
        if let face {
            FT_Done_Face(face)
        }
        if let library {
            FT_Done_FreeType(library)
        }
    }
}

// MARK: New face
extension FontAtlas {
    public mutating func newFace(
        ttfPath: String,
        pixelSize: Int
    ) -> FT_Error? {
        let newFaceResult = FT_New_Face(library, ttfPath, 0, &face)
        guard newFaceResult == 0 else {
            return newFaceResult
        }
        let setPixelSizeResult = FT_Set_Pixel_Sizes(face, UInt32(pixelSize), UInt32(pixelSize))
        guard setPixelSizeResult == 0 else {
            return setPixelSizeResult
        }
        return nil
    }
}


// MARK: Setup
extension FontAtlas {
    private mutating func setup(characters: [UInt32]) {
        // simple packing: row by row
        let padding = 1
        var rowHeight = 0
        var x = padding
        var y = padding
        var neededWidth = 256
        var neededHeight = 256
        var placements: [(char: UInt32, bitMapBuffer: [UInt8], width: Int, height: Int, bearingX: Int, bearingY: Int, advance: Int)] = []
        for char in characters {
            guard FT_Load_Char(face, FT_ULong(char), FT_Int32(FT_LOAD_RENDER)) == 0 else {
                continue
            }
            guard let glyph = face.pointee.glyph else {
                continue
            }
            let bitmap = glyph.pointee.bitmap
            let width = Int(bitmap.width)
            let height = Int(bitmap.rows)
            var data = [UInt8](repeating: 0, count: width * height)
            if width > 0 && height > 0, let buffer = bitmap.buffer {
                let buf = UnsafeBufferPointer(start: buffer, count: width * height)
                data = Array(buf)
            }
            if x + width + padding > neededWidth {
                x = padding
                y += rowHeight + padding
                rowHeight = 0
            }
            if y + height + padding > neededHeight {
                // grow atlas
                neededWidth *= 2
                neededHeight *= 2
            }
            placements.append((
                UInt32(char),
                data,
                width,
                height,
                Int(glyph.pointee.bitmap_left),
                Int(glyph.pointee.bitmap_top),
                Int(glyph.pointee.advance.x >> 6)
            ))
            x += width + padding
            rowHeight = max(rowHeight, height)
        }

        // simple second pass to compute final size and layout
        textureWidth = 1
        while textureWidth < neededWidth {
            textureWidth <<= 1
        }
        textureHeight = 1
        while textureHeight < neededHeight {
            textureHeight <<= 1
        }
        pixelData = Array(repeating: 0, count: textureWidth * textureHeight)

        // place glyphs in rows
        x = padding
        y = padding
        rowHeight = 0
        for (char, bitMapBuffer, width, height, bearingX, bearingY, advance) in placements {
            if x + width + padding > textureWidth {
                x = padding
                y += rowHeight + padding
                rowHeight = 0
            }
            if y + height + padding > textureHeight {
                // shouldn't happen with doubling above
                break
            }
            // copy
            for row in 0..<height {
                let destStart = (y + row) * textureWidth + x
                let srcStart = row * width
                pixelData[destStart..<(destStart + width)] = bitMapBuffer[srcStart..<(srcStart + width)]
            }
            let glyph = Glyph(
                codepoint: char,
                atlasX: x,
                atlasY: y,
                width: width,
                height: height,
                bearingX: bearingX,
                bearingY: bearingY,
                advance: advance
            )
            glyphs[char] = glyph
            x += width + padding
            rowHeight = max(rowHeight, height)
        }
    }
}

// MARK: Measure text
extension FontAtlas {
    public func measure(_ text: String) -> (width: Float, height: Float) {
        var width:Float = 0
        var maxAscent:Float = 0
        var maxDescent:Float = 0
        for scalar in text.unicodeScalars {
            guard let g = glyphs[UInt32(scalar.value)] else { continue }

            // horizontal width
            width += Float(g.advance)

            // vertical metrics
            maxAscent = max(maxAscent,  Float(g.bearingY))
            maxDescent = max(maxDescent, Float(g.height - g.bearingY))
        }
        return (width, maxAscent + maxDescent)
    }
}