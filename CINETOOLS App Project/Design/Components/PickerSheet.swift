//
//  PickerSheet.swift
//  CineTools — Restyle v4 shared components
//
//  Bottom-sheet pickers. These only show options and report taps back to the screen,
//  which writes to its existing @State / settings — so all existing onChange logic still runs.
//

import SwiftUI

// MARK: - Option model

/// One row in a picker sheet. `id` is the index the screen already uses (brand, model, codec, accessory…).
struct PickerOption: Identifiable, Hashable {
    let id: Int
    let title: String
    var subtitle: String? = nil
}

// MARK: - Sheet scaffold

/// Title + Done header with scrolling content. Use inside `.sheet { ... }`.
struct SheetScaffold<Content: View>: View {
    let title: String
    var doneTitle: String = "Done"
    let onDone: () -> Void
    private let content: Content

    init(title: String,
         doneTitle: String = "Done",
         onDone: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.doneTitle = doneTitle
        self.onDone = onDone
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(Theme.Fonts.archivo(22, .semibold))
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Button(doneTitle, action: onDone)
                    .font(Theme.Fonts.archivo(17, .semibold))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .buttonStyle(.plain)
                    .frame(minHeight: Theme.Size.tapTarget)
            }
            .padding(.horizontal, Theme.Spacing.titleMargin)
            .padding(.top, 18)
            .padding(.bottom, 10)

            ScrollView {
                content
                    .padding(.horizontal, Theme.Spacing.cardMargin)
                    .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.card)
    }
}

extension View {
    /// Applies the v4 sheet look: medium/large detents, 30pt top radius, grabber, `card` fill.
    func themedSheet() -> some View {
        self
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(Theme.Radius.sheetTop)
            .presentationBackground(Theme.Colors.card)
            .preferredColorScheme(.dark)
    }
}

// MARK: - Selection indicator

/// Paper ✓ circle when selected; empty ring when not (shown only for multi-select).
struct SelectionIndicator: View {
    let isSelected: Bool
    var showsEmpty: Bool = false

    var body: some View {
        ZStack {
            if isSelected {
                Circle().fill(Theme.Colors.paper)
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.Colors.ink)
            } else if showsEmpty {
                Circle().stroke(Theme.Colors.track, lineWidth: 1.5)
            }
        }
        .frame(width: 28, height: 28)
        .animation(.snappy(duration: 0.2), value: isSelected)
    }
}

// MARK: - Single select

/// List of options; tapping one calls `onSelect(id)`. The screen decides what happens next
/// (set the binding, move on to the model list, dismiss…).
struct SelectionList: View {
    let options: [PickerOption]
    let selectedID: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.id) { position, option in
                Button {
                    onSelect(option.id)
                } label: {
                    OptionRowLabel(option: option) {
                        SelectionIndicator(isSelected: option.id == selectedID)
                    }
                }
                .buttonStyle(RowButtonStyle())
                .accessibilityAddTraits(option.id == selectedID ? .isSelected : [])

                if position < options.count - 1 {
                    RowDivider()
                }
            }
        }
        .background(Theme.Colors.cardRaised,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
    }
}

// MARK: - Multi select

/// Multi-select list (peripherals). Selection state and toggling stay in the screen,
/// so existing accessory logic (incl. focus / audio quantities) is reused untouched.
/// `rowAccessory` lets a selected row show extra controls, e.g. a quantity StepperPill.
struct MultiSelectList<RowAccessory: View>: View {
    let options: [PickerOption]
    let isSelected: (Int) -> Bool
    let onToggle: (Int) -> Void
    private let rowAccessory: (Int) -> RowAccessory

    init(options: [PickerOption],
         isSelected: @escaping (Int) -> Bool,
         onToggle: @escaping (Int) -> Void,
         @ViewBuilder rowAccessory: @escaping (Int) -> RowAccessory) {
        self.options = options
        self.isSelected = isSelected
        self.onToggle = onToggle
        self.rowAccessory = rowAccessory
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.id) { position, option in
                VStack(spacing: 0) {
                    Button {
                        onToggle(option.id)
                    } label: {
                        OptionRowLabel(option: option) {
                            SelectionIndicator(isSelected: isSelected(option.id), showsEmpty: true)
                        }
                    }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityAddTraits(isSelected(option.id) ? .isSelected : [])

                    rowAccessory(option.id)
                }

                if position < options.count - 1 {
                    RowDivider()
                }
            }
        }
        .background(Theme.Colors.cardRaised,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
    }
}

extension MultiSelectList where RowAccessory == EmptyView {
    init(options: [PickerOption],
         isSelected: @escaping (Int) -> Bool,
         onToggle: @escaping (Int) -> Void) {
        self.init(options: options, isSelected: isSelected, onToggle: onToggle) { _ in EmptyView() }
    }
}

// MARK: - Shared row label

private struct OptionRowLabel<Indicator: View>: View {
    let option: PickerOption
    private let indicator: Indicator

    init(option: PickerOption, @ViewBuilder indicator: () -> Indicator) {
        self.option = option
        self.indicator = indicator()
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(option.title)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textPrimary)
                if let subtitle = option.subtitle {
                    Text(subtitle)
                        .font(Theme.Fonts.subLabel)
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
            }
            Spacer(minLength: 8)
            indicator
        }
        .padding(.horizontal, Theme.Spacing.rowPadding)
        .padding(.vertical, 10)
        .frame(minHeight: option.subtitle == nil ? Theme.Size.rowMinHeight : Theme.Size.rowMinHeightWithSub)
        .contentShape(Rectangle())
    }
}
