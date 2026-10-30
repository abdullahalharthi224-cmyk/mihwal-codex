import Foundation

enum ToolCategory: String, CaseIterable, Identifiable {
    case organize
    case convert
    case images

    var id: String { rawValue }

    var titleKey: String {
        "category.\(rawValue)"
    }
}

enum ToolID: String, CaseIterable, Identifiable {
    case mergePDF, splitPDF, compressPDF, rotatePDF, deletePages, extractPages, reversePages
    case pageNumbers, textWatermarkPDF, stripMetadata, removeRestrictions
    case pdfToWord, pdfToText, textToPDF, imagesToPDF, pdfToImages
    case convertImage, compressImage, resizeImage, rotateFlipImage, textWatermarkImage

    var id: String { rawValue }
}

struct ToolDefinition: Identifiable, Hashable {
    let id: ToolID
    let category: ToolCategory
    let titleKey: String
    let subtitleKey: String
    let symbolName: String
}

enum ToolCatalog {
    static let all: [ToolDefinition] = [
        .init(id: .mergePDF, category: .organize, titleKey: "tool.merge", subtitleKey: "tool.merge.subtitle", symbolName: "rectangle.3.group"),
        .init(id: .splitPDF, category: .organize, titleKey: "tool.split", subtitleKey: "tool.split.subtitle", symbolName: "rectangle.split.3x1"),
        .init(id: .compressPDF, category: .organize, titleKey: "tool.compressPDF", subtitleKey: "tool.compressPDF.subtitle", symbolName: "arrow.down.right.and.arrow.up.left"),
        .init(id: .rotatePDF, category: .organize, titleKey: "tool.rotatePDF", subtitleKey: "tool.rotatePDF.subtitle", symbolName: "rotate.right"),
        .init(id: .deletePages, category: .organize, titleKey: "tool.deletePages", subtitleKey: "tool.deletePages.subtitle", symbolName: "trash"),
        .init(id: .extractPages, category: .organize, titleKey: "tool.extractPages", subtitleKey: "tool.extractPages.subtitle", symbolName: "doc.on.doc"),
        .init(id: .reversePages, category: .organize, titleKey: "tool.reversePages", subtitleKey: "tool.reversePages.subtitle", symbolName: "arrow.left.arrow.right"),
        .init(id: .pageNumbers, category: .organize, titleKey: "tool.pageNumbers", subtitleKey: "tool.pageNumbers.subtitle", symbolName: "list.number"),
        .init(id: .textWatermarkPDF, category: .organize, titleKey: "tool.textWatermarkPDF", subtitleKey: "tool.textWatermarkPDF.subtitle", symbolName: "textformat"),
        .init(id: .stripMetadata, category: .organize, titleKey: "tool.stripMetadata", subtitleKey: "tool.stripMetadata.subtitle", symbolName: "eye.slash"),
        .init(id: .removeRestrictions, category: .organize, titleKey: "tool.removeRestrictions", subtitleKey: "tool.removeRestrictions.subtitle", symbolName: "lock.open"),
        .init(id: .pdfToWord, category: .convert, titleKey: "tool.pdfToWord", subtitleKey: "tool.pdfToWord.subtitle", symbolName: "doc.richtext"),
        .init(id: .pdfToText, category: .convert, titleKey: "tool.pdfToText", subtitleKey: "tool.pdfToText.subtitle", symbolName: "doc.plaintext"),
        .init(id: .textToPDF, category: .convert, titleKey: "tool.textToPDF", subtitleKey: "tool.textToPDF.subtitle", symbolName: "doc.text"),
        .init(id: .imagesToPDF, category: .convert, titleKey: "tool.imagesToPDF", subtitleKey: "tool.imagesToPDF.subtitle", symbolName: "photo.on.rectangle"),
        .init(id: .pdfToImages, category: .convert, titleKey: "tool.pdfToImages", subtitleKey: "tool.pdfToImages.subtitle", symbolName: "photo.stack"),
        .init(id: .convertImage, category: .images, titleKey: "tool.convertImage", subtitleKey: "tool.convertImage.subtitle", symbolName: "arrow.triangle.2.circlepath"),
        .init(id: .compressImage, category: .images, titleKey: "tool.compressImage", subtitleKey: "tool.compressImage.subtitle", symbolName: "arrow.down.to.line"),
        .init(id: .resizeImage, category: .images, titleKey: "tool.resizeImage", subtitleKey: "tool.resizeImage.subtitle", symbolName: "arrow.up.left.and.arrow.down.right"),
        .init(id: .rotateFlipImage, category: .images, titleKey: "tool.rotateFlipImage", subtitleKey: "tool.rotateFlipImage.subtitle", symbolName: "rotate.left"),
        .init(id: .textWatermarkImage, category: .images, titleKey: "tool.textWatermarkImage", subtitleKey: "tool.textWatermarkImage.subtitle", symbolName: "character.cursor.ibeam")
    ]
}
