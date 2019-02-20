//
//  GraphView+Draw.swift
//  DiskInfo
//
//  Created by Massimo Savino on 2019-02-19.
//  Copyright © 2019 erndev. All rights reserved.
//
import Cocoa
import Foundation
import CoreGraphics

// MARK: Drawing extension to GraphView

extension GraphView {
    func drawRoundedRect(rect: CGRect, inContext context: CGContext?,
                         radius: CGFloat, borderColor: CGColor, fillColor: CGColor) {
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.maxY), radius: radius)
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                    tangent2End: CGPoint(x: rect.minX, y: rect.maxY), radius: radius)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                    tangent2End: CGPoint(x: rect.minX, y: rect.minY), radius: radius)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.minY), radius: radius)
        path.closeSubpath()
        
        context?.setLineWidth(1.0)
        context?.setFillColor(fillColor)
        context?.setStrokeColor(borderColor)
        
        context?.addPath(path)
        context?.drawPath(using: .fillStroke)
    }
    
    func drawBarGraphInContext(context: CGContext?) {
        let barChartRect = barChartRectangle()
        drawRoundedRect(rect: barChartRect,
                        inContext: context,
                        radius: Constants.barChartCornerRadius,
                        borderColor: barChartAvailableLineColor.cgColor,
                        fillColor: barChartAvailableFillColor.cgColor)
        
        if let fileTypes = fileDistribution?.distribution, let capacity = fileDistribution?.capacity, capacity > 0 {
            var clipRect = barChartRect
            
            for (index, fileType) in fileTypes.enumerated() {
                
                // MARK: Colours and drawing code
                
                let fileTypeInfo = fileType.fileTypeInfo
                let clipWidth = floor(barChartRect.width * CGFloat(fileTypeInfo.percent))
                clipRect.size.width = clipWidth
                
                context?.saveGState()
                context?.clip(to: clipRect)
                
                let fileTypeColors = colorsForFileType(fileType: fileType)
                drawRoundedRect(rect: barChartRect,
                                inContext: context,
                                radius: Constants.barChartCornerRadius,
                                borderColor: fileTypeColors.fillColor.cgColor,
                                fillColor: fileTypeColors.fillColor.cgColor)
                
                context?.restoreGState()
                clipRect.origin.x = clipRect.maxX
                
                // MARK: Formatting the legend
                
                let legendRectWidth = (barChartRect.size.width / CGFloat(fileTypes.count))
                let legendOriginX = barChartRect.origin.x + floor(CGFloat(index) * legendRectWidth)
                let legendOriginY = barChartRect.minY - 2 * Constants.marginSize
                let legendSquareRect = CGRect(x: legendOriginX,
                                              y: legendOriginY,
                                              width: Constants.barChartLegendSquareSize,
                                              height: Constants.barChartLegendSquareSize)
                
                let legendSquarePath = CGMutablePath()
                legendSquarePath.addRect(legendSquareRect)
                
                context?.addPath(legendSquarePath)
                context?.setFillColor(fileTypeColors.fillColor.cgColor)
                context?.setStrokeColor(fileTypeColors.strokeColor.cgColor)
                context?.drawPath(using: .fillStroke)
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byTruncatingTail
                paragraphStyle.alignment = .left
                let nameTextAttributes = [
                    NSAttributedString.Key.font: NSFont.barChartLegendNameFont,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle]
                
                let nameTextSize = fileType.name.size(withAttributes: nameTextAttributes)
                let legendTextOriginX = legendSquareRect.maxX + Constants.legendTextMargin
                let legendTextOriginY = legendOriginY - 2 * Constants.pieChartBorderWidth
                let legendNameRect = CGRect(x: legendTextOriginX,
                                            y: legendTextOriginY,
                                            width: legendRectWidth
                                                 - legendSquareRect.size.width
                                                 - 2 * Constants.legendTextMargin,
                                            height: nameTextSize.height)
                
                fileType.name.draw(in: legendNameRect, withAttributes: nameTextAttributes)
                
                let bytesText = bytesFormatter.string(fromByteCount: fileTypeInfo.bytes)
                let bytesTextAttributes = [
                    NSAttributedString.Key.font: NSFont.barChartLegendNameFont,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.foregroundColor: NSColor.secondaryLabelColor
                ]
                let bytesTextSize = bytesText.size(withAttributes: bytesTextAttributes)
                let bytesTextRect = legendNameRect.offsetBy(dx: 0.0, dy: -bytesTextSize.height)
                bytesText.draw(in: bytesTextRect, withAttributes: bytesTextAttributes)
            }
        }
    }
}
