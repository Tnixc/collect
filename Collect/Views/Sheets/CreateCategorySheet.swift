import SwiftUI

struct CreateCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var categoryName: String = ""
    @State private var selectedColor: String = "blue"

    let predefinedColors = [
        "peach", "darkRed", "pink", "purple",
        "red", "salmon", "yellow", "orange",
        "darkGreen", "green", "teal", "blue",
        "cyan", "navy",
    ]

    var onCreate: (String, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Create New Category")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 12)

            // Description
            Text("Create a new category to organize your documents. Choose a name and color.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

            // Category Name Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Category Name")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                TextField("Enter category name", text: $categoryName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.backgroundTertiary)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppTheme.dividerColor, lineWidth: 1)
                    )
                    .smartFocusRing()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            // Color Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                WrappingHStack(spacing: 12) {
                    ForEach(predefinedColors, id: \.self) { colorName in
                        Button(action: { selectedColor = colorName }) {
                            Circle()
                                .fill(colorFromName(colorName))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.textPrimary, lineWidth: selectedColor == colorName ? 2 : 0)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.dividerColor, lineWidth: selectedColor == colorName ? 0 : 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            // Action Buttons
            HStack(spacing: 12) {
                UIButton(action: { dismiss() }, style: .plain, label: "Cancel")

                Spacer()

                UIButton(
                    action: {
                        if !categoryName.isEmpty {
                            onCreate(categoryName, selectedColor)
                            dismiss()
                        }
                    },
                    style: .primary,
                    label: "Create",
                    icon: "plus"
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 500)
        .background(AppTheme.backgroundPrimary)
        .cornerRadius(12)
    }

    private func colorFromName(_ name: String) -> Color {
        AppTheme.categoryColor(for: name)
    }
}
