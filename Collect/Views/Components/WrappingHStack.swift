//
//  WrappingHStack.swift
//  Collect
//
//  Created by tnixc on 12/10/2025.
//
import SwiftUI

struct WrappingHStack: Layout {
    var spacing: CGFloat

    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(
            sizes: sizes,
            spacing: spacing,
            in: proposal.width ?? .infinity
        ).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal _: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, spacing: spacing, in: bounds.width)
            .offsets

        for (offset, subview) in zip(offsets, subviews) {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + offset.x,
                    y: bounds.minY + offset.y
                ),
                proposal: .unspecified
            )
        }
    }

    private func layout(sizes: [CGSize], spacing: CGFloat, in width: CGFloat)
        -> (offsets: [CGPoint], size: CGSize)
    {
        var result: [CGPoint] = []
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for size in sizes {
            if currentPosition.x + size.width > width, !result.isEmpty {
                // Move to next line
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }

            result.append(currentPosition)
            currentPosition.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxX = max(maxX, currentPosition.x - spacing)
        }

        return (
            result, CGSize(width: maxX, height: currentPosition.y + lineHeight)
        )
    }
}
