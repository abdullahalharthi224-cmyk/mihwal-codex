import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var library: ToolLibrary
    @State private var searchText = ""
    @State private var selectedTool: ToolDefinition?

    private var matchingTools: [ToolDefinition] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ToolCatalog.all
        }
        return ToolCatalog.all.filter { tool in
            localized(tool.titleKey).localizedCaseInsensitiveContains(searchText)
                || localized(tool.subtitleKey).localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.section) {
                    if !library.recentIDs.isEmpty && searchText.isEmpty {
                        ToolSection(
                            title: localized("home.recent"),
                            tools: library.recentIDs.compactMap(tool(for:)),
                            selectedTool: $selectedTool
                        )
                    }

                    if !library.favoriteIDs.isEmpty && searchText.isEmpty {
                        ToolSection(
                            title: localized("home.favorites"),
                            tools: ToolCatalog.all.filter { library.favoriteIDs.contains($0.id) },
                            selectedTool: $selectedTool
                        )
                    }

                    ForEach(ToolCategory.allCases) { category in
                        let tools = matchingTools.filter { $0.category == category }
                        if !tools.isEmpty {
                            ToolSection(
                                title: localized(category.titleKey),
                                tools: tools,
                                selectedTool: $selectedTool
                            )
                        }
                    }

                    if matchingTools.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 72)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.regular)
            }
            .navigationTitle(localized("home.title"))
            .searchable(text: $searchText, prompt: localized("home.search"))
            .sheet(item: $selectedTool) { tool in
                ToolPlaceholderView(tool: tool)
            }
        }
    }

    private func tool(for id: ToolID) -> ToolDefinition? {
        ToolCatalog.all.first { $0.id == id }
    }
}

private struct ToolSection: View {
    let title: String
    let tools: [ToolDefinition]
    @Binding var selectedTool: ToolDefinition?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.compact) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, DesignSystem.Spacing.regular)

            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.compact) {
                ForEach(tools) { tool in
                    Button {
                        selectedTool = tool
                    } label: {
                        ToolCard(tool: tool)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(localized(tool.titleKey))
                    .accessibilityHint(localized(tool.subtitleKey))
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.regular)
        }
    }
}

private struct ToolCard: View {
    let tool: ToolDefinition

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: tool.symbolName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(DesignSystem.Colors.color(for: tool.category))
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(localized(tool.titleKey))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Text(localized(tool.subtitleKey))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .topLeading)
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ToolPlaceholderView: View {
    @EnvironmentObject private var library: ToolLibrary
    @Environment(\.dismiss) private var dismiss
    let tool: ToolDefinition

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                localized(tool.titleKey),
                systemImage: tool.symbolName,
                description: Text(localized("tool.comingSoon"))
            )
            .navigationTitle(localized(tool.titleKey))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        library.toggleFavorite(tool)
                    } label: {
                        Image(systemName: library.favoriteIDs.contains(tool.id) ? "star.fill" : "star")
                    }
                    .accessibilityLabel(localized("tool.favorite"))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localized("common.done")) {
                        library.recordUse(of: tool)
                        dismiss()
                    }
                }
            }
        }
    }
}

func localized(_ key: String) -> String {
    let translated = Bundle.main.localizedString(forKey: key, value: key, table: nil)
    guard translated == key else { return translated }
    return FallbackStrings.value(for: key)
}

private enum FallbackStrings {
    static func value(for key: String) -> String {
        let isArabic = Locale.current.language.languageCode?.identifier == "ar"
        let english: [String: String] = [
            "tool.split": "Split PDF", "tool.compressPDF": "Compress PDF", "tool.rotatePDF": "Rotate PDF",
            "tool.deletePages": "Delete pages", "tool.extractPages": "Extract pages", "tool.reversePages": "Reverse order",
            "tool.pageNumbers": "Page numbers", "tool.textWatermarkPDF": "Text watermark", "tool.stripMetadata": "Strip metadata",
            "tool.removeRestrictions": "Remove restrictions", "tool.pdfToWord": "PDF to Word", "tool.pdfToText": "PDF to text",
            "tool.textToPDF": "Text to PDF", "tool.imagesToPDF": "Images to PDF", "tool.pdfToImages": "PDF to images",
            "tool.convertImage": "Convert formats", "tool.compressImage": "Compress image", "tool.resizeImage": "Resize image",
            "tool.rotateFlipImage": "Rotate / flip", "tool.textWatermarkImage": "Text watermark"
        ]
        let arabic: [String: String] = [
            "tool.split": "تقسيم PDF", "tool.compressPDF": "ضغط PDF", "tool.rotatePDF": "تدوير PDF",
            "tool.deletePages": "حذف الصفحات", "tool.extractPages": "استخراج الصفحات", "tool.reversePages": "عكس الترتيب",
            "tool.pageNumbers": "ترقيم الصفحات", "tool.textWatermarkPDF": "علامة مائية نصية", "tool.stripMetadata": "إزالة البيانات الوصفية",
            "tool.removeRestrictions": "إزالة القيود", "tool.pdfToWord": "PDF إلى Word", "tool.pdfToText": "PDF إلى نص",
            "tool.textToPDF": "نص إلى PDF", "tool.imagesToPDF": "صور إلى PDF", "tool.pdfToImages": "PDF إلى صور",
            "tool.convertImage": "تحويل الصيغة", "tool.compressImage": "ضغط الصورة", "tool.resizeImage": "تغيير الحجم",
            "tool.rotateFlipImage": "تدوير / قلب", "tool.textWatermarkImage": "علامة مائية نصية"
        ]
        if key.hasSuffix(".subtitle") {
            return isArabic ? "معالجة على الجهاز" : "On-device processing"
        }
        return (isArabic ? arabic : english)[key] ?? key
    }
}
