import SwiftUI

struct CreateCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var categoryName: String = ""
    @State private var selectedColor: String = "blue"

    let predefinedColors = ["blue", "green", "orange", "pink", "purple", "yellow", "gray", "tan"]

    var onCreate: (String, String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Category")
                .font(.title2)
                .foregroundColor(AppTheme.textPrimary)

            TextField("Category Name", text: $categoryName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .focusable(false)

            Picker("Color", selection: $selectedColor) {
                ForEach(predefinedColors, id: \.self) { colorName in
                    HStack {
                        Circle()
                            .fill(colorFromName(colorName))
                            .frame(width: 20, height: 20)
                        Text(colorName.capitalized)
                    }
                    .tag(colorName)
                }
            }
            .pickerStyle(.menu)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .focusable(false)

                Button("Create") {
                    onCreate(categoryName, selectedColor)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(categoryName.isEmpty)
                .focusable(false)
            }
        }
        .padding()
        .frame(width: 300, height: 250)
        .background(AppTheme.backgroundSecondary)
    }

    private func colorFromName(_ name: String) -> Color {
        switch name {
        case "blue": return Color.blue
        case "green": return Color.green
        case "orange": return Color.orange
        case "pink": return Color.pink
        case "purple": return Color.purple
        case "yellow": return Color.yellow
        case "gray": return Color.gray
        case "tan": return Color(red: 0.93, green: 0.88, blue: 0.82)
        default: return Color.blue
        }
    }
}
