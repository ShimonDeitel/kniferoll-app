import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: KnifeItem?

    var body: some View {
        NavigationStack {
            Group {
                if store.items.isEmpty {
                    ContentUnavailableView("No Knifes Yet", systemImage: "tray", description: Text("Tap + to add your first knife."))
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(Theme.headlineFont)
                                        .foregroundStyle(Theme.ink)
                                    Text("Steel Type: \(item.steelType)")
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.inkMuted)
                                    Text("Sharpened: \(item.sharpened)")
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.inkMuted)
                                    if store.categoryToggles["Show Notes on Cards"] == true, !item.notes.isEmpty {
                                        Text(item.notes)
                                            .font(.caption)
                                            .foregroundStyle(Theme.inkMuted)
                                    }
                                }
                            }
                            .accessibilityIdentifier("itemRow_\(item.name)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("KnifeRoll")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.isAtFreeLimit && !purchases.isPro {
                            showingPaywall = true
                        } else {
                            showingAdd = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addItemButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ItemEditView(item: nil)
            }
            .sheet(item: $editingItem) { item in
                ItemEditView(item: item)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .background(Theme.background.ignoresSafeArea())
        }
    }
}

struct ItemEditView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    var item: KnifeItem?

    @State private var name: String = ""
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Knife Details") {
                    TextField("Name", text: $name)
                        .accessibilityIdentifier("itemNameField")
                    TextField("Steel Type", text: $field1)
                        .accessibilityIdentifier("itemField1Field")
                    TextField("Sharpened", text: $field2)
                        .accessibilityIdentifier("itemField2Field")
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .accessibilityIdentifier("itemNotesField")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(item == nil ? "Add Knife" : "Edit Knife")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("itemCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("itemSaveButton")
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    name = item.name
                    field1 = item.steelType
                    field2 = item.sharpened
                    notes = item.notes
                }
            }
        }
    }

    private func save() {
        if var item {
            item.name = name
            item.steelType = field1
            item.sharpened = field2
            item.notes = notes
            store.update(item)
        } else {
            let new = KnifeItem(name: name, steelType: field1, sharpened: field2, notes: notes)
            store.add(new)
        }
    }
}
