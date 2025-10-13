import SwiftUI

struct EditCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @State private var categoryName: String
    @State private var selectedColor: String
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showDeleteConfirmation: Bool = false

    let category: Category
    let predefinedColors = [
        "peach", "darkRed", "pink", "purple",
        "red", "salmon", "yellow", "orange",
        "darkGreen", "green", "teal", "blue",
        "cyan", "navy",
    ]

    var onEdit: (String, String) -> Void

    init(category: Category, onEdit: @escaping (String, String) -> Void) {
        self.category = category
        self.onEdit = onEdit
        _categoryName = State(initialValue: category.name)
        _selectedColor = State(initialValue: category.color)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Edit Category")
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
            Text("Edit the name and color of this category.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .padding(.bottom, showError ? 12 : 20)

            // Error Message
            if showError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.destructive)
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.destructive)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }

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
                            .stroke(showError ? AppTheme.destructive : AppTheme.dividerColor, lineWidth: 1)
                    )
                    .smartFocusRing()
                    .onChange(of: categoryName) {
                        // Clear error when user starts typing
                        if showError {
                            showError = false
                        }
                    }
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

                UIButton(
                    action: { showDeleteConfirmation = true },
                    style: .destructive,
                    label: "Delete",
                    icon: "trash"
                )
                .foregroundColor(AppTheme.destructive)

                Spacer()

                UIButton(
                    action: {
                        // Trim whitespace
                        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)

                        // Validate name is not empty
                        guard !trimmedName.isEmpty else {
                            errorMessage = "Category name cannot be empty"
                            showError = true
                            return
                        }

                        // Validate name is different or only color changed
                        guard trimmedName != category.name || selectedColor != category.color else {
                            errorMessage = "No changes made"
                            showError = true
                            return
                        }

                        // Check for duplicate names (case-insensitive) if name changed
                        if trimmedName.lowercased() != category.name.lowercased() {
                            let existingCategories = appState.categories.map { $0.name.lowercased() }
                            if existingCategories.contains(trimmedName.lowercased()) {
                                errorMessage = "A category with this name already exists"
                                showError = true
                                return
                            }
                        }

                        // All validation passed
                        showError = false
                        onEdit(trimmedName, selectedColor)
                        dismiss()
                    },
                    style: .primary,
                    label: "Save Changes",
                    icon: "checkmark"
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 500)
        .background(AppTheme.backgroundPrimary)
        .cornerRadius(12)
        .id(themeManager.effectiveColorScheme)
        .alert("Delete Category?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                appState.deleteCategory(category.name)
                dismiss()
            }
        } message: {
            Text("This will remove '\(category.name)' from all items. This action cannot be undone.")
        }
    }

    private func colorFromName(_ name: String) -> Color {
        AppTheme.categoryColor(for: name)
    }
}
