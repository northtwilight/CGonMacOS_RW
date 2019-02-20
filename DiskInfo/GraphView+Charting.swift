//
//  GraphView+Charting.swift
//  DiskInfo
//
//  Created by Massimo Savino on 2019-02-19.
//  Copyright © 2019 erndev. All rights reserved.
//

import Cocoa
import Foundation
import CoreGraphics

// MARK: Charting Extensions to GraphView

extension GraphView {
    func pieChartRectangle() -> CGRect {
        let width = bounds.size.width * Constants.pieChartWidthPercentage - 2 * Constants.marginSize
        let height = bounds.size.height - 2 * Constants.marginSize
        let diameter = max(min(width, height), Constants.pieChartMinRadius)
        let rect = CGRect(x: Constants.marginSize, y: (bounds.midY - diameter / 2.0), width: diameter, height: diameter)
        return rect
    }
    
    func barChartRectangle() -> CGRect {
        let pieChartRect = pieChartRectangle()
        let width = bounds.size.width - pieChartRect.maxX - 2 * Constants.marginSize
        let rect = CGRect(x: pieChartRect.maxX + Constants.marginSize,
                          y: pieChartRect.midY + Constants.marginSize,
                          width: width, height: barHeight)
        return rect
    }
    
    func barChartLegendRectangle() -> CGRect {
        let barChartRect = barChartRectangle()
        let rect = barChartRect.offsetBy(dx: 0.0, dy: -(barChartRect.size.height + Constants.marginSize))
        return rect
    }
    
    func drawPieChart() {
        guard let fileDistribution = fileDistribution else {
            return
        }
        
        let rect = pieChartRectangle()
        let circle = NSBezierPath(ovalIn: rect)
        pieChartAvailableFillColor.setFill()
        pieChartAvailableLineColor.setStroke()
        circle.stroke()
        circle.fill()
        
        let path = NSBezierPath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let usedPercent = Double(fileDistribution.capacity - fileDistribution.available) / Double(fileDistribution.capacity)
        let endAngle = CGFloat(360 * usedPercent)
        let radius = rect.size.width / 2.0
        
        path.move(to: center)
        path.line(to: CGPoint(x: rect.maxX, y: center.y))
        path.appendArc(withCenter: center,
                       radius: radius,
                       startAngle: 0,
                       endAngle: endAngle)
        path.close()
        
        pieChartUsedLineColor.setStroke()
        
        path.stroke()
        
        if let gradient = NSGradient(starting: pieChartGradientStartColor, ending: pieChartGradientEndColor) {
            gradient.draw(in: path, angle: Constants.pieChartGradientAngle)
        }
        
        let usedMidAngle = endAngle / 2.0
        let availableMidAngle = (360.0 - endAngle) /  2.0
        let halfRadius = radius / 2.0
        
        let usedSpaceText = bytesFormatter.string(fromByteCount: fileDistribution.capacity)
        let usedSpaceTextAttributes = [ NSAttributedString.Key.font: NSFont.pieChartLegendFont,
                                        NSAttributedString.Key.foregroundColor: NSColor.pieChartUsedSpaceTextColor]
        let usedSpaceTextSize = usedSpaceText.size(withAttributes: usedSpaceTextAttributes)
        
        let xPosition = rect.midX + CGFloat(cos(-usedMidAngle.radians)) * halfRadius - (usedSpaceTextSize.width / 2.0)
        let yPosition = rect.midY + CGFloat(sin(usedMidAngle.radians)) * halfRadius - (usedSpaceTextSize.height / 2.0)
        usedSpaceText.draw(at: CGPoint(x: xPosition, y: yPosition), withAttributes: usedSpaceTextAttributes)
        
        let availableSpaceText = bytesFormatter.string(fromByteCount: fileDistribution.available)
        let availableSpaceTextAttributes = [ NSAttributedString.Key.font: NSFont.pieChartLegendFont,
                                             NSAttributedString.Key.foregroundColor: NSColor.pieChartAvailableSpaceTextColor]
        let availableSpaceTextSize = availableSpaceText.size(withAttributes: availableSpaceTextAttributes)
        
        let availableXPosition = rect.midX + cos(-availableMidAngle.radians) * halfRadius - (availableSpaceTextSize.width / 2.0)
        let availableYPosition = rect.midY + sin(-availableMidAngle.radians) * halfRadius - (availableSpaceTextSize.height / 2.0)
        availableSpaceText.draw(at: CGPoint(x: availableXPosition, y: availableYPosition), withAttributes: availableSpaceTextAttributes)
        
    }
}
